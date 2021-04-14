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

print_good(){
    t=$(date +"%I:%M %p") 
    echo "[$t] ${green}[$t] [+]${reset}" $1
}
print_error(){
    t=$(date +"%I:%M %p") 
    echo "[$t] ${red}[x]${reset}" $1
}
print_info(){
    t=$(date +"%I:%M %p") 
    echo "[$t] [*]" $1
}

potfile=$1
contents=$(cat $potfile)
IFS=":"
read -ra HASHES <<< $contents
hash=${HASHES[0]}
cleartext=${HASHES[-1]}
bssid=${HASHES[-2]}

print_good "Password found (BSSID - $blue$underline$bssid$reset) ${grey}${hash}${reset} -> ${green}[${cleartext}]${reset}"