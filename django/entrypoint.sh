#!/bin/sh

# Unzipping translations...
for i in $(ls bolls/static/translations); do unzip bolls/static/translations/$i -d bolls/static/translations; done
for i in $(ls bolls/static/dictionaries); do unzip bolls/static/dictionaries/$i -d bolls/static/dictionaries; done

echo "Waiting for postgres..."
while ! nc -z $SQL_HOST $SQL_PORT; do
  sleep 0.1
done
echo "PostgreSQL started! Running migrations..."
python manage.py migrate --noinput
echo "Migrations complete! Collecting static files..."
python manage.py collectstatic --noinput --clear
rm -rf bolls/static
echo "Static files collected! Starting server..."
exec "$@"
