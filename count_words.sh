#!/bin/bash
#
# Counts words in each file in current directory
# useful to figure out lists of passwords, usernames or files/folders
# in dictionaries

folder=$1
if [ -n $1 ]; then
    folder=./
fi

for f in `ls -l $folder | sort -k 3 | awk '{print $9}'`; do wc -l $f; done
echo -e "\n[+] Done."

