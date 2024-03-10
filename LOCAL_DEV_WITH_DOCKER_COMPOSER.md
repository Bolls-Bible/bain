# How to set up the application locally for dev or fun

### Basic commands to run the application locally

```bash
docker compose -f dev-docker-compose.yml build
docker network create web
docker compose -f dev-docker-compose.yml up -d
```

Then restore the database from a [backup file](https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.sql)

```bash
docker exec -i database psql -U postgres_user postgres_db < backup.sql
# or
docker exec -i database psql -U postgres_user postgres_db < backup.dump
```
If it doesn't work, enter the container with `docker exec -it database bash` and try from inside.


### After successful dump restoring -- don't forget to reset sequences. Log into dbs psql
`docker exec -it database psql -U postgres_user -d postgres_db`

Then run this code
```
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
```
It may take a while before it completes


Now add `bolls.local` to your hosts file (on linux it's /etc/hosts)


```bash
Now you should be able to open the application in your browser at http://bolls.local


### Basic commands for debugging and logging

```bash

docker compose -f dev-docker-compose.yml up -d --force-recreate

docker compose -f dev-docker-compose.yml ps

docker compose -f dev-docker-compose.yml logs -f --tail 8

docker compose -f dev-docker-compose.yml stop

docker compose -f docker-compose.dev.yml exec django python manage.py migrate --noinput 

docker cp ./django/sql/unaccent_plus.rules  db:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules

docker exec -i db psql -U django -d cotton -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

docker cp ./django/sql/unaccent_plus.rules  database:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules
docker exec -t database psql -U postgres_user -d postgres_db -c "CREATE EXTENSION unaccent;"
docker exec -i database psql -U postgres_user -d postgres_db -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

docker compose -f docker-compose.dev.yml  exec -T django python manage.py test --keepdb
```
