#!/bin/bash
# reinstall local concrete

REPO_PATH=/Library/WebServer/Documents/concrete5

echo -e "\n[+] Reinstalling local concrete5 instance..."

if [ -d $REPO_PATH ]
then
    cd $REPO_PATH

    echo -e "[+] updating files from GitHub repository..."
    git pull origin develop

    echo -e "[+] removing temporary files..."
    rm -rf $REPO_PATH/application/cache/*
    rm -rf $REPO_PATH/application/files/*

    echo -e "[+] deleting database.php..."
    cd $REPO_PATH/concrete/config
    rm -f database.php

    echo -e "\n[+] DONE"
fi
