#!/bin/bash


## create domains/ folder
create_domains_folder() {
    mkdir domains
}


## perform sublist3r and amass enumeration on each domain passed as an argument
enumerate_domain() {
    DOMAIN=$1
    
    sublister -d $DOMAIN -o domains/$DOMAIN.sublister
    amass enum -brute -min-for-recursive 1 -d $DOMAIN -o domains/$DOMAIN.amass
    
    if [ -s domains/$DOMAIN.sublister ] || [ -s domains/$DOMAIN.amass ]; then
        cat domains/$DOMAIN.* > domains/$DOMAIN.all
        sort -u -k 1 domains/$DOMAIN.all > domains/$DOMAIN
    fi
    rm -f domains/$DOMAIN.*
}

## processing all outputed list of domains into one, removing dups
## and sorting
create_list_of_domains() {
    # concatenate and sort all domains from the target
    cat domains/*.* > domains/domains.all
    sort -u -k 1 domains/domains.all > domains/__domains.final
    rm -f domains/domains.all
}


## runs denumerator
run_denumerator() {
    denumerator -f domains/__domains.final
}


## performs nmap scan
run_nmap_scan() {
    # run nmap non-aggresive, "look around" scan with top 100 ports only, no servicediscovery, no scripts:
    nmap -Pn --top-ports 100 -T2 -i domains/__domains.final -oN domains.nmap
}


## -----------------------------------------------------------------------------

# list of domains - text file, one domain in single line
DOMAINS=$1
NMAP=$2

# enusre that domains/ folder exists
if ! [ -d 'domains' ]; then
    create_domains_folder
fi

cat $DOMAINS | while read DOMAIN
do
    enumerate_domain $DOMAIN
done

# concatenate and sort all domains from the target
create_list_of_domains
echo -e "\n[+} DONE. Found $(wc -l domains/__domains.final) unique subdomains"

# run denumerator on the domains/domains.final output file
run_denumerator

if [[ -n $NMAP ]]; then
    run_nmap_scan
fi

echo -e "\n[+} DONE."

## -----------------------------------------------------------------------------


