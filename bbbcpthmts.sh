#!/bin/bash

# bl4de's BugBounty/CTF/PenTest/Hacking multi-tool suite -> bbbcpthmts :D
# collection of various wrappers, multi-commands, tips&tricks, shortcuts etc.
# CTX: bl4de@wearehackerone.com
HACKING_HOME="/Users/bl4de/hacking"

# config commands
set_ip() {
    export IP="$1"
}

interactive() {
    set_ip "$1"
    local choice
    echo -e "--------------------------------------------------"
    echo -e "Interactive mode\tTarget: $IP"
    echo -e "--------------------------------------------------"
    echo -e "[1] -> run full nmap scan + -sV -sC on open port(s) "
    echo -e "[2] -> run SMB enumeration (if port 445 is open)"
    echo -e "[3] -> run nfs scan (port 2049 open)"
    echo -e "--------------------------------------------------"
    read -p "Select option: " choice
    case $choice in
        1) full_nmap_scan "$IP" ;;
        2) smb_enum "$IP" ;;
        3) nfs_enum "$IP" 0;;
        *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
}

# runs -p- against IP; then -sV -sC -A against every open port found
full_nmap_scan() {
    echo -e "[+] Running full nmap scan against $IP..."
    echo -e " -> search all open ports..."
    ports=$(nmap -p- --min-rate=1000 "$IP" | grep open | cut -d'/' -f 1 | tr '\n' ',')
    echo -e " -> run version detection + nse scripts against $ports..."
    nmap -p"$ports" -sV -sC -A -Pn -n "$IP" -oN ./"$IP".log
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
    echo > "$HACKING_HOME"/tools/jtr/run/john.pot
    if [[ -n $2 ]]; then
        "$HACKING_HOME"/tools/jtr/run/john --wordlist="$HACKING_HOME"/dictionaries/rockyou.txt "$1" --format="$2"
        elif [[ -z $2 ]]; then
        "$HACKING_HOME"/tools/jtr/run/john --wordlist="$HACKING_HOME"/dictionaries/rockyou.txt "$1"
    fi
    cat "$HACKING_HOME"/tools/jtr/run/john.pot
}

# converts id_rsa to JTR format for cracking SSH key
ssh_to_john() {
    echo -e "[+] Converting SSH id_rsa key to JTR format to crack it"
    python "$HACKING_HOME"/tools/jtr/run/sshng2john.py "$1" > "$1".hash
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

# exposes folder with Linux PrivEsc tools on localhost:9119
privesc_tools_linux() {
    cd "$HACKING_HOME"/tools/Linux-tools || exit
    echo -e "[+] Starting HTTP server on port 9119..."
    http_server 9119
}


# exposes folder with Windows PrivEsc tools on localhost:9119
privesc_tools_linux() {
    cd "$HACKING_HOME"/tools/Windows || exit
    echo -e "[+] Starting HTTP server on port 9119..."
    http_server 9119
}

# enumerates SMB shares on [IP] - port 445 has to be open
smb_enum() {
    echo -e "[+] Enumerating SMB shares on $IP..."
    nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse "$IP"
    echo -e "\n[+] Done."
}

# if RPC on port 111 shows in rpcinfo that nfs on port 2049 is available
# we can enumerate nfs shares available:
nfs_enum() {
    echo -e "[+] Enumerating nfs shares (TCP 2049) on $IP..."
    nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount "$IP"
    echo -e "\n[+] Done."
}

cmd=$1
case "$cmd" in
    set_ip)
        set_ip "$2"
    ;;
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
    privesc_tools_linux)
        privesc_tools_linux
    ;;
    privesc_tools_windows)
        privesc_tools_windows
    ;;
    smb_enum)
        smb_enum "$2"
    ;;
    nfs_enum)
        nfs_enum "$2"
    ;;
    interactive)
        interactive "$2"
    ;;
    *)
        echo -e "Usage:\t bbbcpthmts.sh {cmd} {arg1} {arg2}...{argN}"
        echo -e "\t bbbcpthmts.sh interactive {IP} (interactive mode)"  # interactive -> TBD
        echo -e "\nAvailable commands:"
        echo -e "\n:: COMMANDS IN FOR INTERACTIVE MODE ::"
        echo -e "\tset_ip [IP]\t\t -> sets IP in current Bash session to use by other bbbcpthmts commands"
        echo -e "\n:: RECON ::"
        echo -e "\tfull_nmap_scan [IP]\t\t -> nmap -p- to enumerate ports + -sV -sC -A on found open ports"
        echo -e "\tsmb_enum [IP]\t\t -> enumerates SMB shares on [IP] (445 port has to be open)"
        echo -e "\tnfs_enum [IP]\t\t -> enumerates nfs shares on [IP] (2049 port has to be open/listed in rpcinfo)"
        echo -e "\n:: TOOLS ::"
        echo -e "\thttp_server [PORT]\t\t -> runs HTTP server on [PORT] TCP port"
        echo -e "\tprivesc_tools_linux \t\t -> runs HTTP server on port 9119 in directory with Linux PrivEsc tools"
        echo -e "\tprivesc_tools_windows \t\t -> runs HTTP server on port 9119 in directory with Windows PrivEsc tools"
        echo -e "\n:: PASSWORDS CRACKIN' ::"
        echo -e "\trockyou_john [TYPE] [HASHES]\t -> runs john+rockyou against [HASHES] file with hashes of type [TYPE]"
        echo -e "\tssh_to_john [ID_RSA]\t\t -> id_rsa to JTR SSH hash file for SSH key password cracking"
        echo -e "\n:: STATIC CODE ANALYSIS ::"
        echo -e "\tnpm_scan [MODULE_NAME]\t\t -> static code analysis of MODULE_NAME npm module with nodestructor and semgrep"
        echo -e "\nHack The Planet!"
    ;;
esac
