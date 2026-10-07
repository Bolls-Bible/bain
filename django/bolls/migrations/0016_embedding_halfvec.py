import pgvector.django.halfvec
import pgvector.django.indexes
from django.db import migrations, models

# The heavy work (copying vectors to a halfvec column and building the HNSW index) is done by hand beforehand with
# sql/migrate_embeddings_to_halfvec.sql, because it takes hours and must not run inside `migrate`.
# This migration only swaps the (already emptied) old column for the new one and syncs Django's state.

SWAP_SQL = """
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM bolls_verses WHERE embedding IS NOT NULL) THEN
    RAISE EXCEPTION 'bolls_verses.embedding still holds vectors: run sql/migrate_embeddings_to_halfvec.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'text_vector_halfvec_idx') THEN
    RAISE EXCEPTION 'text_vector_halfvec_idx is missing: run sql/migrate_embeddings_to_halfvec.sql first';
  END IF;
END $$;
DROP INDEX IF EXISTS text_vector_index;
ALTER TABLE bolls_verses DROP COLUMN embedding;
ALTER TABLE bolls_verses RENAME COLUMN embedding_half TO embedding;
"""


class Migration(migrations.Migration):
    dependencies = [("bolls", "0015_verses_embedding_verses_text_vector_index")]

    operations = [
        migrations.SeparateDatabaseAndState(
            state_operations=[
                migrations.RemoveIndex(model_name="verses", name="text_vector_index"),
                migrations.AlterField(
                    model_name="verses",
                    name="embedding",
                    field=pgvector.django.halfvec.HalfVectorField(blank=True, dimensions=1536, null=True),
                ),
                migrations.AddIndex(
                    model_name="verses",
                    index=pgvector.django.indexes.HnswIndex(
                        condition=models.Q(("embedding__isnull", False)),
                        ef_construction=48,
                        fields=["embedding"],
                        m=16,
                        name="text_vector_halfvec_idx",
                        opclasses=["halfvec_cosine_ops"],
                    ),
                ),
            ],
            database_operations=[migrations.RunSQL(SWAP_SQL, migrations.RunSQL.noop)],
        ),
    ]
