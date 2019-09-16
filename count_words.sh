#!/bin/bash
#
# Counts words in each file in current directory
# useful to figure out lists of passwords, usernames or files/folders
# in dictionaries
echo -e "\nusage:\n./count_words.sh [EXTENSION] [FOLDER]"
echo -e "\n- if EXTENSION is not passed, txt is default"
echo -e "- if folder is not passed, current folder is default\n\n"


folder=$2
extension=$1

if [ -n $2 ]; then
    folder=.
fi

if [ -n $1 ]; then
    extension=txt
fi

for f in `ls -l $folder/*.$extension | sort -k 3 | awk '{print $9}'`; do wc -l $f; done
echo -e "\n[+] Done."

