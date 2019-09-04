
# OTUS Linux admin course

## Systemd and SysV

### Write simple service and timer

#### Variables file 
```
[root@otuslinux vagrant]# cat  /etc/sysconfig/watchlog 
# Configuration file for my watchdog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
```

#### Service file
```
[root@otuslinux vagrant]# cat /usr/lib/systemd/system/watchlog.service 
[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```

#### Timer file
```
[root@otuslinux vagrant]# cat /usr/lib/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
```

#### Script
```
[root@otuslinux vagrant]# cat /opt/watchlog.sh 
#!/bin/bash
DATE=`date`
if grep $WORD $LOG &>/dev/null
then
logger "$DATE: I found word, Master!"
else
#logger "$DATE: word - $WORD, log - $LOG!"
exit 0
fi
```

#### Result
```
[root@otuslinux vagrant]# systemctl start watchlog.timer
[root@otuslinux vagrant]# tail /var/log/messages 
...
Aug 31 13:51:06 localhost systemd: Starting My watchlog service...
Aug 31 13:51:06 localhost root: Sat Aug 31 13:51:06 UTC 2019: I found word, Master!
Aug 31 13:51:06 localhost systemd: Started My watchlog service.

```

### Write unit files for spawn-fcgi package

#### Install
```
 yum install epel-release -y && yum install spawn-fcgi php php-cli
mod_fcgid httpd -y
```

#### Prepare config
```
[root@otuslinux vagrant]# cat /etc/sysconfig/spawn-fcgi 
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"

[root@otuslinux vagrant]# cat  /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target
```

#### Check status
```
[root@otuslinux vagrant]# systemctl start spawn-fcgi
[root@otuslinux vagrant]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-08-31 14:19:37 UTC; 5s ago
 Main PID: 6991 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─6991 /usr/bin/php-cgi

```

### Modify Apache for multiple instances

#### Edit config file
```
[root@otuslinux vagrant]# cat /usr/lib/systemd/system/httpd@.service
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I   <--------- ADD "-%I"
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
# We want systemd to give httpd some time to finish gracefully, but still want
# it to kill httpd after TimeoutStopSec if something went wrong during the
# graceful stop. Normally, Systemd sends SIGTERM signal right after the
# ExecStop, which would kill httpd. We are sending useless SIGCONT here to give
# httpd time to finish.
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target

```

#### Config files for units
```
[root@otuslinux conf]# grep OPTION /etc/sysconfig/httpd-first 
# httpd binary at startup, set OPTIONS here.
OPTIONS=-f conf/first.conf

[root@otuslinux conf]# grep OPTION /etc/sysconfig/httpd-second 
# httpd binary at startup, set OPTIONS here.
OPTIONS=-f conf/second.conf
```

#### HTTPD configs
```
[root@otuslinux conf]# cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
[root@otuslinux conf]# cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf  <---- EDIT THIS FILE AS BELLOW
[root@otuslinux conf]# egrep  "Listen|PidFile" /etc/httpd/conf/second.conf | grep -v ^#
Listen 8080
PidFile /var/run/httpd-second.pid
```

#### Result
```
[root@otuslinux conf]# systemctl start httpd@first
[root@otuslinux conf]# systemctl start httpd@second

[root@otuslinux conf]#  ss -tnulp | grep httpd
tcp    LISTEN     0      128      :::8080                 :::*                   users:(("httpd",pid=26384,fd=4),("httpd",pid=26383,fd=4),("httpd",pid=26382,fd=4),("httpd",pid=26381,fd=4),("httpd",pid=26380,fd=4),("httpd",pid=26379,fd=4))
tcp    LISTEN     0      128      :::80                   :::*                   users:(("httpd",pid=26370,fd=4),("httpd",pid=26369,fd=4),("httpd",pid=26368,fd=4),("httpd",pid=26367,fd=4),("httpd",pid=26366,fd=4),("httpd",pid=26365,fd=4))

 [root@otuslinux conf]# systemctl status httpd@first.service
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-08-31 14:45:29 UTC; 19s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 26365 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─26365 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─26366 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─26367 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─26368 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─26369 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─26370 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Aug 31 14:45:29 otuslinux systemd[1]: Starting The Apache HTTP Server...
Aug 31 14:45:29 otuslinux httpd[26365]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
Aug 31 14:45:29 otuslinux systemd[1]: Started The Apache HTTP Server.
[root@otuslinux conf]# systemctl status httpd@second.service
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-08-31 14:45:41 UTC; 13s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 26379 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─26379 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─26380 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─26381 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─26382 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─26383 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─26384 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Aug 31 14:45:41 otuslinux systemd[1]: Starting The Apache HTTP Server...
Aug 31 14:45:41 otuslinux httpd[26379]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
Aug 31 14:45:41 otuslinux systemd[1]: Started The Apache HTTP Server. 
```

#### Create systemd scripts for Jira

```
[root@otuslinux vagrant]#  wget https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.2.3-x64.bin
[root@otuslinux vagrant]# chmod +x atlassian-jira-software-7.2.3-x64.bin
[root@otuslinux vagrant]# ./atlassian-jira-software-7.2.3-x64.bin << EOF
o 1 i y EOF
[root@otuslinux vagrant]# touch /lib/systemd/system/jira.service
[root@otuslinux vagrant]# chmod 664 /lib/systemd/system/jira.service
```


#### Usefull links

http://0pointer.de/blog/projects/systemd-docs.htmleof