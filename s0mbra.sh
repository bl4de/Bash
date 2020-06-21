#!/bin/bash
# shellcheck disable=SC1087
###          ###
###  S0mbra  ###
###          ###


# BugBounty/CTF/PenTest/Hacking suite 
# collection of various wrappers, multi-commands, tips&tricks, shortcuts etc.
# CTX: bl4de@wearehackerone.com

HACKING_HOME="/Users/bl4de/hacking"

GREEN='\033[1;32m'
GRAY='\033[1;30m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'

CLR='\033[0m'

__logo="
                      :PB@Bk:
                  ,jB@@B@B@B@BBL.
               7G@B@B@BMMMMMB@B@B@Nr
           :kB@B@@@MMOMOMOMOMMMM@B@B@B1,
       :5@B@B@B@BBMMOMOMOMOMOMOMM@@@B@B@BBu.
    70@@@B@B@B@BXBBOMOMOMOMOMOMMBMPB@B@B@B@B@Nr
  G@@@BJ iB@B@@  OBMOMOMOMOMOMOM@2  B@B@B. EB@B@S
  @@BM@GJBU.  iSuB@OMOMOMOMOMOMM@OU1:  .kBLM@M@B@
  B@MMB@B       7@BBMMOMOMOMOMOBB@:       B@BMM@B
  @@@B@B         7@@@MMOMOMOMM@B@:         @@B@B@
  @@OLB.          BNB@MMOMOMM@BEB          rBjM@B
  @@  @           M  OBOMOMM@q  M          .@  @@
  @@OvB           B:u@MMOMOMMBJiB          .BvM@B
  @B@B@J         0@B@MMOMOMOMB@B@u         q@@@B@
  B@MBB@v       G@@BMMMMMMMMMMMBB@5       F@BMM@B
  @BBM@BPNi   LMEB@OMMMM@B@MMOMM@BZM7   rEqB@MBB@
  B@@@BM  B@B@B  qBMOMB@B@B@BMOMBL  B@B@B  @B@B@M
   J@@@@PB@B@B@B7G@OMBB.   ,@MMM@qLB@B@@@BqB@BBv
      iGB@,i0@M@B@MMO@E  :  M@OMM@@@B@Pii@@N:
         .   B@M@B@MMM@B@B@B@MMM@@@M@B
             @B@B.i@MBB@B@B@@BM@::B@B@
             B@@@ .B@B.:@B@ :B@B  @B@O
               :0 r@B@  B@@ .@B@: P:
                   vMB :@B@ :BO7
                       ,B@B
"


# config commands
set_ip() {
    export IP="$1"
}

interactive() {
    clear
    trap '' SIGINT SIGQUIT SIGTSTP
    set_ip "$1"
    local choice
    echo "$__logo"
    echo -e "$BLUE------------------------------------------------------------------"
    echo -e "Bl4de's BugBounty/CTF/PenTest/Hacking multi-tool -> bbbcpthmts :D "
    echo -e "------------------------------------------------------------------"
    echo -e "Interactive mode\tTarget: $IP"
    echo -e "------------------------------------------------------------------"
    echo -e "[1] -> run full nmap scan + -sV -sC on open port(s) "
    echo -e "[2] -> run SMB enumeration (if port 445 is open)"
    echo -e "[3] -> run nfs scan (port 2049 open)"
    echo -e "[4] -> run nikto against HTTP server on port 80 with default plugins"
    echo -e ""
    echo -e "[0] -> Quit"
    echo -e "------------------------------------------------------------------$CLR"
    read -p "Select option:" choice
    case $choice in
        1) full_nmap_scan "$IP" ;;
        2) smb_enum "$IP" ;;
        3) nfs_enum "$IP" ;;
        4) nikto -host "$IP" -Plugins tests ;;
        0) exit ;;
        *) interactive "$IP"
    esac
}

