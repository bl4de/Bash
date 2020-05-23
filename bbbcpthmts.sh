#!/bin/bash

# bl4de's BugBounty/CTF/PenTest/Hacking multi-tool suite -> bbbcpthmts :D
# collection of various wrappers, multi-commands, tips&tricks, shortcuts etc.
# CTX: bl4de@wearehackerone.com
HACKING_HOME="/Users/bl4de/hacking"

# runs -p- against IP; then -sV -sC -A against every open port found
full_nmap_scan() {
    echo -e "[+] Running full nmap scan against $1..."
    echo -e " -> search all open ports..."
    ports=$(nmap -p- --min-rate=1000 "$1" | grep open | cut -d'/' -f 1 | tr '\n' ',')
    echo -e " -> run version detection + nse scripts against $ports..."
    nmap -p"$ports" -sV -sC -A -Pn -n "$1" -oN ./"$1".log
    echo -e "[+] Done!"
}

# runs Python 3 built-in HTTP server on [PORT]
http_server() {
    echo -e "[+] Running Simple HTTP Server in current directory on port $1"
    python3 -m http.server "$1"
}

# runs john with rockyou.txt against hash type [FORMAT] and file [HASHES]
rockyou_john() {
    echo -e "[+] Running john with rockyou dictionary against $1 of type $2"
    echo > /Users/bl4de/hacking/tools/jtr/run/john.pot
    if [[ -n $2 ]]; then
        /Users/bl4de/hacking/tools/jtr/run/john --wordlist=/Users/bl4de/hacking/dictionaries/rockyou.txt "$1" --format="$2"
        elif [[ -z $2 ]]; then
        /Users/bl4de/hacking/tools/jtr/run/john --wordlist=/Users/bl4de/hacking/dictionaries/rockyou.txt "$1"
    fi
    cat /Users/bl4de/hacking/tools/jtr/run/john.pot
}

# converts id_rsa to JTR format for cracking SSH key
ssh_to_john() {
    echo -e "[+] Converting SSH id_rsa key to JTR format to crack it"
    python /Users/bl4de/hacking/tools/jtr/run/sshng2john.py "$1" > "$1".hash
    echo -e "[+] We have a hash.\n"
    echo -e "[+] Let's now crack it!"
    rockyou_john "$1".hash
}

# static code analysis of npm module installed in ~/node_modules
# with nodestructor and semgrep
npm_scan() {
    echo -e "[+] Starting static code analysis of $1 module with nodestructor and semgrep..."
    nodestructor -r ~/node_modules/"$1" --verbose --skip-test-files
    semgrep --lang javascript --config "$HACKING_HOME"/tools/semgrep-rules/contrib/nodejsscan/ "$HOME"/node_modules/"$1"/*.js
    exitcode=$(ls "$HOME"/node_modules/"$1"/*/ >/dev/null 2>&1)
    if [ "$exitcode" == 0 ]; then
        semgrep --lang javascript --config "$HACKING_HOME"/tools/semgrep-rules/contrib/nodejsscan/ "$HOME"/node_modules/"$1"/**/*.js
    fi
    echo -e "\n\n[+]Done."
}


cmd=$1
case "$cmd" in
    full_nmap_scan)
        full_nmap_scan "$2"
    ;;
    http_server)
        http_server "$2"
    ;;
    rockyou_john)
        rockyou_john "$2" "$3"
    ;;
    ssh_to_john)
        ssh_to_john "$2"
    ;;
    npm_scan)
        npm_scan "$2"
    ;;
    *)
        echo -e "Usage: $0 {cmd} {arg1} {arg2}...{argN}\n"
        echo -e "Available commands:\n"
        echo -e ":: RECON ::"
        echo -e "\tfull_nmap_scan [IP]\t\t -> nmap -p- to enumerate ports + -sV -sC -A on found open ports"
        echo -e "\n:: TOOLS ::"
        echo -e "\thttp_server [PORT]\t\t -> runs HTTP server on [PORT] TCP port"
        echo -e "\n:: PASSWORDS CRACKIN' ::"
        echo -e "\trockyou_john [TYPE] [HASHES]\t -> runs john+rockyou against [HASHES] file with hashes of type [TYPE]"
        echo -e "\tssh_to_john [ID_RSA]\t\t -> id_rsa to JTR SSH hash file for SSH key password cracking"
        echo -e "\n:: STATIC CODE ANALYSIS ::"
        echo -e "\tnpm_scan [MODULE_NAME]\t\t -> static code analysis of MODULE_NAME npm module with nodestructor and semgrep"
        echo -e "\nHack The Planet!"
    ;;
esac
