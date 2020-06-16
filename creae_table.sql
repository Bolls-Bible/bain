COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/w.csv' DELIMITER ',' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/LUT.csv' DELIMITER '	' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/meng.csv' DELIMITER '|' CSV HEADER;

INSERT into bolls_verses(translation, book, chapter, verse, text) values ('RV1960', 1, 1, 1, 'En el principio creó Dios los cielos y la tierra.');


SELECT * FROM bolls_verses ORDER BY BOOK, CHAPTER, VERSE

SELECT translation, count(id) FROM bolls_verses GROUP BY translation
SELECT book, count(chapter) FROM bolls_verses GROUP BY chapter;
-- SELECT book_number, count(chapter) FROM verses where verse = 1 GROUP BY book_number;
SELECT * FROM bolls_verses where translation='LXX' ORDER BY BOOK, CHAPTER, VERSE

UPDATE bolls_verses SET text = ('Dios, en el principio, creó los cielos y la tierra. ') where translation='NVI' and book=1  and chapter=1 and verse=1
-----------
UPDATE bolls_verses SET book = 66 where translation='HOM' and book=67;
delete from bolls_verses where translation='HOM' and book = 72;
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/repairedbooks.csv' DELIMITER '|' CSV HEADER;
----------


\copy auth_user(id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM '/home/b/data-1583933238173.csv' DELIMITER ',' CSV HEADER;

psql    --host=bollsdb.cekf5swxirfn.us-east-2.rds.amazonaws.com    --port=5432    --username=postgres    --password    --dbname=bain
#8q^EMgAxWbmLGEp

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/NTjud_verses.csv' DELIMITER '|' CSV HEADER;
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/NRT_verses.csv' DELIMITER '|' CSV HEADER;

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/lost_books(20,22).csv' DELIMITER '|' CSV HEADER;

\copy bolls_bookmarks(id,color,note,user_id,verse_id,date) FROM '/home/b/Downloads/bolls_bookmarks.csv' DELIMITER ',' CSV HEADER;

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/test.csv' DELIMITER '|' CSV HEADER;


\copy (Select * From bolls_verses where translation='DNB') To '/home/b/Bibles/dnb.csv' With CSV DELIMITER '|';
\copy (select calculate_translation_hashes()) To '/home/b/hashes.csv' With CSV DELIMITER '|';


-- Fix broken sequences
CREATE OR REPLACE FUNCTION "reset_sequence" (tablename text, columnname text)
RETURNS "pg_catalog"."void" AS
$body$
DECLARE
BEGIN
    EXECUTE 'SELECT setval( pg_get_serial_sequence(''' || tablename || ''', ''' || columnname || '''),
    (SELECT COALESCE(MAX(id)+1,1) FROM ' || tablename || '), false)';
END;
$body$  LANGUAGE 'plpgsql';

select table_name || '_' || column_name || '_seq', reset_sequence(table_name, column_name) from information_schema.columns where column_default like 'nextval%';


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