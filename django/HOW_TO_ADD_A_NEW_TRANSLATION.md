# How to add a new translation to the project.

### Find it in appropriate format.

I prefer sqlite modules from MyBible app. I have a `myBible_concordance.sql` file where is code for converting MyBible modules into appropriate for me format. I download that modules from 'https://www.ph4.ru/b4_poisk.php?text=YLT&abbr=0'. Except of sqlite modules it may be also any database or csv or structured data but mid that you will need to convert it into csv format to insert it into my postgresql db.

### Format it.

I download sqlite module from there. The downloaded zip may ,contain two sqlite databases. The translation itself and optionally comments (the one with `.commentaries.` in name). In the translation sqlite database run the code from `myBible_concordance.sql`, then export the `verses` and `books` table to csv files. csv format is handy for working with data. Then format the text in `verses.csv`, delete some unneded tags from there, convert some of that tags ...

Mind that the output will be interpreted as html. You may use there html tags like `<i></i>` or `<br>` &c to get the text neater. I would say also that you should use some text to make it looks better. Usually I get the text from MyBible modules and there are some patters. The `<J>` tags are incapsulating <i>Jesus words</i>. I delete it. There are `<t>` tags. Delete them. But the closing `</t>` tags change to new line tag `</br>`. There are many tags that I simply delete with regex. But you may find a new use for them. Map `<e>` to `<b>`

Also add before all a new collumn `translation` that should be filled with the abbreviation of the translation aka `YLT`, `KJV`, `UBIO` &c. *It should be unique!*  

### Prepare Books list for given translation

Also you need to format the books and make it a JavaScript array. Examples you may find in the `translations_books.json`. Be careful. Every book should have appropriate `bookid`, `chapters`, `chronorder` according to `name`. To make easier and more precise configuration of these fields I have created `book_list_generation.js` file with code that may help to add appropriate fields to the appropriate book. Comments about that inside.

If you add a translation of a new language -- don't forget to set the translation a default for new users with that language default in their browser. Go to `state.imba` and see the switch inside of constructor.

### If there are translator's commentaries -- prepare them too. Else -- skip this step.

I assume you are using MyBible modules.
Execute sql code from commentaries_concordance.sql in the commentaries database in order to format it.
Export the commentaries table as .csv from the formatted database, save it to `/commentaries/mybcommentaries.csv`.
Change `translation` variable at `/commentaries/main.py` to the translation abbreviation (for example 'JNT'), save and run it.
It will store to the commentaries.csv file commentaries, ready for pushing to the app database.
Run `\copy bolls_commentary(translation, book, chapter, verse, text) FROM '/home/bohuslav/bain/commentaries/commentaries.csv' DELIMITER ',' CSV HEADER;` to push the comments to the database (don't forget to edit the path :).


### Add it to the app.

After formating the text and books you may add it to the app. First of all copy the verses to the database with the next command:

```sql
\copy bolls_verses(translation, book, chapter, verse, text) FROM '/home/path_to_the_file/verses.csv' DELIMITER '|' CSV HEADER;
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


### May Jehovah bless you.