# This folder created to keep sql scripts in one place
## Some notes
 - myBible_concordance.slq contains script needed for converting myBible sqLite modules books numerations to my own numeration
 - calculate_translation_hashes.sql contains function for calculatinf translation hashes to check out unexpected changes in translations
 - general.sql is just a bunch of rundom useful scripts used during the development
### How to add a new translation
 - First of all find <b>reliable source of translations</b>. I use myBible modules from https://www.ph4.ru/b4_poisk.php, my friend uses e-sword. The main thing is to find <b>reliable source of translations</b>.
 - Than convert it to my numeration of books, delete unneeded insertions if such exist. Just format it. It may contain sone html.
 - Than add it to local PosqgreSQL db called bain. The next commant may be used:
 ```sql
 psql bain
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/b/Bibles/{TRANSLATION}.csv' DELIMITER '|' CSV HEADER;

 ```
 - Generate array of books with the structure like in translation_books.json inside of components folder.
 - Add it to correspond language in languages.json.
 - Test it.
 - Deploy it. (Do not deploy in friday before Shabbat. It can do only me 😎 :)