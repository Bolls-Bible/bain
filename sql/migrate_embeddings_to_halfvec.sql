-- Converts bolls_verses.embedding (vector(1536), ~60 GB) to halfvec(1536) without downtime and without losing data.
-- Run BEFORE deploying migration 0016, from psql with autocommit, inside tmux/screen:
--   podman exec -i bolls-db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < sql/migrate_embeddings_to_halfvec.sql
-- Resumable: re-running continues where it stopped. Semantic search falls back to linear search from step 1 until step 4.
-- In a second pane, vacuum the table every few minutes so freed TOAST space is reused:
--   while true; do podman exec bolls-db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "VACUUM bolls_verses;"'; df -h /; sleep 300; done
-- Watch `df -h /`; pause if free space drops under ~15 GB.

-- 1. Drop the old index (frees ~33 GB) and add the new column.
DROP INDEX CONCURRENTLY IF EXISTS text_vector_index;
ALTER TABLE bolls_verses ADD COLUMN IF NOT EXISTS embedding_half halfvec(1536);

-- 2. Copy in batches. Each batch copies and clears the old value in ONE statement, so nothing is lost or duplicated.
DO $$
DECLARE
  last_id integer := (SELECT max(id) + 1 FROM bolls_verses);
  moved integer;
  total bigint := 0;
BEGIN
  LOOP
    WITH batch AS (
      SELECT id FROM bolls_verses
      WHERE id < last_id AND embedding IS NOT NULL
      ORDER BY id DESC LIMIT 2000
    ),
    upd AS (
      UPDATE bolls_verses v
      SET embedding_half = v.embedding::halfvec(1536), embedding = NULL
      FROM batch WHERE v.id = batch.id
      RETURNING v.id
    )
    SELECT min(id), count(*) INTO last_id, moved FROM upd;
    EXIT WHEN moved = 0;
    total := total + moved;
    RAISE NOTICE 'converted % rows, next id < %', total, last_id;
    COMMIT;
  END LOOP;
END $$;

-- 3. Verify: left_behind must be 0.
SELECT count(*) FILTER (WHERE embedding_half IS NOT NULL) AS converted,
       count(*) FILTER (WHERE embedding IS NOT NULL)      AS left_behind
FROM bolls_verses;

-- 4. Build the index (hours; needs ~16 GB). Do not run inside a transaction.
SET maintenance_work_mem = '2500MB';
SET max_parallel_maintenance_workers = 3;
CREATE INDEX CONCURRENTLY IF NOT EXISTS text_vector_halfvec_idx
  ON bolls_verses USING hnsw (embedding_half halfvec_cosine_ops)
  WITH (m = 16, ef_construction = 48)
  WHERE embedding_half IS NOT NULL;
-- Then deploy: migration 0016 drops the old column, renames embedding_half -> embedding (the index follows the rename).
-- Finally: ANALYZE bolls_verses; and, to return disk space to the OS, VACUUM FULL bolls_verses; (locks the table) or pg_repack.
