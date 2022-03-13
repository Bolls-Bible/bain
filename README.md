# bain

## Setting up the repo

- clone the repo using git

```bash
git clone git@github.com:Bohooslav/bain.git
```

- enter the directory

```bash
cd bain/django/
```

- set up local enviroment. This is a very important step. For now I work with python 3.7 because of gcloud works only on that + it is more stable for now.

```bash
pipenv
pipenv shell
```

- install reqirements using pip

```bash
pipenv install -r requirements.txt
```

- run server (I am using 0 host for better debugging. You are free to use whatever you want)

```bash
python manage.py runserver 0:8000
```

- and go to <http://0.0.0.0:8000/>
- check if everything is correct and you do not see any error. You will not see any verse, because to do that you should have installed PostreSQL, create bd 'bain', run migrations and fill a table 'bolls_verses' with translations. Ask me to get the translations <https:t.me/Boguslavv>. Using pgAdmin or cmd, create a database, called by default `bain`. 
- Then fill the database with default data (translations and commentaries) restoring this backup <https://drive.google.com/file/d/1HACNyHbzVi_7rGtv96HYrlutrJP-Lv6x/view?usp=sharing>. Dowload the backup and restore it.

```bash
pg_restore -v -d bain < bolls_backup.dump
```

 than run migrations to be sure everything is up to date:

```bash
python manage.py makemigrations
python manage.py migrate
```

- the next step is to go to `./bolls/static/bolls/` to install Imba dependencies

```bash
cd django/bolls/static/bolls/
npm install
```

- than watch the changes in files to compile them

```bash
npm run watch
```

After that you should be able to debug it.

### Checklist before any deploy

- update sw.js
- npm run build
- git pull on server
- ./inject-secrets.sh
- ./deploy.sh

And do not forget to clean expired sessions sometimes

```bash
python manage.py clearsessions
```

# Become a maintainer

You will get full access to Google Cloud project running the app backend, VPS with PostgreSQL database, abd this repo.
