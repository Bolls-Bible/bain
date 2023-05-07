# bain

## Setting up the repo

- clone the repo using git

```bash
git clone git@github.com:Bohooslav/bain.git
```

There are two ways you may run this project:
1. Just run it on bare metal, on your machine
2. Run it in docker with docker compose

### Bare metal setup

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
- Then fill the database with default data (translations and commentaries) restoring this backup <https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.dump>. Dowload the backup and restore it.

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

### Docker Compose setup

Go to [LOCAL_DEV_WITH_DOCKER_COMPOSER.md](LOCAL_DEV_WITH_DOCKER_COMPOSER.md) for mpore info

### Checklist before any deploy

- work is done on a branch name following the next pattern: 'feature/**'
- update sw.js
- npm run build
- push the branch to GitHub. See if the dev deploy is successful
- If the deploy is successful -- tag the branch with a new version tag (vX.X.X)
- Open pull request into `master` branch

And do not forget to clean expired sessions sometimes

```bash
python manage.py clearsessions
```

# Become a maintainer

You will get full access to this repo.

### [How to add a new translation](./django/HOW_TO_ADD_A_NEW_TRANSLATION.md)
### [How to add a new dictionary](./django/HOW_TO_ADD_A_NEW_DICTIONARY.md)
