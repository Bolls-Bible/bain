----------- INSERTING OF THE TEXT TO THE DB
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/prj/translations/HAC.csv' DELIMITER '|' CSV HEADER;
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/prj/translations/KB.csv' DELIMITER ',' CSV HEADER;


COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/w.csv' DELIMITER ',' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/imba/Bibles/LUT.csv' DELIMITER '	' CSV HEADER;
COPY bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/meng.csv' DELIMITER '|' CSV HEADER;


----------- INSERTING COMMENTARIES TO THE DB
\copy bolls_commentary(translation, book, chapter, verse, text) FROM '/home/bohuslav/bain/django/commentaries/commentaries.csv' DELIMITER ',' CSV HEADER;


docker exec -i <database_container> psql -U <database_user> -d <database_name> -c "<sql command>"
docker exec -i database_container psql -U database_user -d database_name -c "sql_command"

-- ADD NEW TRANSLATION TO LOCAL DEV DB IN DOCKER CONTAINER --
docker cp ./DSV+.csv database:verses.csv
docker exec -i database psql -U postgres_user -d postgres_db -c "\copy bolls_verses(translation, book, chapter, verse, text) FROM 'verses.csv' DELIMITER ',' CSV HEADER;"


----------- DOCKER HELPER COMMANDS -----------
 docker cp ./S00.csv database:verses.csv
 docker cp ./commentaries.csv database:commentaries.csv
 
 docker exec -i database psql -U postgres_user -d postgres_db -c "\copy bolls_verses(translation, book, chapter, verse,  text) FROM 'verses.csv' DELIMITER ',' CSV HEADER;"
 
 docker exec -i database psql -U postgres_user -d postgres_db -c "\copy bolls_commentary(translation, book, chapter, verse, text) FROM 'commentaries.csv' DELIMITER ',' CSV HEADER;"


 docker exec -i database psql -U postgres_user -d postgres_db -c "\copy bolls_verses(translation, book, chapter, verse, text) FROM 'verses.csv' DELIMITER ',' CSV HEADER;"

 delete FROM bolls_verses where translation='NJB' and book = 72;
 docker exec -i database psql -U postgres_user -d postgres_db -c "delete FROM bolls_verses where translation='DSV+'"


ALTER TABLE dictionary
  ADD dictionary TEXT DEFAULT "BDBT" NOT NULL;

\copy bolls_dictionary(topic,definition,lexeme,transliteration,pronunciation,short_definition,dictionary) FROM '/home/bohuslav/prj/translations/eng.csv' DELIMITER ',' CSV HEADER;

INSERT inTO bolls_verses(translation, book, chapter, verse, text) values ('RV1960', 1, 1, 1, 'En el principio creó Dios los cielos y la tierra.');


SELECT * FROM bolls_verses ORDER BY BOOK, CHAPTER, VERSE;

select * from bolls_verses where translation='KJA' and book=20 and chapter=1 and verse=8;

SELECT translation, count(id) FROM bolls_verses GROUP BY translation;
SELECT book, count(chapter) FROM bolls_verses GROUP BY chapter;
SELECT book, count(chapter) FROM bolls_verses where translation='NDL' GROUP BY chapter;
-- SELECT book_number, count(chapter) FROM verses where verse = 1 GROUP BY book_number;
SELECT * FROM bolls_verses where translation='LXX' ORDER BY BOOK, CHAPTER, VERSE;

-- SELECT book, count(chapter) FROM bolls_verses where translation='NBS' and verse = 1 GROUP BY book;



UPDATE bolls_verses SET text = ('— Eu sou o bom Pastor. Conheço as minhas ovelhas, assim como o meu Pai me conhece. E as minhas ovelhas me conhecem,') where translation='VFL' and book=43 and chapter=10 and verse=14
INSERT INTO bolls_verses(translation, book, chapter, verse, text) values ('VFL', 43, 10, 15, 'assim como eu conheço o Pai. Eu dou a minha vida pelas ovelhas.');
UPDATE bolls_verses SET text = ('Foi um profeta deles mesmos, lá da ilha de Creta, que disse: “Os cretenses são sempre mentirosos, feras terríveis e comilões preguiçosos”.') where translation='VFL' and book=56 and chapter=1 and verse=12


