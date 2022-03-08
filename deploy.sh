#!/bin/bash

mkdir /letsencrypt
docker network create web
docker-compose up -d --build --force-recreate

# Run migrations
docker-compose exec web_dev python manage.py migrate --noinput

# Collect static files
docker-compose exec web_dev python manage.py collectstatic --no-input --clear

# Copy & activate unaccent rules
# Here I use container name `postgres`. That feature is not important in testing. Maybe...
# ill take your word for it -A
docker cp ./django/sql/unaccent_plus.rules  db_dev:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules
docker exec -i db_dev psql -U django_dev -d cotton -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

echo "Done."
