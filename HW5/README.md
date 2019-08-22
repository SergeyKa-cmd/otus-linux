
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
```

File
```
$> sudo ./lsof.sh -f .123.swp
 Processing:/
Pids of processes: 18443 5432
```

Process
```
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

As we can see high priority get less(beter) time to proceed.

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

### IO concurency

Runing two vdbench test simultaneously on hard disk with next config:
```
sd=sd1,lun=/dev/sda2,openflags=o_direct
wd=bd,sd=sd*,seekpct=random,rdpct=80
rd=runbd1,wd=bd,iorate=max,elapsed=60,interval=5,threads=2,forxfersize=(8k)
```

#### Test1

As we see best-effort gives a little bit more i/o and MB/sec.

Iotop
```
Total DISK READ :       4.48 M/s | Total DISK WRITE :    1262.67 K/s
Actual DISK READ:       4.48 M/s | Actual DISK WRITE:    1303.84 K/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND                                                                           
15568 be/4 root     1146.01 K/s  253.91 K/s  0.00 % 98.23 % java -client -Xmx1024m -Xms128m -cp /home/~5 -l localhost-0 -p 5570 [IO_task /dev/sd]
15567 be/4 root     1159.73 K/s  274.49 K/s  0.00 % 98.10 % java -client -Xmx1024m -Xms128m -cp /home/~5 -l localhost-0 -p 5570 [IO_task /dev/sd]
15657 be/0 root     1139.15 K/s  281.36 K/s  0.00 % 97.75 % java -client -Xmx1024m -Xms128m -cp /home/~5 -l localhost-0 -p 5570 [IO_task /dev/sd]
15656 be/0 root     1146.01 K/s  308.80 K/s  0.00 % 97.42 % java -client -Xmx1024m -Xms128m -cp /home/~5 -l localhost-0 -p 5570 [IO_task /dev/sd]
```

High priority, class - 2 for best-effort
```
#> ionice -c 2 -n 0 ./vdbench -f ./io.test
...
22:43:48.001 Starting RD=runbd1; I/O rate: Uncontrolled MAX; elapsed=60; For loops: threads=2 xfersize=8k

Aug 21, 2019    interval        i/o   MB/sec   bytes   read     resp     read    write     read    write     resp  queue  cpu%  cpu%
                               rate  1024**2     i/o    pct     time     resp     resp      max      max   stddev  depth sys+u   sys
22:43:53.145           1      370.0     2.89    8192  80.49    5.205    6.316    0.624   177.83    24.34    7.754    1.9  18.0   4.4
...
22:44:48.027          12      480.2     3.75    8192  80.51    4.141    5.008    0.561    61.90    28.29    4.347    2.0  15.7   3.9
22:44:48.061    avg_2-12      376.8     2.94    8192  79.64    5.271    6.474    0.565   142.46   128.65    5.233    2.0  12.8   3.6
22:44:49.259 Vdbench execution completed successfully. 
```

Default priority
```
#> ./vdbench -f ./io.test 
...
22:43:46.004 Starting RD=runbd1; I/O rate: Uncontrolled MAX; elapsed=60; For loops: threads=2 xfersize=8k

Aug 21, 2019    interval        i/o   MB/sec   bytes   read     resp     read    write     read    write     resp  queue  cpu%  cpu%
                               rate  1024**2     i/o    pct     time     resp     resp      max      max   stddev  depth sys+u   sys
22:43:51.134           1      429.2     3.35    8192  80.20    4.296    5.249    0.434   381.43     5.17   13.773    1.8  20.4   4.4
...
22:44:46.027          12      357.0     2.79    8192  80.22    5.582    6.730    0.929   120.54   114.63    6.129    2.0  12.4   3.5
22:44:46.061    avg_2-12      365.5     2.86    8192  79.68    5.435    6.679    0.558   140.75   114.63    5.273    2.0  12.9   3.7
22:44:47.105 Vdbench execution completed successfully. 
```

#### Test2

But realtime dramaticaly gone wild and default priority has no chance :) 

Iotop
```
Total DISK READ :       4.09 M/s | Total DISK WRITE :    1026.83 K/s
Actual DISK READ:       4.09 M/s | Actual DISK WRITE:    1089.27 K/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND                                                                           
17002 be/4 root        6.94 K/s    0.00 B/s  0.00 % 99.99 % java -client -Xmx1024m -Xms128m -cp /home/~8 -l localhost-0 -p 5570 [IO_task /dev/sd]
17001 be/4 root        0.00 B/s    6.94 K/s  0.00 % 99.99 % java -client -Xmx1024m -Xms128m -cp /home/~8 -l localhost-0 -p 5570 [IO_task /dev/sd]
17039 rt/0 root        2.02 M/s  492.60 K/s  0.00 % 97.34 % java -client -Xmx1024m -Xms128m -cp /home/~8 -l localhost-0 -p 5570 [IO_task /dev/sd]
17040 rt/0 root        2.07 M/s  506.48 K/s  0.00 % 97.31 % java -client -Xmx1024m -Xms128m -cp /home/~8 -l localhost-0 -p 5570 [IO_task /dev/sd]
```

High priority, class - 1 for realtime
```
#> ionice -c 1 -n 0 ./vdbench -f ./io.test

22:54:02.004 Starting RD=runbd1; I/O rate: Uncontrolled MAX; elapsed=60; For loops: threads=2 xfersize=8k

Aug 21, 2019    interval        i/o   MB/sec   bytes   read     resp     read    write     read    write     resp  queue  cpu%  cpu%
                               rate  1024**2     i/o    pct     time     resp     resp      max      max   stddev  depth sys+u   sys
22:54:07.098           1      732.0     5.72    8192  80.38    2.636    3.161    0.486   181.89    26.56    4.117    1.9  11.7   3.1
...
22:55:02.038          12      679.2     5.31    8192  79.80    2.925    3.541    0.494   152.22    16.11    4.781    2.0   8.7   2.4
22:55:02.088    avg_2-12      695.2     5.43    8192  79.76    2.855    3.441    0.545   152.22   141.85    3.777    2.0   8.9   2.5
22:55:02.908 Vdbench execution completed successfully. 

```

Default priority
```
#> ./vdbench -f ./io.test 
...
22:54:02.005 Starting RD=runbd1; I/O rate: Uncontrolled MAX; elapsed=60; For loops: threads=2 xfersize=8k

Aug 21, 2019    interval        i/o   MB/sec   bytes   read     resp     read    write     read    write     resp  queue  cpu%  cpu%
                               rate  1024**2     i/o    pct     time     resp     resp      max      max   stddev  depth sys+u   sys
22:54:07.091           1        0.4     0.00    8192 100.00 1108.020 1108.020    0.000  1108.40     0.00    0.532    1.9  15.4   3.6
...
22:55:02.048          12        0.4     0.00    8192 100.00 5005.975 5005.975    0.000  5007.20     0.00    1.737    2.0   8.7   2.4
22:55:02.086    avg_2-12        0.4     0.00    8192  86.36 5000.158 5003.153 4981.190  5035.43  4997.59   18.166    2.0   8.9   2.5
22:55:03.466 Vdbench execution completed successfully. 

```

## Useful links

https://gregchapple.com/updating-ulimit-on-running-linux-process/
https://www.ibm.com/developerworks/ru/library/l-signals_1/index.html
