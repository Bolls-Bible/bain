create or replace function calculate_translation_hashes()
RETURNS TABLE (
  translation_name VARCHAR,
  translation_hash varchar
) AS $$
declare
 var_r record;
begin
 for var_r in (
    select
     subquery.translation,
     (
      select
       md5(CAST((array_agg(bv.* order by id)) AS text))
      from
       bolls_verses bv
      WHERE
       bv.translation = subquery.translation
     ) as hash_translation
    from (
      select distinct
       bv."translation"
      from
       bolls_verses bv
      group by
       "translation"
      ) subquery
     )
    LOOP
           translation_name := var_r.translation ;
     translation_hash := var_r.hash_translation;
           RETURN NEXT;
    END LOOP;

end; $$
LANGUAGE 'plpgsql';