
# OTUS Linux admin course

## PostgreSQL replication

### How to use this repo

Clone repo, run `vagrant up`. 


| Name  | IP           |
|-------|--------------|
|master	|192.168.100.10|
|slave	|192.168.100.11|
|backup |192.168.100.12|
------------------------

### Stend config

#### Master server

* `/var/lib/pgsql/11/data/pg_hba.conf` 
```
# PostgreSQL Client Authentication Configuration File
# ===================================================
# TYPE  DATABASE        USER                    ADDRESS                        METHOD
local   all             all                                                    peer
# Allow all users access (passwd check) 
host    all             all                     192.168.100.0/24               md5
# Allow selected users access (passwd check)
host    replication     repluser     127.0.0.1/32                   md5
host    replication     repluser     192.168.100.10/32           md5
host    replication     repluser     192.168.100.11/32          md5
host    replication     streaming_barman 192.168.100.12/32 md5
```

* `/var/lib/pgsql/11/data/postgresql.conf`
```
listen_addresses = '*'

max_connections = 80
shared_buffers = 256MB
dynamic_shared_memory_type = posix

fsync = on
autovacuum = on

hot_standby = on
wal_level = replica
wal_log_hints = on
max_replication_slots = 4
max_wal_senders = 6
wal_keep_segments = 32
min_wal_size = 100MB
max_wal_size = 1GB
archive_mode = on
# set WAL archive in local dir "archive" (barman use when backup)
archive_command = 'cp -i %p /var/lib/pgsql/11/data/archive/%f'

# set WAL archive on barman server in dir "incoming"
# recommemded but need setup keys 
# archive_command = 'barman-wal-archive 192.168.100.12 192.168.100.10 %p'
```

#### Standby server

* `/var/lib/pgsql/11/data/postgresql.conf`
```
listen_addresses = '*'
hot_standby = on
```

* `/var/lib/pgsql/11/data/postgresql.conf`
```
listen_addresses = '*'
hot_standby = on[root@slave vagrant]# cat /var/lib/pgsql/11/data/recovery.conf
standby_mode = 'on'
primary_conninfo = 'user=repluser passfile=''/var/lib/pgsql/.pgpass'' host=192.168.100.10 port=5432 sslmode=prefer sslcompression=0 krbsrvname=postgres target_session_attrs=any'
primary_slot_name = 'standby_slot'
```

#### Barman server

* `/etc/barman.conf`
```
[barman]
barman_user = barman
barman_home = /var/lib/barman
configuration_files_directory = /etc/barman.d
log_file = /var/log/barman/barman.log
log_level = INFO
;compression = gzip
```

* `/etc/barman.d/main.conf`
```
[192.168.100.10]
description =  "PostgreSQL Database"
conninfo = host=192.168.100.10 user=barman dbname=postgres
streaming_conninfo = host=192.168.100.10 user=streaming_barman dbname=postgres
backup_method = postgres
streaming_archiver = on
slot_name = barman
path_prefix = /usr/pgsql-11/bin
```

------------------------

### Check replication

* Create DB and table wih data on master server.
```
[root@master vagrant]# sudo -u postgres psql
postgres=# CREATE DATABASE test_db ENCODING='UTF8';
CREATE DATABASE
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# CREATE TABLE companies (name varchar(80));
CREATE TABLE
test_db=# INSERT INTO companies VALUES ('Otus');
INSERT 0 1

```

* Check DB on slave server.
```
[root@slave vagrant]# sudo -u postgres psql
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(4 rows)

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# SELECT * FROM companies ;
 name 
------
 Otus
(1 row)
```

------------------------

### Barman backup

* Check WAL files
```
[root@backup vagrant]# sudo barman switch-wal --force --archive --archive-timeout 60 192.168.100.10
The WAL file 000000010000000000000003 has been closed on server '192.168.100.10'
Waiting for the WAL file 000000010000000000000003 from server '192.168.100.10' (max: 60 seconds)
Processing xlog segments from streaming for 192.168.100.10
	000000010000000000000003
```

* Check barman
```
[root@backup vagrant]# sudo barman check 192.168.100.10
Server 192.168.100.10:
	PostgreSQL: OK
	is_superuser: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archiver errors: OK
```

