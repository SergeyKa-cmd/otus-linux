
# OTUS Linux admin course

## Processes and threads 

### Script for analyse proc FS.

Some simple script for analysing proccesses.

Script [ps.sh](ps.sh)

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

Some simple script for view open descriptors or which process open file

Script [lsof.sh](lsof.sh)

Example of usage:
```
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

## Useful links

