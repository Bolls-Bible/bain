# How to set up the application locally for dev or fun

- Clone the repo using git

```bash
git clone git@github.com:Bolls-Bible/bain.git
```

### Basic commands to run the application locally

```bash
make build
make create-network
```

Now add `bolls.local` to your hosts file (on linux it's /etc/hosts) and generate ssl certificates by running

```bash
make mkcert-install
```

Then create .env.dev (may be empty) and run the application with

```bash
make up
```

And don't forget to run migrations and create a superuser with

```bash
make migrate
make createsuperuser
```

Once it runs you can download and restore essential tables in the database, run

```bash
make restore-db
```

Now you should be able to open the application in your browser at https://bolls.local

### Basic commands for debugging and logging

```bash

docker compose up -d --force-recreate

docker compose ps

docker compose logs -f --tail 8

docker compose stop

docker compose exec django python manage.py makemigrations
docker compose exec django python manage.py migrate --noinput

docker cp ./django/sql/unaccent_plus.rules db:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules

docker exec -i db psql -U django -d cotton -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

docker cp ./django/sql/unaccent_plus.rules database:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules
docker exec -t database psql -U postgres_user -d postgres_db -c "CREATE EXTENSION unaccent;"
docker exec -i database psql -U postgres_user -d postgres_db -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

docker compose exec -T django python manage.py test --keepdb
```
