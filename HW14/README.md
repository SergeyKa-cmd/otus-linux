
# OTUS Linux admin course

## Backup (Bacula)

### How to use this repo

Clone repo. Use `vagrant up` for create VM of bacula server and client. 

Gendalf - bacula server

Bilbo - bacula client

### Backula

#### Server installation

##### Ubuntu
```
$ sudo vi /etc/bacula/bacula-dir.conf    <--- see conf  mentioned bellow
$ sudo vi /etc/bacula/bacula-sd.conf
$ sudo bacula-dir /etc/bacula/bacula-dir.conf
$ sudo bacula-sd /etc/bacula/bacula-sd.conf
$ sudo systemctl status bacula-director.service
```

Edit `/etc/bacula/bacula-dir.conf` like [bacula-dir.conf](bacula-servert/bacula-dir.conf)
Edit `/etc/bacula/bacula-sd.conf` like [bacula-sd.conf](bacula-server/bacula-sd.conf)

###### Centos7 (tried to run but have some problem, so better use ubuntu)
```
$ sudo systemctl start mariadb
$ /usr/libexec/bacula/grant_mysql_privileges
$ /usr/libexec/bacula/create_mysql_database -u root
$ /usr/libexec/bacula/make_mysql_tables -u bacula
$ sudo mysql_secure_installation
$ mysql -u root -p
MariaDB [(none)]> UPDATE mysql.user SET Password=PASSWORD('bacula_db_password') WHERE User='bacula';
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> exit
$ sudo systemctl enable mariadb
$ sudo alternatives --config libbaccats.so   <--- select 1 mysql
$ sudo mkdir -p /bacula/backup /bacula/restore
$ sudo chown -R bacula:bacula /bacula
$ sudo chmod -R 700 /bacula
$ sudo vi /etc/bacula/bacula-dir.conf    <--- see conf in file bacula-dir.conf
$ sudo bacula-dir /etc/bacula/bacula-dir.conf
$ sudo bacula-sd /etc/bacula/bacula-sd.conf
$ sudo systemctl status bacula-dir.service
```

#### Client installation

##### Ubuntu
```
$ sudo apt-get update
$ sudo apt-get install bacula-client
$ sudo vi /etc/bacula/bacula-fd.conf    <--- see conf bellow
$ sudo bacula-fd /etc/bacula/bacula-fd.conf
$ sudo service bacula-fd restart
$ sudo mkdir -p /bacula/restore
$ sudo chown -R bacula:bacula /bacula
$ sudo chmod -R 700 /bacula
```

Edit `/etc/bacula/bacula-fd.conf` like [bacula-fd.conf](bacula-client/bacula-fd.conf)


### Bacula operations

#### Test connection to client

```
root@gendalf:~# bconsole 
Connecting to Director localhost:9101
1000 OK: 1 gendalf-dir Version: 7.0.5 (28 July 2014)
Enter a period to cancel a command.
*status
Status available for:
     1: Director
     2: Storage
     3: Client
     4: Scheduled
     5: All
Select daemon type for status (1-5): 3
The defined Client resources are:
     1: gendalf-fd
     2: bilbo-fd
Select Client (File daemon) resource (1-2): 2
Connecting to Client bilbo-fd at 192.168.50.20:9102

bilbo-fd Version: 7.0.5 (28 July 2014)  x86_64-pc-linux-gnu ubuntu 16.04
Daemon started 29-Sep-19 17:41. Jobs: run=0 running=0.
 Heap: heap=172,032 smbytes=187,678 max_bytes=187,825 bufs=53 max_bufs=54
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s

Running Jobs:
Director connected at: 29-Sep-19 17:41
No Jobs running.
====

Terminated Jobs:
====
You have messages.
*
```

#### Bacula console `bconsole`

##### Help
```
root@gendalf:~# bconsole 
Connecting to Director localhost:9101
1000 OK: 1 gendalf-dir Version: 7.0.5 (28 July 2014)
Enter a period to cancel a command.
*help
  Command       Description
  =======       ===========
  add           Add media to a pool
  autodisplay   Autodisplay console messages
  automount     Automount after label
  cancel        Cancel a job
  create        Create DB Pool from resource
  delete        Delete volume, pool or job
  disable       Disable a job, attributes batch process
  enable        Enable a job, attributes batch process
  estimate      Performs FileSet estimate, listing gives full listing
  exit          Terminate Bconsole session
  gui           Non-interactive gui mode
  help          Print help on specific command
  label         Label a tape
  list          List objects from catalog
  llist         Full or long list like list command
  messages      Display pending messages
  memory        Print current memory usage
  mount         Mount storage
  prune         Prune expired records from catalog
  purge         Purge records from catalog
  quit          Terminate Bconsole session
  query         Query catalog
  restore       Restore files
  relabel       Relabel a tape
  release       Release storage
  reload        Reload conf file
  run           Run a job
  status        Report status
  stop          Stop a job
  setdebug      Sets debug level
  setbandwidth  Sets bandwidth
  setip         Sets new client address -- if authorized
  show          Show resource records
  sqlquery      Use SQL to query catalog
  time          Print current time
  trace         Turn on/off trace to file
  truncate      Truncate one or more Volumes
  unmount       Unmount storage
  umount        Umount - for old-time Unix guys, see unmount
  update        Update volume, pool or stats
  use           Use catalog xxx
  var           Does variable expansion
  version       Print Director version
  wait          Wait until no jobs are running

When at a prompt, entering a period cancels the command.
```
##### Run backup
```
root@gendalf:~# bconsole 
Connecting to Director localhost:9101
1000 OK: 1 gendalf-dir Version: 7.0.5 (28 July 2014)
Enter a period to cancel a command.
*run
Automatically selected Catalog: MyCatalog
Using Catalog "MyCatalog"
A job name must be specified.
The defined Job resources are:
     1: LocalBackup
     2: BilboRemoteBackup
     3: RestoreRemote
     4: BackupCatalog
     5: RestoreFiles
Select Job resource (1-5): 2
Run Backup job
JobName:  BilboRemoteBackup
Level:    Incremental
Client:   bilbo-fd
FileSet:  bilbo etc
Pool:     File (From Job resource)
Storage:  File (From Job resource)
When:     2019-09-30 18:50:01
Priority: 10
OK to run? (yes/mod/no): yes
Job queued. JobId=92
You have messages.

root@gendalf:~# ll -h /srv/backup/backupstorage/Vol-0003 
-rw-r----- 1 bacula tape 980K Sep 30 18:50 /srv/backup/backupstorage/Vol-0003
root@gendalf:~# file /srv/backup/backupstorage/Vol-0003
/srv/backup/backupstorage/Vol-0003: Bacula volume, started Mon Sep 30 09:03:14 2019
```

##### Restore backup 
```
root@gendalf:~# bconsole 
Connecting to Director localhost:9101
1000 OK: 1 gendalf-dir Version: 7.0.5 (28 July 2014)
Enter a period to cancel a command.
*restore
Automatically selected Catalog: MyCatalog
Using Catalog "MyCatalog"

First you select one or more JobIds that contain files
to be restored. You will be presented several methods
of specifying the JobIds. Then you will be allowed to
select which files from those JobIds are to be restored.

To select the JobIds, you have the following choices:
     1: List last 20 Jobs run
     2: List Jobs where a given File is saved
     3: Enter list of comma separated JobIds to select
     4: Enter SQL list command
     5: Select the most recent backup for a client
     6: Select backup for a client before a specified time
     7: Enter a list of files to restore
     8: Enter a list of files to restore before a specified time
     9: Find the JobIds of the most recent backup for a client
    10: Find the JobIds for a backup for a client before a specified time
    11: Enter a list of directories to restore for found JobIds
    12: Select full restore to a specified Job date
    13: Cancel
1
+-------+----------+---------------------+----------+----------+----------+
| JobId | Client   | StartTime           | JobLevel | JobFiles | JobBytes |
+-------+----------+---------------------+----------+----------+----------+
| 92    | bilbo-fd | 2019-09-30 18:50:15 | I        | 0        | 0        |
| 91    | bilbo-fd | 2019-09-30 18:50:03 | I        | 0        | 0        |
| 90    | bilbo-fd | 2019-09-30 18:40:02 | I        | 0        | 0        |
| 89    | bilbo-fd | 2019-09-30 18:30:12 | D        | 1        | 0        |
| 88    | bilbo-fd | 2019-09-30 18:30:00 | I        | 0        | 0        |
| 87    | bilbo-fd | 2019-09-30 18:20:02 | I        | 0        | 0        |
| 86    | bilbo-fd | 2019-09-30 18:10:19 | I        | 0        | 0        |
| 85    | bilbo-fd | 2019-09-30 17:20:02 | I        | 1        | 0        |
| 81    | bilbo-fd | 2019-09-30 17:10:02 | I        | 0        | 0        |
| 80    | bilbo-fd | 2019-09-30 17:00:12 | D        | 2        | 37       |
| 79    | bilbo-fd | 2019-09-30 17:00:00 | I        | 0        | 0        |
| 78    | bilbo-fd | 2019-09-30 14:10:03 | I        | 0        | 0        |
| 77    | bilbo-fd | 2019-09-30 14:00:13 | D        | 2        | 37       |
| 76    | bilbo-fd | 2019-09-30 14:00:01 | I        | 0        | 0        |
| 75    | bilbo-fd | 2019-09-30 13:50:03 | I        | 0        | 0        |
| 74    | bilbo-fd | 2019-09-30 13:40:03 | I        | 0        | 0        |
| 73    | bilbo-fd | 2019-09-30 13:30:12 | D        | 2        | 37       |
| 72    | bilbo-fd | 2019-09-30 13:30:01 | I        | 0        | 0        |
| 71    | bilbo-fd | 2019-09-30 13:20:02 | I        | 0        | 0        |
| 70    | bilbo-fd | 2019-09-30 13:10:02 | I        | 0        | 0        |
+-------+----------+---------------------+----------+----------+----------+
To select the JobIds, you have the following choices:
     1: List last 20 Jobs run
     2: List Jobs where a given File is saved
     3: Enter list of comma separated JobIds to select
     4: Enter SQL list command
     5: Select the most recent backup for a client
     6: Select backup for a client before a specified time
     7: Enter a list of files to restore
     8: Enter a list of files to restore before a specified time
     9: Find the JobIds of the most recent backup for a client
    10: Find the JobIds for a backup for a client before a specified time
    11: Enter a list of directories to restore for found JobIds
    12: Select full restore to a specified Job date
    13: Cancel
3
Enter JobId(s), comma separated, to restore: 80
You have selected the following JobId: 80

Building directory tree for JobId(s) 80 ...  
1 files inserted into the tree.

You are now entering file selection mode where you add (mark) and
remove (unmark) files to be restored. No files are initially added, unless
you used the "all" keyword on the command line.
Enter "done" to leave this mode.

cwd is: /
$ add etc/
2 files marked.
cd etc/ 
cwd is: /etc/
$ ls
*BACULA_TEST_12-34
$ done
Bootstrap records written to /var/lib/bacula/gendalf-dir.restore.4.bsr

The Job will require the following (*=>InChanger):
   Volume(s)                 Storage(s)                SD Device(s)
===========================================================================
   
    Vol-0003                  File                      FileStorage              

Volumes marked with "*" are in the Autochanger.


2 files selected to be restored.

The defined Restore Job resources are:
     1: RestoreRemote
     2: RestoreFiles
Select Restore Job (1-2): 1
Defined Clients:
     1: bilbo-fd
     2: gendalf-fd
Select the Client (1-2): 1
Using Catalog "MyCatalog"
Run Restore job
JobName:         RestoreRemote
Bootstrap:       /var/lib/bacula/gendalf-dir.restore.4.bsr
Where:           /bacula/restore
Replace:         always
FileSet:         Full Set
Backup Client:   bilbo-fd
Restore Client:  bilbo-fd
Storage:         File
When:            2019-09-30 18:51:25
Catalog:         MyCatalog
Priority:        10
OK to run? (yes/mod/no): yes
Job queued. JobId=93
You have messages.

root@bilbo:~# ll /bacula/restore/etc/BACULA_TEST_12-34 
-rw-r--r-- 1 root root 29 Sep 30 12:16 /bacula/restore/etc/BACULA_TEST_12-34

```

##### Status
```
root@gendalf:~# bconsole 
Connecting to Director localhost:9101
1000 OK: 1 gendalf-dir Version: 7.0.5 (28 July 2014)
Enter a period to cancel a command.
*status all
gendalf-dir Version: 7.0.5 (28 July 2014) x86_64-pc-linux-gnu ubuntu 16.04
Daemon started 30-Sep-19 12:02. Jobs: run=20, running=0 mode=0,0
 Heap: heap=651,264 smbytes=290,187 max_bytes=430,065 bufs=339 max_bufs=402

Scheduled Jobs:
Level          Type     Pri  Scheduled          Job Name           Volume
===================================================================================
Incremental    Backup    10  30-Sep-19 17:10    BilboRemoteBackup  Vol-0003
Incremental    Backup    10  30-Sep-19 17:20    BilboRemoteBackup  Vol-0003
Incremental    Backup    10  30-Sep-19 17:30    BilboRemoteBackup  Vol-0003
Differential   Backup    10  30-Sep-19 17:30    BilboRemoteBackup  Vol-0003
Incremental    Backup    10  30-Sep-19 17:40    BilboRemoteBackup  Vol-0003
Incremental    Backup    10  30-Sep-19 17:50    BilboRemoteBackup  Vol-0003
Incremental    Backup    10  30-Sep-19 18:00    BilboRemoteBackup  Vol-0003
Differential   Backup    10  30-Sep-19 18:00    BilboRemoteBackup  Vol-0003
Incremental    Backup    10  30-Sep-19 23:05    LocalBackup        Vol-0001
Full           Backup    11  30-Sep-19 23:10    BackupCatalog      Vol-0001
Full           Backup    10  01-Oct-19 00:01    BilboRemoteBackup  Vol-0003
====

Running Jobs:
Console connected at 30-Sep-19 12:15
No Jobs running.
====

Terminated Jobs:
 JobId  Level    Files      Bytes   Status   Finished        Name 
====================================================================
    71  Incr          0         0   OK       30-Sep-19 13:20 BilboRemoteBackup
    72  Incr          0         0   OK       30-Sep-19 13:30 BilboRemoteBackup
    73  Diff          2        37   OK       30-Sep-19 13:30 BilboRemoteBackup
    74  Incr          0         0   OK       30-Sep-19 13:40 BilboRemoteBackup
    75  Incr          0         0   OK       30-Sep-19 13:50 BilboRemoteBackup
    76  Incr          0         0   OK       30-Sep-19 14:00 BilboRemoteBackup
    77  Diff          2        37   OK       30-Sep-19 14:00 BilboRemoteBackup
    78  Incr          0         0   OK       30-Sep-19 14:10 BilboRemoteBackup
    79  Incr          0         0   OK       30-Sep-19 17:00 BilboRemoteBackup
    80  Diff          2        37   OK       30-Sep-19 17:00 BilboRemoteBackup

====
Connecting to Storage daemon File1 at 192.168.50.10:9103

gendalf-sd Version: 7.0.5 (28 July 2014) x86_64-pc-linux-gnu ubuntu 16.04
Daemon started 30-Sep-19 12:03. Jobs: run=20, running=0.
 Heap: heap=135,168 smbytes=247,513 max_bytes=458,419 bufs=144 max_bufs=168
 Sizes: boffset_t=8 size_t=8 int32_t=4 int64_t=8 mode=0,0

Running Jobs:
No Jobs running.
====

Jobs waiting to reserve a drive:
====

Terminated Jobs:
 JobId  Level    Files      Bytes   Status   Finished        Name 
===================================================================
    71  Incr          0         0   OK       30-Sep-19 13:20 BilboRemoteBackup
    72  Incr          0         0   OK       30-Sep-19 13:30 BilboRemoteBackup
    73  Diff          2       208   OK       30-Sep-19 13:30 BilboRemoteBackup
    74  Incr          0         0   OK       30-Sep-19 13:40 BilboRemoteBackup
    75  Incr          0         0   OK       30-Sep-19 13:50 BilboRemoteBackup
    76  Incr          0         0   OK       30-Sep-19 14:00 BilboRemoteBackup
    77  Diff          2       208   OK       30-Sep-19 14:00 BilboRemoteBackup
    78  Incr          0         0   OK       30-Sep-19 14:10 BilboRemoteBackup
    79  Incr          0         0   OK       30-Sep-19 17:00 BilboRemoteBackup
    80  Diff          2       208   OK       30-Sep-19 17:00 BilboRemoteBackup
====

Device status:
Autochanger "FileChgr1" with devices:
   "FileChgr1-Dev1" (/nonexistant/path/to/file/archive/dir)
   "FileChgr1-Dev2" (/nonexistant/path/to/file/archive/dir)
Autochanger "FileChgr2" with devices:
   "FileChgr2-Dev1" (/nonexistant/path/to/file/archive/dir)
   "FileChgr2-Dev2" (/nonexistant/path/to/file/archive/dir)

Device "FileChgr1-Dev1" (/nonexistant/path/to/file/archive/dir) is not open.
==

Device "FileChgr1-Dev2" (/nonexistant/path/to/file/archive/dir) is not open.
==

Device "FileStorage" (/srv/backup/backupstorage) is not open.
==

Device "FileChgr2-Dev1" (/nonexistant/path/to/file/archive/dir) is not open.
==

Device "FileChgr2-Dev2" (/nonexistant/path/to/file/archive/dir) is not open.
==
====

Used Volume status:
====

Attr spooling: 0 active jobs, 433,019 bytes; 20 total jobs, 433,019 max bytes.
====

Connecting to Client gendalf-fd at localhost:9102

gendalf-fd Version: 7.0.5 (28 July 2014)  x86_64-pc-linux-gnu ubuntu 16.04
Daemon started 30-Sep-19 12:03. Jobs: run=0 running=0.
 Heap: heap=172,032 smbytes=187,680 max_bytes=187,827 bufs=53 max_bufs=54
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s

Running Jobs:
Director connected at: 30-Sep-19 17:00
No Jobs running.
====

Terminated Jobs:
====
Connecting to Client bilbo-fd at 192.168.50.20:9102

bilbo-fd Version: 7.0.5 (28 July 2014)  x86_64-pc-linux-gnu ubuntu 16.04
Daemon started 30-Sep-19 10:06. Jobs: run=20 running=0.
 Heap: heap=176,128 smbytes=476,730 max_bytes=736,959 bufs=100 max_bufs=159
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s

Running Jobs:
Director connected at: 30-Sep-19 17:00
No Jobs running.
====

Terminated Jobs:
 JobId  Level    Files      Bytes   Status   Finished        Name 
===================================================================
    71  Incr          0         0   OK       30-Sep-19 13:20 BilboRemoteBackup
    72  Incr          0         0   OK       30-Sep-19 13:30 BilboRemoteBackup
    73  Diff          2        37   OK       30-Sep-19 13:30 BilboRemoteBackup
    74  Incr          0         0   OK       30-Sep-19 13:40 BilboRemoteBackup
    75  Incr          0         0   OK       30-Sep-19 13:50 BilboRemoteBackup
    76  Incr          0         0   OK       30-Sep-19 14:00 BilboRemoteBackup
    77  Diff          2        37   OK       30-Sep-19 14:00 BilboRemoteBackup
    78  Incr          0         0   OK       30-Sep-19 14:10 BilboRemoteBackup
    79  Incr          0         0   OK       30-Sep-19 17:00 BilboRemoteBackup
    80  Diff          2        37   OK       30-Sep-19 17:00 BilboRemoteBackup
====

```