SELECT * FROM bolls_verses where translation = 'WLCa' and book = 24 and chapter = 36 and verse = 3;
SELECT unaccent(text) FROM bolls_verses where translation = 'WLCa' and book = 24 and chapter = 36 and verse = 3;
SUV/1/6/4
SELECT * FROM bolls_verses where translation = 'SUV' and book = 1 and chapter = 6 and verse = 4;
UPDATE bolls_verses SET text = (' Nao Wanefili walikuwako duniani siku zile; tena, baada ya hayo, wana wa Mungu walipoingia kwa binti za wanadamu, wakazaa nao wana; hao ndio waliokuwa watu hodari zamani, watu wenye sifa.') where translation = 'SUV' and book = 1 and chapter = 6 and verse = 4;
INSERT INTO bolls_verses (translation, book, chapter, verse, text) VALUES ('TR', 40, 1, 1, 'βιβλος γενεσεως ιησου χριστου υιου δαβιδ υιου αβρααμ');

docker exec -i db psql -U django -d bain -c "INSERT INTO bolls_verses (translation, book, chapter, verse, text) VALUES ('TR', 40, 1, 1, 'βιβλος γενεσεως ιησου χριστου υιου δαβιδ υιου αβρααμ');"
docker exec -i database psql -U postgres_user -d postgres_db -c "INSERT INTO bolls_verses (translation, book, chapter, verse, text) VALUES ('TR', 40, 1, 1, 'βιβλος γενεσεως ιησου χριστου υιου δαβιδ υιου αβρααμ');"


UPDATE bolls_verses SET book = 66 where translation='HOM' and book=67;
delete FROM bolls_verses where translation='NJB' and book = 72;

SELECT book_number, count(chapter) FROM verses where verse = 1 GROUP BY book_number;
SELECT count(verse) FROM verses where book_number < 67;
SELECT count(verse) FROM bolls_verses where book < 67 and translation='KJV';

-- Insert this to bolls_verses with translation KJV, book 43, chapter 4 verse 50
INSERT INTO bolls_verses (translation, book, chapter, verse, text) VALUES ('KJV', 43, 4, 50, 'Jesus saith unto him, Go thy way; thy son liveth. And the man believed the word that Jesus had spoken unto him, and he went his way.');

docker exec -i database psql -U postgres_user postgres_db -c "INSERT INTO bolls_verses (translation, book, chapter, verse, text) VALUES ('KJV', 43, 4, 50, 'Jesus saith unto him, Go thy way; thy son liveth. And the man believed the word that Jesus had spoken unto him, and he went his way.');"

----------
UPDATE bolls_bookmarks SET verse_id = y where verse_id = x;

\copy auth_user(id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM '/home/b/data-1583933238173.csv' DELIMITER ',' CSV HEADER;
\copy bolls_bookmarks(id, color, collection, user_id, verse_id, date, note_id) FROM 'bookmarks.csv' DELIMITER '|' CSV HEADER;

psql    --host=144.126.148.204    --port=5432    --username=bain    --password    --dbname=bain

\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/prj/translations/VFL.csv' DELIMITER '|' CSV HEADER;
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/prj/translations/NIV.csv' DELIMITER ',' CSV HEADER;



\copy bolls_verses(id, translation, book, chapter, verse, text) FROM '~/prj/translations/ylt.csv' DELIMITER '|' CSV HEADER;
\copy bolls_dictionary(id,topic,definition,lexeme,transliteration,pronunciation,short_definition,dictionary) FROM '~/prj/translations/bdbt.csv' DELIMITER '|' CSV HEADER;



\copy (SELECT * FROM bolls_verses where translation='YLT') TO '~/prj/translations/ylt.csv' WITH CSV DELIMITER '|';
\copy (SELECT * FROM bolls_dictionary where dictionary='BDBT') TO '~/prj/translations/bdbt.csv' WITH CSV DELIMITER '|';
\copy (SELECT * FROM bolls_verses) TO '/home/bohuslav/verses.csv' WITH CSV DELIMITER '|';
\copy (SELECT calculate_translation_hashes()) TO '/home/b/hashes.csv' WITH CSV DELIMITER '|';
\copy (SELECT * FROM bolls_bookmarks) TO 'bookmarks.csv' WITH CSV DELIMITER '|';
\copy (SELECT * FROM bolls_commentary) TO '/home/bohuslav/commentary.csv' WITH CSV DELIMITER '|';


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





\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/bohuslav/prj/translations/PHIL.csv' DELIMITER ',' CSV HEADER;
\copy bolls_commentary(translation, book, chapter, verse, text) FROM '/home/bohuslav/bain/django/commentaries/commentaries.csv' DELIMITER ',' CSV HEADER;
