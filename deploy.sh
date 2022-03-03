#!/bin/bash

mkdir letsencrypt
docker network create web
docker-compose up -d --build --force-recreate --remove-orphans

# Run migrations
docker-compose exec web python manage.py migrate --noinput

# Collect static files
docker-compose exec web python manage.py collectstatic --no-input --clear

# Copy & activate unaccent rules
docker cp ./django/sql/unaccent_plus.rules  46aa08d2b689:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules
docker exec -it 46aa08d2b689 psql -U django -d bain -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

echo "Done."
