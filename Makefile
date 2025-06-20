# HELP
# ANSI escape codes for colors and styles
RESET := "\033[0m"
BOLD := "\033[1m"
UNDERLINE := "\033[4m"
GREEN := "\033[32m"
CYAN := "\033[36m"
YELLOW := "\033[33m"

# Use podman or docker for container management
# DOCKER := docker
DOCKER := podman

help:
	@echo -e ${BOLD}Usage:${RESET}
	@echo "  make [target]"
	@echo ""
	@echo -e ${BOLD}Targets:${RESET}
	@echo -e "  "${GREEN}"Network"${RESET}
	@echo -e "    "${CYAN}"create-network"${RESET}"        Create a docker network"
	@echo -e "    "${CYAN}"mkcert-install"${RESET}"        Install mkcert"
	@echo -e "    "${CYAN}"certs-generate"${RESET}"        Generate certificates"
	@echo -e ""
	@echo -e "  "${GREEN}"Docker Compose"${RESET}
	@echo -e "    "${CYAN}"build"${RESET}"                 Build the docker images"
	@echo -e "    "${CYAN}"build-no-cache"${RESET}"        Build the docker images without cache"
	@echo -e "    "${CYAN}"restore-db"${RESET}"            Restore the database"
	@echo -e "    "${CYAN}"up"${RESET}"                    Start the docker containers"
	@echo -e "    "${CYAN}"down"${RESET}"                  Stop the docker containers"
	@echo -e "    "${CYAN}"restart"${RESET}"               Restart the docker containers"
	@echo -e ""
	@echo -e "  "${GREEN}"Django"${RESET}
	@echo -e "    "${CYAN}"createsuperuser"${RESET}"       Create a superuser"
	@echo -e "    "${CYAN}"migrations"${RESET}"            Create migrations"
	@echo -e "    "${CYAN}"migrate"${RESET}"               Apply migrations"
	@echo -e "    "${CYAN}"shell"${RESET}"                 Open the Django shell"
	@echo -e ""
	@echo -e "  "${GREEN}"Node/Imba"${RESET}
	@echo -e "    "${CYAN}"npm-install, ni"${RESET}"        Install npm packages"
	@echo -e "    "${CYAN}"npm-run, nr"${RESET}"            Run npm scripts"
	@echo -e "    "${CYAN}"npm-update, nu"${RESET}"         Update npm packages"
	@echo -e "    "${CYAN}"npm-outdated, no"${RESET}"       Check outdated npm packages"
	@echo -e "    "${CYAN}"npm-update-all, nua"${RESET}"    Update all npm packages"
	@echo -e "    "${CYAN}"enter-node, en"${RESET}"         Enter the node container"
	@echo -e ""
	@echo -e "  "${GREEN}"This Help"${RESET}
	@echo -e "    "${CYAN}"help"${RESET}"                  Display this help message"
	@echo ""



# Run once only
create-network:
	$(DOCKER) network create web

mkcert-install:
	./mkcert/mkcert-install.sh
	@$(MAKE) certs-generate

certs-generate:
	./mkcert/mkcert-certs.sh


build:
	$(DOCKER) compose build

build-no-cache:
	$(DOCKER) compose build --no-cache

restore-db:
	# first, make sure we have all migrations run
	@$(MAKE) migrate

	# check if the file exists, otherwise download https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.sql into the /sql/ folder
	[ -f sql/restore.sql ] || wget https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.sql -O sql/restore.sql

	# copy the file to the db container
	$(DOCKER) cp sql/restore.sql database:/restore.sql

	# restore the database
	$(DOCKER) compose exec database psql -U postgres_user -d postgres_db -f ./restore.sql

	# restore sequences and indexes
	$(DOCKER) cp sql/restore-indexes-sequences.sql database:/restore-indexes-sequences.sql
	$(DOCKER) compose exec database psql -U postgres_user -d postgres_db -f ./restore-indexes-sequences.sql

	# add UNACCENT rules
	$(DOCKER) cp sql/unaccent_plus.rules database:/usr/local/share/postgresql/tsearch_data/unaccent_plus.rules
	$(DOCKER) exec -t database psql -U postgres_user -d postgres_db -c "CREATE EXTENSION unaccent;"
	$(DOCKER) exec -t database psql -U postgres_user -d postgres_db -c "ALTER TEXT SEARCH DICTIONARY unaccent (RULES='unaccent_plus')"

	# create extension pg_trgm;
	$(DOCKER) exec -t database psql -U postgres_user -d postgres_db -c "CREATE EXTENSION pg_trgm;"

up:
	$(DOCKER) compose up

stop:
	$(DOCKER) compose stop

down:
	$(DOCKER) compose down --remove-orphans

restart:
	@$(MAKE) down
	@$(MAKE) up


# Django commands
createsuperuser:
	$(DOCKER) compose exec django python manage.py createsuperuser

migrations:
	$(DOCKER) compose exec django python manage.py makemigrations

migrate:
	$(DOCKER) compose exec django python manage.py migrate $(filter-out $@,$(MAKECMDGOALS))

showmigrations:
	$(DOCKER) compose exec django python manage.py showmigrations

shell:
	$(DOCKER) compose exec django python manage.py shell

django-logs dl:
	$(DOCKER) compose logs -f django

# Node/Imba commands
npm-install ni:
	$(DOCKER) compose exec imba npm install $(filter-out $@,$(MAKECMDGOALS))

npm-run nr:
	$(DOCKER) compose exec imba npm run $(filter-out $@,$(MAKECMDGOALS))

npm-update nu:
	$(DOCKER) compose exec imba npm update $(filter-out $@,$(MAKECMDGOALS))

npm-outdated no:
	$(DOCKER) compose exec imba npm outdated $(filter-out $@,$(MAKECMDGOALS))

npm-uninstall nd:
	$(DOCKER) compose exec imba npm uninstall $(filter-out $@,$(MAKECMDGOALS))

npm-update-all nua:
	$(DOCKER) compose exec imba npx npm-check-updates -u
	$(DOCKER) compose exec imba npm i

imba-logs il:
	$(DOCKER) compose logs -f imba

enter-node en:
	$(DOCKER) compose exec imba bash

# TODO: Add commands for adding translations along with commentaries

# Ignore issues when command does not exist
%:
	@:
