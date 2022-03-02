#!/bin/bash

exec inject-secrets.sh
mkdir letsencrypt
docker network create web
docker-compose up -d --build --force-recreate --remove-orphans
docker-compose exec web python manage.py migrate --noinput
docker-compose exec web python manage.py collectstatic --no-input --clear
echo "Done."
