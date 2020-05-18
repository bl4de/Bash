#!/bin/bash

# bl4de's BugBounty/CTF/PenTest/Hacking multi-tool suite -> bbbcpthmts :D
# collection of various wrappers, multi-commands, tips&tricks, shortcuts etc.
# CTX: bl4de@wearehackerone.com

# runs -p- against IP; then -sV -sC -A against every open port found
full_nmap_scan() {
    echo -e "[+] Running full nmap scan against $1..."
    echo -e " -> search all open ports..."
    ports=$(nmap -p- --min-rate=1000 $1 | grep open | cut -d'/' -f 1 | tr '\n' ',')
    echo -e " -> run version detection + nse scripts against $ports..."
    nmap -p$ports -sV -sC -A -Pn -n $1 -oN ./$1.log
    echo -e "[+] Done!"
}

# runs Python 3 built-in HTTP server on [PORT]
http_server() {
    echo -e "[+] Running Simple HTTP Server in current directory on port $1"
    python3 -m http.server $1
}

# runs john with rockyou.txt against hash type [FORMAT] and file [HASHES]
rockyou_john() {
    echo -e "[+] Running john with rockyou dictionary against $2 of type $1"
    > /Users/bl4de/hacking/tools/jtr/run/john.pot
    /Users/bl4de/hacking/tools/jtr/run/john --format=$1 --wordlist=/Users/bl4de/hacking/dictionaries/rockyou.txt $2
    cat /Users/bl4de/hacking/tools/jtr/run/john.pot
}

cmd=$1
case "$cmd" in
    full_nmap_scan)
        full_nmap_scan "$2"
    ;;
    http_server)
        http_server $2
    ;;
    rockyou_john)
        rockyou_john $2 $3
    ;;
    *)
        echo -e "Usage: $0 {cmd} {arg1} {arg2}...{argN}\n"
        echo -e "Available commands:\n"
        echo -e "\tfull_nmap_scan [IP]\t\t -> nmap -p- to enumerate ports + -sV -sC -A on found open ports"
        echo -e "\thttp_server [PORT]\t\t -> runs HTTP server on [PORT] TCP port"
        echo -e "\trockyou_john [TYPE] [HASHES]\t -> runs john+rockyou against [HASHES] file with hashes of type [TYPE]"
        echo -e "\nHack The Planet!"
    ;;
esac
