#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
grey=`tput setaf 8`
reset=`tput sgr0`
bold=`tput bold`
underline=`tput smul`

l="${red}< * >${reset}"

random_string() {
        local l=15
	[ -n "$1" ] && l=$1
        [ -n "$2" ] && l=$(shuf --random-source=/dev/urandom -i $1-$2 -n 1)
      	tr -dc A-Za-z0-9 < /dev/urandom | head -c ${l} | xargs
}

port=$(shuf --random-source=/dev/urandom -i 4444-9999 -n 1)
password=$(random_string)
workload="2"
outfile="cracked_hashes.txt"
potfile="cracked.pot"
ip_local=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
ip_global=`curl -s http://whatismyip.akamai.com/`
server_ip=$ip_local

print_good(){
    echo "${green}[+]${reset}" $1
}
print_error(){
    echo "${red}[x]${reset}" $1
}
print_info(){
    echo "[*]" $1
}

files_init(){
    touch $potfile
    touch $outfile
    cp watcher.sh /usr/bin/
}

watch_potfile(){
    ls $potfile|entr -p watcher.sh /_
}

generate_client(){
    sed "s/PORT/$port/" client_template.sh|sed "s/IP/$server_ip/"|sed "s/WORKLOAD/$workload/"|sed "s/POTFILE/$potfile/"|sed "s/OUTFILE/$outfile/"|sed "s/PASSWORD/$password/" > airstrike_client.sh
    chmod +x airstrike_client.sh
}

start_server(){
    hashcat --force --brain-server --brain-host $server_ip --brain-port $port --brain-password $password > /dev/null 2>&1 &

    server_start_status="$?"
}

print_summary(){
    echo
    print_info "Using default output   $green->$reset $bold$outfile$reset"
    print_info "Using default potfile  $green->$reset $bold$potfile$reset"
    echo
    print_info "Generated client-side handshake capturer (${bold}client.sh${reset})"
    if [ "$server_start_status" = "0" ]; then
        echo
        print_good "Started server on port $magenta$port$reset ($server_ip)"
    else
        echo
        print_error "Cannot start server - exit code $red$server_start_status$reset"
    fi
    echo
}


print_banner(){
echo """		        
$red
 | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
 | . A . i . r   S . t . r . i . k . e . |
 | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
$reset
"""
}

print_usage(){
print_banner
echo "Created by: redcodelabs.io $l"
echo
echo "usage: airstrike_server.sh [-h] [-p <port>] [-g] [-x]"
echo
echo "options:"
echo " -h	        Show help message and exit"
echo " -p <port>    Port to start Brain server on     (default: ${green}random${reset})" 
echo " -g           Start server on global IP address (default: ${green}local${reset})"
echo " -x           Use extreme workload              (default: ${green}moderate${reset})"
echo
echo
}

while getopts "hgp:" opt; do
    case "$opt" in
    h)
        print_usage
        exit 0
        ;;
    g)  server_ip=$ip_global
        ;;
    p)  port=$OPTARG
        ;;
    x)  workload="4"
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

print_banner
generate_client
files_init
start_server 
print_summary &
watch_potfile &