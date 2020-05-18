#!/bin/bash

# bl4de's BugBounty/CTF/PenTest/Hacking multi-tool suite -> bbbcpthmts :D
# collection of various wrappers, multi-commands, tips&tricks, shortcuts etc.
# CTX: bl4de@wearehackerone.com

full_nmap_scan() {
    echo -e "[+] Running full nmap scan against $1..."
    echo -e " -> search all open ports..."
    ports=$(nmap -p- --min-rate=1000 $1 | grep open | cut -d'/' -f 1 | tr '\n' ',')
    echo -e " -> run version detection + nse scripts against $ports..."
    nmap -p$ports -sV -sC -A -Pn -n $1 -oN ./$1.log
    echo -e "[+] Done!"
}

http_server() {
    echo -e "[+] Running Simple HTTP Server in current directory on port $1"
    python3 -m http.server $1
}


cmd=$1
case "$cmd" in
    full_nmap_scan)
        full_nmap_scan "$2"
    ;;
    http_server)
        http_server $2
    ;;
    
    *)
        echo "Usage: $0 {cmd} {arg1} {arg2}...{argN}"
    ;;
esac
