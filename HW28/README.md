
# OTUS Linux admin course

## Mysql (Replication)

### How to use this repo

Clone repo, run `vagrant up`. You`ll get mysql master and replica servers.

### Check status

#### Check GTID and mode is ON

 * Master
```
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
|           1 |
+-------------+
1 row in set (0.00 sec)

mysql> SHOW VARIABLES LIKE 'gtid_mode';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| gtid_mode     | ON    |
+---------------+-------+
1 row in set (0.08 sec)

```

* Replica
```
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
|           2 |
+-------------+
1 row in set (0.14 sec)

```

#### Replica status

* Master
```
mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: mysql-bin.000002
         Position: 121515
     Binlog_Do_DB: bet
 Binlog_Ignore_DB: 
Executed_Gtid_Set: cb0fd609-1381-11ea-be23-5254008afee6:1-44
1 row in set (0.04 sec)
```

* Slave
```
mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.11.160
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 121515
               Relay_Log_File: replica-relay-bin.000002
                Relay_Log_Pos: 121729
        Relay_Master_Log_File: mysql-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 121515
              Relay_Log_Space: 121939
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: cb0fd609-1381-11ea-be23-5254008afee6
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: cb0fd609-1381-11ea-be23-5254008afee6:1-44
            Executed_Gtid_Set: 45667134-1381-11ea-9a2a-5254008afee6:1-2,
cb0fd609-1381-11ea-be23-5254008afee6:1-44
                Auto_Position: 1
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
       Master_public_key_path: 
        Get_master_public_key: 0
            Network_Namespace: 
1 row in set (0.02 sec)

```

#### Replica in action

Make changes on master
```
mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)

mysql> INSERT INTO bookmaker (id,bookmaker_name) VALUES(2,'Otus_test');
Query OK, 1 row affected (0.03 sec)

mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  2 | Otus_test      |
|  3 | unibet         |
+----+----------------+
6 rows in set (0.00 sec)

```

See record `Otus_test` on replica
```
mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)

mysql> SELECT * FROM bookmaker;  <---- After add on master
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  2 | Otus_test      |   <---!!!
|  3 | unibet         |
+----+----------------+
6 rows in set (0.00 sec)

```

Check bin logs on replica
```
[root@replica vagrant]# mysqlbinlog /var/lib/mysql/mysql-bin.000002 |tail -20
/*!80014 SET @@session.immediate_server_version=80018*//*!*/;
SET @@SESSION.GTID_NEXT= 'cb0fd609-1381-11ea-be23-5254008afee6:46'/*!*/;
# at 116830
#191130 17:26:10 server id 1  end_log_pos 116906 CRC32 0x08694a56 	Query	thread_id=20	exec_time=0	error_code=0
SET TIMESTAMP=1575127570/*!*/;
BEGIN
/*!*/;
# at 116906
#191130 17:26:10 server id 1  end_log_pos 117040 CRC32 0x296e33c6 	Query	thread_id=20	exec_time=0	error_code=0
SET TIMESTAMP=1575127570/*!*/;
INSERT INTO bookmaker (id,bookmaker_name) VALUES(2,'Otus_test')
/*!*/;
# at 117040
#191130 17:26:10 server id 1  end_log_pos 117071 CRC32 0x80d9a286 	Xid = 88
COMMIT/*!*/;
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
```

### Useful links

https://habr.com/post/126358/

https://ruhighload.com/%D0%9A%D0%B0%D0%BA+%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B8%D1%82%D1%8C+mysql+master-slave+%D1%80%D0%B5%D0%BF%D0%BB%D0%B8%D0%BA%D0%B0%D1%86%D0%B8%D1%8E%3F

https://easyengine.io/tutorials/mysql/query-profiling

http://manenok.pp.ua/tunning-mysql/

http://gahcep.github.io/blog/2013/01/05/mysql-utf8/

https://www.digitalocean.com/community/tutorials/how-to-configure-mysql-backups-with-percona-xtrabackup-on-ubuntu-16-04

https://github.com/chrisleekr/vagrant-mysql-master-slave-replication.git

https://www.percona.com/sites/default/files/presentations/checklistfinal-170607204115.pdf

https://www.percona.com/software/mysql-database/percona-xtrabackup/feature-comparison

https://docs.ansible.com/ansible/2.5/modules/mysql_replication_module.html