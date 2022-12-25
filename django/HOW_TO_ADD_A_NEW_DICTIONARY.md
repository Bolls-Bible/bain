# How to add a new dictionary to the project.

### Find it in appropriate format.

I prefer sqlite modules from MyBible app. I download that modules from 'https://www.ph4.ru/b4_poisk.php?text=BDB&abbr=0'. Except of sqlite modules it may be also any database or csv or structured data but mid that you will need to convert it into csv format to insert it into my postgresql db.

### Format it.

Unarchive the downloaded zip. Export the `dictionary` table in csv format. `.csv` format is handy for working with data.  Mind that the output will be interpreted as html.

Also add before all a new collumn `dictionary` that should be filled with the abbreviation of the dictionaty aka `BDB`, `RUSD`, `BDBSC` &c. *It should be unique!*

🚧🚧🚧 Work in Progress 🚧🚧🚧

### Add it to the app.

After formating the text and books you may add it to the app. First of all copy the verses to the database with the next command:

```sql
\copy bolls_dictionary(...) FROM '/home/path_to_the_file/dictionary.csv' DELIMITER '|' CSV HEADER;
```

Also paste the books array with the abbreviation of the translation as a name. This abbreviation should be the same as the first collumn of the `translation` collumn in the database that is described above.

### Create pull request.

I will run it locally, test it, and if everything is workinig fine I will deploy it.
!NOTE. Attach to the pull request the csv files you were working with. I need them for my local db. It is not shipped with the project, because it is big. Next steps are for me.

### Deploy the translation to production database

Deploy the translation to main database. Log into linode instance with ssh and copy the csv file(s) to production database running in docker. Example commands for copying trnslation into container and inserting the data into database:

```bash
docker cp ./KB.csv db_dev:verses.csv
docker cp ./commentaries.csv db_dev:commentaries.csv

docker exec -i db_dev psql -U django_dev -d cotton -c "\copy bolls_verses(translation, book, chapter, verse, text) FROM 'verses.csv' DELIMITER ',' CSV HEADER;"

docker exec -i db_dev psql -U django_dev -d cotton -c "\copy bolls_commentary(translation, book, chapter, verse, text) FROM 'commentaries.csv' DELIMITER ',' CSV HEADER;"
```

Go to `https://bolls.life/get-translation/{abbreviation_of_the_new_translation}` and save the result to `translations` folder inside of `bolls/static/`. The saved filed should have thr translation abbreviation as its name and `.json` as extension. Then zip it. You may find examples in that folder. Otherwise the user will not be able to download it.

If it times out try to get it from inside container, `wget -O verses.json -timeout=0 localhost:8000/get-translation/<translation-abbrevition>/`.

### Test it.

Check out if it works. If the books chapters are in a proper number, if there are no weird signs. Check out everything that you think should be verified. And if everything is right...


### May Jhovah bless you.