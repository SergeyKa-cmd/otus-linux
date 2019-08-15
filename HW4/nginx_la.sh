#!/bin/bash

# Simple Nginx log analyser

#######################
# Variables

lockfile=/tmp/nla.lock
logfile=./nginx/access.log.test
errorfile=./nginx/error.log.1
resultfile=/tmp/resultfile.txt
usermail=root@localhost
shiftfile=/tmp/shiftfile
typeset -i shift=0
typeset -i filelong
hostname=`uname -n`

# you can set logrotate ON or OFF. if OFF then script try to calc shift in log file after last start
logrotate="OFF"

#######################
# Functions

clean_up() {
	rm -f $lockfile
    rm -f $resultfile
	exit 255
}

cat_logfile() {
    tail -n +$shift $logfile
}

sort_top() {
    sort \
    | uniq -c \
    | sort -nr \
    | head -10
}

get_request_ips(){
    echo ""
    echo "Top 10 Request IP's:"
    echo "===================="
    cat_logfile \
    | awk '{print $1}' \
    | sort_top
    echo ""
}

get_request_pages(){
    echo "Top 10 Request Pages:"
    echo "====================="
    cat_logfile \
    | egrep "GET.*http" \
    |  awk '{print $11}' \
    | sort_top
    echo ""
}

get_request_retcode(){
    echo "Top 10: Page Return Codes:"
    echo "=========================="
    cat_logfile\
    | awk '{print $9}' \
    | sort_top
    echo ""
}

get_errors(){
    echo "All errors:"
    echo "==========="
    cat $errorfile \
    | egrep "\[error\]"
    echo ""
}

get_shift(){
    filelong=`wc -l $logfile | awk '{print $1}'`
    if [ -f $shiftfile ]; then
        shift=`cat $shiftfile`
        if [ $shift -gt $filelong ]; then
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "Warning: Something goes wrong, starting from begin of log."
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo
            shift="0"
        else
            shift+=1
        fi
    else
        shift="0"
    fi
    echo $filelong > $shiftfile
}


#######################
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

# send all output ot file
#exec &> $resultfile

# if OFF then script try to calc shift 
if [ $logrotate == "OFF" ]; then
    get_shift
fi

echo "**************************************"
echo "*** Last hour nginx log statistics ***"
echo "**************************************"
echo "Hostname: $hostname"
echo "---------------------------------------"
# get statistics
get_request_ips
get_request_pages
get_request_retcode
get_errors

echo "Log parsed"

# send mail to recipient
#sendmail $usermail < $resultfile

# delete temp files
clean_up
