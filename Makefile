
# Run once only
create-network:
	docker network create web

mkcert-install:
	./mkcert/mkcert-install.sh
	@$(MAKE) certs-generate

certs-generate:
	./mkcert/mkcert-certs.sh


build:
	docker compose build

build-no-cache:
	docker compose build --no-cache

up:
	docker compose up

down:
	docker compose down --remove-orphans

restart:
	@$(MAKE) down
	@$(MAKE) up




# HELP
# ANSI escape codes for colors and styles
RESET := "\033[0m"
BOLD := "\033[1m"
UNDERLINE := "\033[4m"
GREEN := "\033[32m"
CYAN := "\033[36m"
YELLOW := "\033[33m"

help:
	@echo -e ${BOLD}Usage:${RESET}
	@echo "  make [target]"
	@echo ""
	@echo -e ${BOLD}Targets:${RESET}
	@echo -e "  "${CYAN}"create-network"${RESET}"        Create a docker network"
	@echo -e "  "${CYAN}"mkcert-install"${RESET}"        Install mkcert"
	@echo -e "  "${CYAN}"certs-generate"${RESET}"        Generate certificates"
	@echo -e "  "${CYAN}"build"${RESET}"                 Build the docker images"
	@echo -e "  "${CYAN}"build-no-cache"${RESET}"         Build the docker images without cache"
	@echo -e "  "${CYAN}"up"${RESET}"                    Start the docker containers"
	@echo -e "  "${CYAN}"down"${RESET}"                  Stop the docker containers"
	@echo -e "  "${CYAN}"restart"${RESET}"               Restart the docker containers"
	@echo -e "  "${CYAN}"help"${RESET}"                  Display this help message"
	@echo ""

# Ignore issues when command does not exist
%:
	@:
