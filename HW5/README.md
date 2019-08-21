
# OTUS Linux admin course

## Processes and threads 

### Script for analyse proc FS.

Some simple script [ps.sh](ps.sh) for analysing proccesses.

Example of usage:
```
$> ./ps.sh
 Processing:|  Done.

       UID   PID  PPID STATE  NAME                
      root     1     1     S  (systemd)           
      root     2     0     S  (kthreadd)          
      root     4     0     I  (kworker/0:0H)      
      root     6     0     I  (mm_percpu_wq)      
      root     7     0     S  (ksoftirqd/0)       
      root     8     0     I  (rcu_sched)         
      root     9     0     I  (rcu_bh)            
      root    10     0     S  (migration/0)       

```

Trap example:
```
$> ./ps.sh | head
Failed to acquire lockfile: /tmp/./ps.sh.lock.
Held by 24248
```

### Script to see open files or process

Some simple script [lsof.sh](lsof.sh) for view open descriptors or which process open file.

Example of usage:
```
$> ./lsof.sh 
Usage: ./lsof.sh [OPTION]... [NAME]...
 -f, --file           file name
 -p, --process       process name

$> sudo ./lsof.sh -f .123.swp
 Processing:/
Pids of processes: 18443 5432


$> sudo ./lsof.sh -p $$
Open descriptors for process 8857 :

anon_inode:[eventpoll]
/dev/pts/0
/dev/shm/.org.chromium.Chromium.08PZxz
/dev/shm/.org.chromium.Chromium.2VeiNB
/dev/shm/.org.chromium.Chromium.3DLVza
...
socket:[77436]
socket:[82185]
/usr/share/code/chrome_100_percent.pak
/usr/share/code/chrome_200_percent.pak
...
```

## Stress tests

### Processor concurency

We have 8 cpu, so try run two script [stress.sh](stress.sh)  (high and low priority) simultaneously by clusterssh, and run 6 proccess `yes > /dev/nul`.

```
top - 16:48:40 up 20 min,  3 users,  load average: 7,97, 3,75, 1,89
Tasks: 439 total,   9 running, 355 sleeping,   0 stopped,   0 zombie
%Cpu(s): 49,8 us, 38,5 sy, 11,6 ni,  0,0 id,  0,0 wa,  0,0 hi,  0,0 si,  0,0 st
KiB Mem : 16319876 total,  9603244 free,  3510632 used,  3206000 buff/cache
KiB Swap:  1003516 total,  1003516 free,        0 used. 11758924 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND     
 8019 root      20   0   14576    796    732 R 100,0  0,0   1:40.20 yes         
 8024 root      20   0   14576    792    732 R 100,0  0,0   1:38.17 yes         
 8013 root      20   0   14576    776    716 R 100,0  0,0   1:53.12 yes         
 7996 root      20   0   14576    788    724 R  99,3  0,0   2:10.66 yes         
 8003 root      20   0   14576    732    672 R  98,0  0,0   2:06.59 yes         
 8008 root      20   0   14576    740    676 R  97,4  0,0   2:00.53 yes         
 7944 root       0 -20   13956   7724   1352 R  94,7  0,0   2:40.42 bzip2       
 7943 root      39  19   13956   7776   1404 R  92,8  0,0   2:26.36 bzip2       
 7942 root       0 -20   14620    924    860 S   4,9  0,0   0:09.94 dd          
 7941 root      39  19   14620    888    824 S   4,3  0,0   0:08.71 dd          
 5521 alf       20   0   41304   5568   3880 S   3,0  0,0   0:21.42 htop      
```

As we can see high priority get less time to proceed.

High priority
```
#> time nice -n -20 ./stress.sh
2000000+0 records in
2000000+0 records out
1024000000 bytes (1,0 GB, 977 MiB) copied, 279,616 s, 3,7 MB/s

real    4m39,828s
user    4m27,712s
sys     0m14,995s
```


Low priority 
```
#> time nice -n 20 ./stress.sh
2000000+0 records in
2000000+0 records out
1024000000 bytes (1,0 GB, 977 MiB) copied, 301,383 s, 3,4 MB/s

real    5m1,515s
user    4m30,451s
sys     0m14,820s

```

## Useful links

