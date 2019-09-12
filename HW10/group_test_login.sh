#!/bin/bash

#Set needed GID_PERMIT for group login access on weekend 

GID_PERMIT='1004'
GID=`id -g $PAM_USER`

# for variables debug 
#env > /tmp/123
#echo $GID >> /tmp/123

if [ $(date +%a) = "Sat" ] || [$(date +%a) = "Sun" ]; then
  if [ $GID = $GID_PERMIT ]; then
      exit 0
    else 
      exit 1
  fi
fi

exit 0