# runs -p- against IP; then -sV -sC -A against every open port found
full_nmap_scan() {
    echo -e "$BLUE[+] Running full nmap scan against $1...$CLR"
    echo -e " -> search all open ports..."
    ports=$(nmap -p- --min-rate=1000 "$1" | grep open | cut -d'/' -f 1 | tr '\n' ',')
    echo -e " -> run version detection + nse scripts against $ports..."
    nmap -p"$ports" -sV -sC -A -Pn -n "$1" -oN ./"$1".log
    echo -e "[+] Done!"
}

# runs Python 3 built-in HTTP server on [PORT]
http_server() {
    echo -e "$BLUE[+] Running Simple HTTP Server in current directory on port $1$CLR"
    python3 -m http.server "$1"
}

# runs john with rockyou.txt against hash type [FORMAT] and file [HASHES]
rockyou_john() {
    echo -e "$BLUE[+] Running john with rockyou dictionary against $1 of type $2$CLR"
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
    echo -e "$BLUE[+] Converting SSH id_rsa key to JTR format to crack it$CLR"
    python "$HACKING_HOME"/tools/jtr/run/sshng2john.py "$1" > "$1".hash
    echo -e "$BLUE[+] We have a hash.\n"
    echo -e "$BLUE[+] Let's now crack it!"
    rockyou_john "$1".hash
}

# static code analysis of npm module installed in ~/node_modules
# with nodestructor and semgrep
npm_scan() {
    echo -e "$BLUE[+] Starting static code analysis of $1 module with nodestructor and semgrep...$CLR"
    nodestructor -r ~/node_modules/"$1" --verbose --skip-test-files
    semgrep --lang javascript --config "$HACKING_HOME"/tools/semgrep-rules/contrib/nodejsscan/ "$HOME"/node_modules/"$1"/*.js
    exitcode=$(ls "$HOME"/node_modules/"$1"/*/ >/dev/null 2>&1)
    if [ "$exitcode" == 0 ]; then
        semgrep --lang javascript --config "$HACKING_HOME"/tools/semgrep-rules/contrib/nodejsscan/ "$HOME"/node_modules/"$1"/**/*.js
    fi
    echo -e "\n\n[+]Done."
}


# static code analysis of single JavaScript code
javascript_sca() {
    echo -e "$BLUE[+] Starting static code analysis of $1 file with nodestructor and semgrep...$CLR"
    nodestructor --include-browser-patterns --include-urls "$1"
    semgrep --lang javascript --config "$HACKING_HOME"/tools/semgrep-rules/contrib/nodejsscan/ "$1"
    echo -e "\n\n[+]Done."
}

# exposes folder with Linux PrivEsc tools on localhost:9119
privesc_tools_linux() {
    cd "$HACKING_HOME"/tools/Linux-tools || exit
    echo -e "$BLUE[+] Starting HTTP server on port 9119...$CLR"
    http_server 9119
}


# exposes folder with Windows PrivEsc tools on localhost:9119
privesc_tools_linux() {
    cd "$HACKING_HOME"/tools/Windows || exit
    echo -e "$BLUE[+] Starting HTTP server on port 9119...$CLR"
    http_server 9119
}

# enumerates SMB shares on [IP] - port 445 has to be open
smb_enum() {
    echo -e "$BLUE[+] Enumerating SMB shares on $1...$CLR"
    nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse "$1"
    echo -e "\n[+] Done."
}

# if RPC on port 111 shows in rpcinfo that nfs on port 2049 is available
# we can enumerate nfs shares available:
nfs_enum() {
    echo -e "$BLUE[+] Enumerating nfs shares (TCP 2049) on $1...$CLR"
    nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount "$1"
    echo -e "\n[+] Done."
}

