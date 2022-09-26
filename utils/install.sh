#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
MAGENTA=`tput setaf 5`
BLUE=`tput setaf 4`
NC=`tput sgr0`
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
INVENV=$(python3 -c 'import sys; print ("1" if hasattr(sys, "real_prefix") else "0")');
VENV_DIR=./bs_venv

if [ -d $VENV_DIR ] && [ $INVENV == "0" ]; then
    echo "Found $VENV_DIR, activating it: "
    source $VENV_DIR/bin/activate
    echo "Activated $VENV_DIR"
else
    echo "Creating new $VENV_DIR and activating it"
    python3 -m venv $VENV_DIR && source $VENV_DIR/bin/activate;
fi
echo "Installing dependencies"
pip3 install -r requirements.txt

echo "${BOLD}${GREEN}======= Now run ${BLUE}./bluespice -h${GREEN} to see all bluespice options =======${NC}${NORMAL}"