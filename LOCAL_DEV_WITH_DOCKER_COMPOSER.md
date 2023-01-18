# How to set up the application locally for dev or fun

docker-compose -f dev-docker-compose.yml build

docker-compose -f dev-docker-compose.yml up -d

docker-compose -f dev-docker-compose.yml up -d --force-recreate

docker-compose -f dev-docker-compose.yml ps

docker-compose -f dev-docker-compose.yml logs -f --tail 8

docker-compose -f dev-docker-compose.yml stop
