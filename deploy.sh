#!/bin/bash

python manage.py collectstatic --no-input --clear
gcloud app deploy --quiet
echo "Done."
