This instructions are oriented on MyBible modules

First of all run script from `commentaries_concordance.sql` in the commentaries database shipped with MyBible module, something like `KB.commentaries.SQLite3`.

Then export `commentaries` table into a `mybcommentaries.csv` file.

Optionally there might be cross references file `ABBR.crossreferences.SQLite3`, run the script from `references_concordance.sql` in the cross references database. Then export `cross_references` table into a `cross_references.csv` file. If you use cross references you should update `books_short_names` variable at the books_map.py file.

Once all data in place -- update translation variable at `main.py`, comment out the `convert_cross_references_into_links` code call if you don't have cross references, and run it. Have fun!
