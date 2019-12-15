
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
[root@backup vagrant]# sudo barman backup 192.168.100.10
Starting backup using postgres method for server 192.168.100.10 in /var/lib/barman/192.168.100.10/base/20191215T125820
Backup start at LSN: 0/4000060 (000000010000000000000004, 00000060)
Starting backup copy via pg_basebackup for 20191215T125820
Copy done (time: 1 second)
Finalising the backup.
This is the first backup for server 192.168.100.10
WAL segments preceding the current backup have been found:
	000000010000000000000003 from server 192.168.100.10 has been removed
Backup size: 94.0 MiB
Backup end at LSN: 0/6000000 (000000010000000000000005, 00000000)
Backup completed (start time: 2019-12-15 12:58:20.571059, elapsed time: 2 seconds)
Processing xlog segments from streaming for 192.168.100.10
	000000010000000000000004
WARNING: IMPORTANT: this backup is classified as WAITING_FOR_WALS, meaning that Barman has not received yet all the required WAL files for the backup consistency.
This is a common behaviour in concurrent backup scenarios, and Barman automatically set the backup as DONE once all the required WAL files have been archived.
Hint: execute the backup command with '--wait'
```

* Check backup dir.
```
[root@backup vagrant]# ls -l /var/lib/barman/192.168.100.10/
total 4
drwxr-xr-x. 3 barman barman 29 Dec 15 12:58 base
drwxr-xr-x. 2 barman barman  6 Dec 15 12:58 errors
-rw-r--r--. 1 barman barman 64 Dec 15 12:58 identity.json
drwxr-xr-x. 2 barman barman  6 Dec 15 12:58 incoming
drwxr-xr-x. 2 barman barman 78 Dec 15 12:58 streaming
drwxr-xr-x. 2 barman barman 21 Dec 15 12:58 wals
```

### Useful links

https://yum.postgresql.org/

https://wiki.postgresql.org/wiki/Apt

http://repo.postgrespro.ru/

https://www.postgres-xl.org/

https://www.postgresql.org/docs/9.4/functions-admin.html

https://www.pgbarman.org/