#!/bin/bash

mkdir /letsencrypt
docker network create web
docker-compose up -d --build --force-recreate

# Run migrations
docker-compose exec web python manage.py migrate --noinput

# Collect static files
docker-compose exec web python manage.py collectstatic --no-input --clear

# Copy & activate unaccent rules
# Here I use container name `postgres`. That feature is not important in testing. Maybe...
# ill take your word for it -A
docker cp ./django/sql/unaccent_plus.rules  postgres:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules
docker exec -it postgres psql -U django -d bain -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

echo "Done."
