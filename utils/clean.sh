#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

if [ "$VIRTUAL_ENV" != "" ]; then
    echo "${BOLD}${RED}Exit venv first by ctrl+d or exit${NC}${NORMAL}"
else
    rm -rf venv
    find -iname "*.pyc" -delete
    echo "${BOLD}${GREEN}======= Successfully cleaned =======${NC}${NORMAL}"
fi