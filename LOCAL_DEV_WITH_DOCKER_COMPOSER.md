# How to set up the application locally for dev or fun

### Basic commands to run the application locally

```bash
docker-compose -f dev-docker-compose.yml build

docker-compose -f dev-docker-compose.yml up -d
```

Then restore the database from a (backup file)[https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.sql]

```bash
docker exec -i database psql -U postgres_user postgres_db < backup.sql
```
If it doesn't work, enter the container with `docker exec -it database bash` and try from inside.


Now you should be able to open the application in your browser at http://bolls.local


### Basic commands for debugging and logging

```bash

docker-compose -f dev-docker-compose.yml up -d --force-recreate

docker-compose -f dev-docker-compose.yml ps

docker-compose -f dev-docker-compose.yml logs -f --tail 8

docker-compose -f dev-docker-compose.yml stop
```
