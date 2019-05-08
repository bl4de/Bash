#!/bin/sh
# reinstall local concrete

REPO_PATH=/Library/WebServer/Documents/concrete5

echo -e "\n[+] Reinstalling local concrete5 instance..."
cd $REPO_PATH

echo -e "[+] updating files from GitHub repository..."
git pull origin develop

echo -e "[+] removing temporary files..."
rm -rf application/cache/*
rm -rf application/files/*

echo -e "[+] deleting database.php..."
cd ../config
rm -f dataabse.php

echo -e "\n[+] DONE"