#### System log example

```
30-Sep 12:10 gendalf-dir JobId 62: Start Backup JobId 62, Job=BilboRemoteBackup.2019-09-30_12.10.00_04
30-Sep 12:10 gendalf-dir JobId 62: Using Device "FileStorage" to write.
30-Sep 12:10 gendalf-sd JobId 62: Volume "Vol-0003" previously written, moving to end of data.
30-Sep 12:10 gendalf-sd JobId 62: Ready to append to end of Volume "Vol-0003" size=989,325
30-Sep 12:10 gendalf-sd JobId 62: Elapsed time=00:00:11, Transfer rate=0  Bytes/second
30-Sep 12:10 gendalf-sd JobId 62: Sending spooled attrs to the Director. Despooling 0 bytes ...
30-Sep 12:10 gendalf-dir JobId 62: Bacula gendalf-dir 7.0.5 (28Jul14):
  Build OS:               x86_64-pc-linux-gnu ubuntu 16.04
  JobId:                  62
  Job:                    BilboRemoteBackup.2019-09-30_12.10.00_04
  Backup Level:           Incremental, since=2019-09-30 12:04:04
  Client:                 "bilbo-fd" 7.0.5 (28Jul14) x86_64-pc-linux-gnu,ubuntu,16.04
  FileSet:                "bilbo etc" 2019-09-29 18:30:00
  Pool:                   "File" (From Job resource)
  Catalog:                "MyCatalog" (From Client resource)
  Storage:                "File" (From Job resource)
  Scheduled time:         30-Sep-2019 12:10:00
  Start time:             30-Sep-2019 12:10:02
  End time:               30-Sep-2019 12:10:13
  Elapsed time:           11 secs
  Priority:               10
  FD Files Written:       0
  SD Files Written:       0
  FD Bytes Written:       0 (0 B)
  SD Bytes Written:       0 (0 B)
  Rate:                   0.0 KB/s
  Software Compression:   None
  VSS:                    no
  Encryption:             no
  Accurate:               no
  Volume name(s):         
  Volume Session Id:      2
  Volume Session Time:    1569834194
  Last Volume Bytes:      989,741 (989.7 KB)
  Non-fatal FD errors:    0
  SD Errors:              0
  FD termination status:  OK
  SD termination status:  OK
  Termination:            Backup OK

30-Sep 12:10 gendalf-dir JobId 62: Begin pruning Jobs older than 6 months .
30-Sep 12:10 gendalf-dir JobId 62: No Jobs found to prune.
30-Sep 12:10 gendalf-dir JobId 62: Begin pruning Files.
30-Sep 12:10 gendalf-dir JobId 62: No Files found to prune.
30-Sep 12:10 gendalf-dir JobId 62: End auto prune.

```

### Useful links

https://webmodelling.com/webbits/miscellaneous/bacula.aspx

https://webmodelling.com/webbits/miscellaneous/bacula.aspx