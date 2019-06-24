#!/bin/bash

# list of domains - text file, one domain in single line
DOMAINS=$1

if ! [ -d 'domains' ]; then
    mkdir domains
fi

for DOMAIN in $(cat $DOMAINS)
do
    sublister -d $DOMAIN -o domains/$DOMAIN.sublister
    amass enum -brute -min-for-recursive 1 -d $DOMAIN -o domains/$DOMAIN.amass
    
    if [ -s domains/$DOMAIN.sublister ] && [ -s domains/$DOMAIN.amass ]; then
        cat domains/$DOMAIN.* > domains/$DOMAIN.all
        sort -u -k 1 domains/$DOMAIN.all > domains/$DOMAIN
    fi
    rm -f domains/$DOMAIN.*
done

# concatenate and sort all domains from the target
cat domains/*.* > domains/domains.all
sort -u -k 1 domains/domains.all > domains/domains.final

rm -f domains/domains.all
echo -e "\n[+} DONE. Found $(wc -l domains/domains.final) unique subdomains"

# run denumerator on the domains/domains.final output file
denumerator -f domains/domains.final

echo -e "\n[+} DONE."


