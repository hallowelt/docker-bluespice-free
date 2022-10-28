.DEFAULT_GOAL=help
SHELL := /bin/bash

run: setup # Creates venv and install dependencies and activate bs_venv

setup: # Creates venv and install dependencies
	@if [[ ! -f ./.env ]]; then \
		echo "creating new .env config file"; \
		cp -f example.env .env; \
	fi
	@if [[ "${VIRTUAL_ENV}" != *bs_venv ]]; then \
		/bin/bash --rcfile ./utils/install.sh; \
	else \
		echo "`tput setaf 5`Already inside bs_venv, if facing problems run 'make clean' and run 'make setup' again`tput sgr0`"; \
	fi

clean: # Cleans the currently installed venv and dependencies
	@./utils/clean.sh

help: # Show this help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

