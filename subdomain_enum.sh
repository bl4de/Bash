#!/bin/bash

# list of domains - text file, one domain in single line
DOMAINS=$1
NMAP=$2

if ! [ -d 'domains' ]; then
    mkdir domains
fi

for DOMAIN in $(cat $DOMAINS)
do
    sublister -d $DOMAIN -o domains/$DOMAIN.sublister
    amass enum -brute -min-for-recursive 1 -d $DOMAIN -o domains/$DOMAIN.amass
    
    if [ -s domains/$DOMAIN.sublister ] || [ -s domains/$DOMAIN.amass ]; then
        cat domains/$DOMAIN.* > domains/$DOMAIN.all
        sort -u -k 1 domains/$DOMAIN.all > domains/$DOMAIN
    fi
    rm -f domains/$DOMAIN.*
done

# concatenate and sort all domains from the target
cat domains/*.* > domains/domains.all
sort -u -k 1 domains/domains.all > domains/__domains.final

rm -f domains/domains.all
echo -e "\n[+} DONE. Found $(wc -l domains/__domains.final) unique subdomains"

# run denumerator on the domains/domains.final output file
denumerator -f domains/__domains.final

if [[ -n $NMAP ]]; then
    # run nmap non-aggresive, "look around" scan with top 100 ports only, no servicediscovery, no scripts:
    nmap -Pn --top-ports 100 -T2 -i domains/__domains.final -oN domains.nmap
fi

echo -e "\n[+} DONE."


