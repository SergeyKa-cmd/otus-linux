
# OTUS Linux admin course

## NFS SMB FTP

### How to use this repo

Clone repo, run `vagrant up`. You'l get two machines `nfsserver` and `client`.

### Stend config

#### Check nfsserver

* Nfs shares
```
[root@nfsserver vagrant]# showmount -e
Export list for nfsserver:
/var/nfs_share client
```

#### Check client

* Nfs mounts
```
[root@client upload]# showmount -e nfsserver
Export list for nfsserver:
/var/nfs_share client

[root@client upload]# mount | grep nfsserver
/etc/auto.master.d/auto.nfs on /mnt/nfsserver type autofs (rw,relatime,fd=17,pgrp=5510,timeout=600,minproto=5,maxproto=5,indirect,pipe_ino=32332)
nfsserver:/var/nfs_share on /mnt/nfsserver/public type nfs (rw,nosuid,noexec,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,soft,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.10.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.10.10)
```

* Automount
```
[vagrant@client ~]$ cd /mnt/nfsserver/public
[vagrant@client public]$ ls
upload
[vagrant@client public]$ cd upload/
[vagrant@client upload]$ mkdir testfolder
[vagrant@client upload]$ echo "test" > testfolder/testfile
[vagrant@client upload]$ ls -la testfolder/
total 4
drwxrwxr-x. 2 vagrant vagrant 22 Dec 27 17:25 .
drwxrwxrwx. 3 root    root    24 Dec 27 17:25 ..
-rw-rw-r--. 1 vagrant vagrant  5 Dec 27 17:25 testfile
[vagrant@client upload]$ df -hT
Filesystem               Type      Size  Used Avail Use% Mounted on
/dev/sda1                xfs        40G  2.9G   38G   8% /
devtmpfs                 devtmpfs  236M     0  236M   0% /dev
tmpfs                    tmpfs     244M     0  244M   0% /dev/shm
tmpfs                    tmpfs     244M  4.5M  240M   2% /run
tmpfs                    tmpfs     244M     0  244M   0% /sys/fs/cgroup
tmpfs                    tmpfs      49M     0   49M   0% /run/user/1000
nfsserver:/var/nfs_share nfs        40G  2.8G   38G   7% /mnt/nfsserver/public
```

* Root_squash
```
[vagrant@client upload]$  sudo su
[root@client upload]# touch testfile2
[root@client upload]# ls -la
total 0
drwxrwxrwx. 3 root      root      41 Dec 27 17:25 .
dr-xr-xr-x. 3 root      root      20 Dec 27 17:18 ..
-rw-r--r--. 1 nfsnobody nfsnobody  0 Dec 27 17:25 testfile2
drwxrwxr-x. 2 vagrant   vagrant   22 Dec 27 17:25 testfolder
```

### Useful links

http://nfs.sourceforge.net/

https://technet.microsoft.com/ru-ru/jj680665.aspx

http://www.bog.pp.ru/work/NFS.html#mount

https://otus.ru/media/dc/1a/dell_nfs_server-5373-dc1a63.pdf