# checking AWS S3 bucket
s3() {
    clear
    echo -e "$BLUE[+] Checking AWS S3 $1 bucket$CLR"
    aws s3 ls "s3://$1" --no-sign-request
    if [[ "$?" == 0 ]]; then
        echo -e "\n$GREEN+ content of the bucket can be listed!$CLR"
    elif [[ "$?" != 0 ]]; then
        echo -e "\n$RED- could not list the content... :/$CLR"
    fi

    touch test.txt
    echo 'TEST' >> test.txt
    aws s3 cp test.txt "s3://$1/test.txt" --no-sign-request
    if [[ "$?" == 0 ]]; then
        echo -e "\n$GREEN+ WOW!!! We can copy files to the bucket!!! PWNed!!!$CLR"
    elif [[ "$?" != 0 ]]; then
        echo -e "\n$RED- nope, cp does not work... :/$CLR"
    fi
    rm -f test.txt

    aws s3api get-bucket-acl --bucket "$1" --no-sign-request
    if [[ "$?" == 0 ]]; then
        echo -e "\n$GREEN+  We can list ACL policies$CLR"
    elif [[ "$?" != 0 ]]; then
        echo -e "\n$RED- nope, ACL policies not readable... :/$CLR"
    fi

    aws s3api put-bucket-acl --bucket "$1" --grant-full-control emailaddress=deebiaan@gmail.com
    if [[ "$?" == 0 ]]; then
        echo -e "\n$GREEN+  We can grant full control!!! PWNed!!!$CLR"
    elif [[ "$?" != 0 ]]; then
        echo -e "\n$RED- nope, can't grant control... :/$CLR"
    fi
    echo -e "\n[+] Done."
}

cmd=$1
echo "$__logo"
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
    javascript_sca)
        javascript_sca "$2"
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
    s3)
        s3 "$2"
    ;;
    interactive)
        interactive "$2"
    ;;
    *)
        clear
        echo -e "$GREEN\nI'm guessing there's no chance we can take care of this quietly, is there? - S0mbra$CLR"
        echo -e "\n\n--------------------------------------------------------------------------------------------------------------"
        echo -e "Usage:\t$YELLOW s0mbra.sh {cmd} {arg1} {arg2}...{argN}"
        echo -e "\t s0mbra.sh interactive {IP} (interactive mode)$CLR"  # interactive -> TBD
        echo -e "\nAvailable commands:"
        echo -e "\n::$BLUE COMMANDS IN FOR INTERACTIVE MODE ::$CLR"
        echo -e "\tset_ip [IP]\t\t\t -> sets IP in current Bash session to use by other bbbcpthmts commands"
        echo -e "\n::$BLUE RECON ::$CLR"
        echo -e "\tfull_nmap_scan [IP]\t\t -> nmap -p- to enumerate ports + -sV -sC -A on found open ports"
        echo -e "\tsmb_enum [IP]\t\t\t -> enumerates SMB shares on [IP] (445 port has to be open)"
        echo -e "\tnfs_enum [IP]\t\t\t -> enumerates nfs shares on [IP] (2049 port has to be open/listed in rpcinfo)"
        echo -e "\ts3 [bucket]\t\t\t -> checks privileges on AWS S3 bucket (ls, cp, mv etc.)"
        echo -e "\n::$BLUE TOOLS ::$CLR"
        echo -e "\thttp_server [PORT]\t\t -> runs HTTP server on [PORT] TCP port"
        echo -e "\tprivesc_tools_linux \t\t -> runs HTTP server on port 9119 in directory with Linux PrivEsc tools"
        echo -e "\tprivesc_tools_windows \t\t -> runs HTTP server on port 9119 in directory with Windows PrivEsc tools"
        echo -e "\n::$BLUE PASSWORDS CRACKIN' ::$CLR"
        echo -e "\trockyou_john [TYPE] [HASHES]\t -> runs john+rockyou against [HASHES] file with hashes of type [TYPE]"
        echo -e "\tssh_to_john [ID_RSA]\t\t -> id_rsa to JTR SSH hash file for SSH key password cracking"
        echo -e "\n::$BLUE STATIC CODE ANALYSIS ::$CLR"
        echo -e "\tnpm_scan [MODULE_NAME]\t\t -> static code analysis of MODULE_NAME npm module with nodestructor and semgrep"
        echo -e "\tjavascript_sca [FILE_NAME]\t -> static code analysis of single JavaScript file with nodestructor and semgrep"
        echo -e "\n\n--------------------------------------------------------------------------------------------------------------"
        echo -e "$GREEN\nHack The Planet!\n$CLR"
    ;;
esac
