#!/bin/bash

DOMAIN=$1

sublister -d $DOMAIN -o $DOMAIN.sublister
amass enum -brute -min-for-recursive 1 -d $DOMAIN -o $DOMAIN.amass

cat $DOMAIN.* > $DOMAIN.all
sort -u -k 1 $DOMAIN.all > $DOMAIN

rm -f $DOMAIN.*

echo -e "\n[+} DONE. Found $(wc -l $DOMAIN) unique subdomains"