* Run backup
```
[root@backup vagrant]# sudo barman backup 192.168.100.10 --wait
Starting backup using postgres method for server 192.168.100.10 in /var/lib/barman/192.168.100.10/base/20191218T104029
Backup start at LSN: 0/130000C8 (000000010000000000000013, 000000C8)
Starting backup copy via pg_basebackup for 20191218T104029
Copy done (time: 2 seconds)
Finalising the backup.
Backup size: 326.6 MiB
Backup end at LSN: 0/15000000 (000000010000000000000014, 00000000)
Backup completed (start time: 2019-12-18 10:40:29.762023, elapsed time: 2 seconds)
Waiting for the WAL file 000000010000000000000014 from server '192.168.100.10'
Processing xlog segments from streaming for 192.168.100.10
        000000010000000000000012
        000000010000000000000013
Processing xlog segments from streaming for 192.168.100.10
        000000010000000000000014
```

* Check backup dir.
```
[root@backup vagrant]# ls -l /var/lib/barman/192.168.100.10/
total 4
drwxr-xr-x. 7 barman barman 121 Dec 18 10:40 base
drwxr-xr-x. 2 barman barman   6 Dec 18 10:20 errors
-rw-r--r--. 1 barman barman  64 Dec 18 10:20 identity.json
drwxr-xr-x. 2 barman barman   6 Dec 18 10:20 incoming
drwxr-xr-x. 2 barman barman  46 Dec 18 10:40 streaming
drwxr-xr-x. 3 barman barman  45 Dec 18 10:40 wals
```

* Show server params
```
[root@backup vagrant]# barman show-server 192.168.100.10
Server 192.168.100.10:
        active: True
        archive_timeout: 0
        archiver: False
        archiver_batch_size: 0
        backup_directory: /var/lib/barman/192.168.100.10
        backup_method: postgres
        backup_options: BackupOptions(['concurrent_backup'])
        bandwidth_limit: None
        barman_home: /var/lib/barman
        barman_lock_directory: /var/lib/barman
        basebackup_retry_sleep: 30
        basebackup_retry_times: 0
...
```

* Recovery (you should setup ssh-key auth between barman ans master)

```
[root@backup vagrant]# barman list-backup 192.168.100.10
192.168.100.10 20191218T145011 - Wed Dec 18 14:50:12 2019 - Size: 118.7 MiB - WAL Size: 0 B

[root@backup vagrant]# barman show-backup 192.168.100.10 20191218T145011
Backup 20191218T145011:
  Server Name            : 192.168.100.10
  System Id              : 6771789205388191330
  Status                 : DONE
  PostgreSQL Version     : 110006
  PGDATA directory       : /var/lib/pgsql/11/data

  Base backup information:
    Disk usage           : 102.7 MiB (118.7 MiB with WALs)
    Incremental size     : 102.7 MiB (-0.00%)
    Timeline             : 1
    Begin WAL            : 000000010000000000000006
    End WAL              : 000000010000000000000006
    WAL number           : 1
    Begin time           : 2019-12-18 14:50:11+00:00
    End time             : 2019-12-18 14:50:12.913720+00:00
    Copy time            : 1 second
    Estimated throughput : 56.1 MiB/s
    Begin Offset         : 40
    End Offset           : 0
    Begin LSN           : 0/6000028
    End LSN             : 0/7000000

  WAL information:
    No of files          : 0
    Disk usage           : 0 B
    Last available       : 000000010000000000000006

  Catalog information:
    Retention Policy     : not enforced
    Previous Backup      : - (this is the oldest base backup)
    Next Backup          : - (this is the latest base backup)

[root@backup vagrant]# barman recover 192.168.100.10 20191218T145011 /var/lib/pgsql/11/data --remote-ssh-command "ssh postgres@192.168.100.10"
Starting remote restore for server 192.168.100.10 using backup 20191218T145011
Destination directory: /var/lib/pgsql/11/data
Remote command: ssh postgres@192.168.100.10
Using safe horizon time for smart rsync copy: 2019-12-18 14:50:11+00:00
Copying the base backup.
Copying required WAL segments.
Generating archive status files
Identify dangerous settings in destination directory.

IMPORTANT
These settings have been modified to prevent data losses

postgresql.conf line 20: archive_command = false

Recovery completed (start time: 2019-12-18 16:02:54.388917, elapsed time: 22 seconds)

Your PostgreSQL server has been successfully prepared for recovery!
```

### Useful links

https://yum.postgresql.org/

https://wiki.postgresql.org/wiki/Apt

http://repo.postgrespro.ru/

https://www.postgres-xl.org/

https://www.postgresql.org/docs/9.4/functions-admin.html

https://www.pgbarman.org/
