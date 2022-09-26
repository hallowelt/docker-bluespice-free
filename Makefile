.DEFAULT_GOAL=help
SHELL := /bin/bash

install: setup

setup: # Creates venv and install dependencies
	@if [[ "${VIRTUAL_ENV}" != *bs_venv ]]; then \
		echo "`tput setaf 2`======= installing =======`tput sgr0`" && /bin/bash --rcfile ./utils/install.sh; \
	else \
		echo "`tput setaf 5`Setup is already done, if facing problems run 'make clean' and run 'make setup' again`tput sgr0`"; \
	fi

clean: # Cleans the currently installed venv and dependencies
	@./utils/clean.sh

help: # Show this help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


