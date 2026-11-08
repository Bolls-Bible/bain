Just place MyBible module sqlite files here in the folder export-mybible-module and run the command `python main.py` to export the module and generate `books.json`, `verses.csv`, and `commentaries.csv` whenever applicable.

The script detects the translation abbreviation from the file names. Use files named like `ABBR.SQLite3` for verses and `ABBR.commentaries.SQLite3` for commentaries.

## Helpful commands for exporting

```bash
podman cp ./verses.csv database:verses.csv
podman exec -i database psql -U postgres_user -d postgres_db -c "\copy bolls_verses(translation, book, chapter, verse, text) FROM 'verses.csv' DELIMITER ',' CSV HEADER;"
podman exec -i database rm verses.csv

# commentaries
podman cp ./commentaries.csv database:commentaries.csv
podman exec -i database psql -U postgres_user -d postgres_db -c "\copy bolls_commentary(translation, book, chapter, verse, text) FROM 'commentaries.csv' DELIMITER ',' CSV HEADER;"
podman exec -i database rm commentaries.csv

podman cp ./SECE.csv database:lexicon.csv
podman exec -i database psql -U postgres_user -d postgres_db -c "\copy bolls_dictionary(dictionary, topic, definition, lexeme, transliteration, pronunciation, short_definition) FROM 'lexicon.csv' DELIMITER ',' CSV HEADER;"
podman exec -i database rm lexicon.csv

# Nuke options
# delete the dictionary
podman exec -i database psql -U postgres_user -d postgres_db -c "DELETE FROM bolls_dictionary WHERE dictionary='NA28'"
# delete the commentaries
podman exec -i database psql -U postgres_user -d postgres_db -c "DELETE FROM bolls_commentary WHERE translation='NA28'"
# delete a translation
podman exec -i database psql -U postgres_user -d postgres_db -c "DELETE FROM bolls_verses where translation='KBSI';"
```
