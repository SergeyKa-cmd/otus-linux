
# OTUS Linux admin course

## Security (AAA)
 
### Usage

Clone this repo, run `vagrant up` and you`ll get virtualbox machinea and 3 local user added for testing purposes.

### PAM

#### Module pam_time

Add to `/etc/security/time.conf` Format`service;terminal;user;time`
```
*;*;day;Al0800-2000
*;*;night;!Al0800-2000
*;*;friday;Fr
```


Edit `/etc/pam.d/sshd`to get
```
...
account required pam_nologin.so
account required pam_time.so
...
```

#### Module pam_exec

Edit `/etc/pam.d/sshd`to get
```
...
account required pam_nologin.so
account required pam_exec.so /usr/local/bin/test_login.sh
...
```

[Script test_login.sh](test_login.sh)

#### Module pam_script

Install `for pkg in epel-release pam_script; do yum install -y $pkg; done`

Edit `/etc/pam.d/sshd`to get
```
...
account required pam_nologin.so
account required pam_scrip.so /usr/local/bin/test_login.sh
...
```

#### Module pam_cap

Need to install `yum install -y nmap-ncat`

SElinux off `sudo setenforce 0`

Edit `/etc/pam.d/sshd`to get
```
...
account required pam_nologin.so
auth required pam_cap.so
...
```

Run `echo `cap_net_bind_service day` >>/etc/security/capability.conf`

Add rights `sudo setcap cap_net_bind_service=+ep /usr/bin/ncat`

Now check
```
[day@nginx ~]$ ncat -l -p 80
Make Linux great again
```

```
[root@nginx vagrant]# echo "Make Linux great again" > /dev/tcp/127.0.0.7/80
```

### Admin rights

#### Sudoers

Add user to group `wheel` by `usermod -G wheel day` and get root rights
```
[day@nginx ~]$ sudo -i
[sudo] password for day: 
[root@nginx ~]# 
```

Or you can write in `/etc/sudoers`
```
day ALL=(ALL) ALL
or
day ALL=(ALL) NOPASSWD: ALL
```

Also you can use `/etc/sudoers.d/day` it`s more flexible.

### HW tasks

#### Restrict access on weekend for all except some group

Edit `/etc/pam.d/sshd`to get
```
...
account required pam_nologin.so
account required pam_exec.so /usr/local/bin/group_test_login.sh
...
```

[Script group_test_login.sh](group_test_login.sh)


#### Add sudo for user

Add to `/etc/sudoers` by using `visudo`
```
day ALL=(ALL) NOPASSWD: ALL
```

Check permitions
```
[day@nginx ~]$ sudo -l
...

User day may run the following commands on nginx:
    (ALL) ALL
    (ALL) NOPASSWD: ALL
```

### Usefull links

https://medium.com/information-and-technology/wtf-is-pam-99a16c80ac57

https://gitlab.com/apparmor/apparmor/wikis/QuickProfileLanguage

http://rus-linux.net/MyLDP/sec/PolicyKit_pr2.html

http://www.linux-pam.org/Linux-PAM-html/

https://ru.bmstu.wiki/Polkit

https://lwn.net/Articles/486306/

https://www.opennet.ru/base/net/pam_linux.txt.html

https://otus.ru/media/96/64/Linux_PAM_SAG-4560-966489.pdf

https://www.systutorials.com/docs/linux/man/8-pam_time/

https://linux.die.net/man/5/pam_script