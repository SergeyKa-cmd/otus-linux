#!/bin/bash

# Simple proccess state analyser

pids=(`ls /proc | grep -E "^[0-9]+$"|sort -n`)
format="%10s %5s %5s %5s  %-20s\n"

get_users(){
    sp='/-\|'
    printf ' '
    echo -n "Processing:."
    users=`ls -l /proc/  | awk '{print $9 " " $3 }'| sed 's/\///g' |egrep "^[0-9]"`
    while read -r line ; do
        user=`echo $line | awk '{print $2}'`
        pid=`echo $line | awk '{print $1}'`
        username[$pid]=$user
        printf '\b%.1s' "$sp"
        sp=${sp#?}${sp%???}
    done <<< "$users"  
    printf "  Done.\n\n"
}

print_stat(){
    printf "$format" "UID" "PID" "PPID" "STATE" "NAME" 
    for pid in ${pids[@]}; do
        if [ -d /proc/$pid ]; then
            stats=(`cat /proc/${pid}/stat`)
            uid=`cat /proc/${pid}/loginuid`
            username=${username[$pid]}
            ppid=${stats[4]}
            state=${stats[2]}
            name=${stats[1]}
            printf "$format" $username $pid $ppid $state $name
        fi
    done   
}
 
get_users
print_stat

#echo ${pids[@]}
