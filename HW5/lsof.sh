#!/bin/bash

# Simple open descriptors analyser

# Variables 

lockfile=/tmp/$0.lock

# Functions

clean_up() {
	rm -f $lockfile
	exit 255
}

usage(){
    echo "Usage: $0 [OPTION]... [FULL PATH FILENAME]..."
    echo " -f, --file           file name" 
    echo " -p, --process       process name"
    echo "Use root (sudo) for full access."
}

findFile(){
    if echo $fileName | grep -v  '^\/.*' > /dev/null; then
            echo "Error: please use full path name."
            echo
            usage
            clean_up
    fi
    sp='/-\|'
    printf ' '
    echo -n "Processing:."
    procs=`ls /proc/  | egrep "^[0-9]"`
    typeset -i i=0
    while read -r pid ; do
        if ls -l /proc/$pid/fd 2>/dev/null| awk '{print $11}' | egrep -v "socket|pipe" | grep "${fileName}$" &>/dev/null; then 
            pids[$i]="$pid"
            i+=1
        fi
        printf '\b%.1s' "$sp"
        sp=${sp#?}${sp%???}
    done <<< "$procs"
    echo
    echo "Pids of processes: ${pids[@]}"
}

findProc(){
    if [ -d /proc/$procName/fd ] ; then
        echo "Open descriptors for process $procName :"
        ls -l /proc/$procName/fd | awk '{print $11}' | sort 
    else
        echo "Error: there is no process $procName"
    fi
}

# Main

# set trap
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then
    trap clean_up SIGHUP SIGINT SIGTERM
else
    echo "Failed to acquire lockfile: $lockfile."
    echo "Held by $(cat $lockfile)"
    exit 255
fi

# check args
if [[ ! $# -eq 2  ]]; then
    usage
    clean_up
fi

case $1 in
  -p|--process) procName=$2; findProc;;
  -f|--file) fileName=$2; findFile;;
  *) usage; exit 1;;
esac;

clean_up