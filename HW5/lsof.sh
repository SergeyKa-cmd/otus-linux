#!/bin/bash

# Simple open descriptors analyser

# Functions

usage(){
    echo "Usage: $0 [OPTION]... [NAME]..."
    echo " -f, --file           file name" 
    echo " -p, --process       process name"
}

findFile(){
    sp='/-\|'
    printf ' '
    echo -n "Processing:."
    procs=`ls /proc/  | egrep "^[0-9]"`
    typeset -i i=0
    #replace dot wit slash/dot for proper grep usage
    fileName=$(sed 's/\./\\\./g' <<< $fileName)
    while read -r pid ; do
        if ls -l /proc/$pid/fd 2>/dev/null| awk '{print $11}' | egrep -v "socket|pipe" | grep "\/${fileName}$" &>/dev/null; then 
            pids[$i]="$pid"
            #echo "pid - ${pids[i]}"
            #echo "i - $i"
            i+=1
        fi
        printf '\b%.1s' "$sp"
        sp=${sp#?}${sp%???}
    done <<< "$procs"
    echo
    echo "Pids of processes: ${pids[@]}"
}

findProc(){
    #echo "Should procc? $procSet $procName"
    if [ -d /proc/$procName/fd ] ; then
        echo "Open descriptors for process $procName :"
        ls -l /proc/$procName/fd | awk '{print $11}' | sort 
    else
        echo "Error: there is no process $procName"
    fi
}

# Main

if [[ ! $# -eq 2  ]]; then
    usage
    exit 4
fi

case $1 in
  -p|--process) procName=$2; findProc;;
  -f|--file) fileName=$2; findFile;;
  *) usage; exit 1;;
esac;

