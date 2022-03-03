----------- INSERTING OF THE TEXT TO THE DB
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/projects/bolls_data/HAC.csv' DELIMITER '|' CSV HEADER;
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/projects/bolls_data/HAC.csv' DELIMITER ',' CSV HEADER;


COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/w.csv' DELIMITER ',' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/LUT.csv' DELIMITER '	' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/meng.csv' DELIMITER '|' CSV HEADER;


----------- INSERTING COMMENTARIES TO THE DB
\copy bolls_commentary(translation, book, chapter, verse, text) FROM '/home/bohuslav/bain/commentaries/commentaries.csv' DELIMITER ',' CSV HEADER;


ALTER TABLE dictionary
  ADD dictionary TEXT DEFAULT "BDBT" NOT NULL;

\copy bolls_dictionary(topic,definition,lexeme,transliteration,pronunciation,short_definition,dictionary) FROM '/home/bohuslav/projects/bolls_data/eng.csv' DELIMITER ',' CSV HEADER;

INSERT inTO bolls_verses(translation, book, chapter, verse, text) values ('RV1960', 1, 1, 1, 'En el principio creó Dios los cielos y la tierra.');


SELECT * FROM bolls_verses ORDER BY BOOK, CHAPTER, VERSE;

select * from bolls_verses where translation='KJA' and book=20 and chapter=1 and verse=8;

SELECT translation, count(id) FROM bolls_verses GROUP BY translation;
SELECT book, count(chapter) FROM bolls_verses GROUP BY chapter;
SELECT book, count(chapter) FROM bolls_verses where translation='NDL' GROUP BY chapter;
-- SELECT book_number, count(chapter) FROM verses where verse = 1 GROUP BY book_number;
SELECT * FROM bolls_verses where translation='LXX' ORDER BY BOOK, CHAPTER, VERSE;

-- SELECT book, count(chapter) FROM bolls_verses where translation='NBS' and verse = 1 GROUP BY book;

UPDATE bolls_verses SET text = ('Filho meu, ouve a instrução de teu pai e não menosprezes o ensino de tua mãe.') where translation='KJA' and book=20 and chapter=1 and verse=8;
SELECT * FROM bolls_verses where translation = 'YLT' and book = 24 and chapter = 36 and verse = 3;
YLT/24/36/3/

UPDATE bolls_verses SET book = 66 where translation='HOM' and book=67;
delete FROM bolls_verses where translation='NJB' and book = 72;

SELECT book_number, count(chapter) FROM verses where verse = 1 GROUP BY book_number;
SELECT count(verse) FROM verses where book_number < 67;
SELECT count(verse) FROM bolls_verses where book < 67 and translation='KJV';


----------
UPDATE bolls_bookmarks SET verse_id = y where verse_id = x;

\copy auth_user(id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM '/home/b/data-1583933238173.csv' DELIMITER ',' CSV HEADER;
\copy bolls_bookmarks(id, color, collection, user_id, verse_id, date, note_id) FROM 'bookmarks.csv' DELIMITER '|' CSV HEADER;

psql    --host=144.126.148.204    --port=5432    --username=bain    --password    --dbname=bain

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/projects/bolls_data/VFL.csv' DELIMITER '|' CSV HEADER;
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/projects/bolls_data/VFL.csv' DELIMITER ',' CSV HEADER;


\copy bolls_verses(id, translation, book, chapter, verse, text) FROM '/home/bohuslav/Documents/Bible/verses.csv' DELIMITER '|' CSV HEADER;



\copy (SELECT * FROM bolls_verses where translation='DNB') TO '/home/b/Bibles/dnb.csv' WITH CSV DELIMITER '|';
\copy (SELECT * FROM bolls_verses) TO '/home/bohuslav/verses.csv' WITH CSV DELIMITER '|';
\copy (SELECT calculate_translation_hashes()) TO '/home/b/hashes.csv' WITH CSV DELIMITER '|';
\copy (SELECT * FROM bolls_bookmarks) TO 'bookmarks.csv' WITH CSV DELIMITER '|';


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

SELECT table_name || '_' || column_name || '_seq', reset_sequence(table_name, column_name) FROM information_schema.columns where column_default like 'nextval%';
-- END


SELECT * FROM bolls_verses where id = 1523961 or id = 1526351 or id = 1524145 or id = 1506556 or id = 1508819 or id = 1522125 or id = 1523633 or id = 1508764 or id = 1520680 or id = 1520080 or id = 1506559 or id = 1523873 or id = 1525284 or id = 1506560 or id = 1511896 or id = 1524268 or id = 1525921 or id = 1506561 or id = 1525764 or id = 1520581 or id = 1520580 or id = 1525136 or id = 1508946 or id = 1509867 or id = 1509868 or id = 1520923 or id = 1522135;


DELETE FROM bolls_verses lg
WHERE  NOT EXISTS (
   SELECT FROM bolls_bookmarks lr
   WHERE  lr.verse_id = lg.id
   ) and translation = 'DELETED';

UPDATE bolls_verses SET translation = ('DELETED') where translation = 'KJV';





\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/projects/bolls_data/NJB.csv' DELIMITER ',' CSV HEADER;
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/projects/bolls_data/FACB.csv' DELIMITER ',' CSV HEADER;
\copy bolls_commentary(translation, book, chapter, verse, text) FROM '/home/bohuslav/bain/commentaries/commentaries.csv' DELIMITER ',' CSV HEADER;
