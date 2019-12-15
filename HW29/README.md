
# OTUS Linux admin course

## Mysql InnoDB cluster

### How to use this repo

See Swarm and Docker-compose section for details.

### Docker-compose

* Run up cluster on local machine
```
$> docker-compose up -d
Starting hw29_proxy_1                  ... done
Starting hw29_galera_etcd_1            ... done
Starting hw29_percona-xtradb-cluster_1 ... done

$> docker-compose scale percona-xtradb-cluster=3
WARNING: The scale command is deprecated. Use the up command with the --scale flag instead.
Starting hw29_percona-xtradb-cluster_1 ... done
Creating hw29_percona-xtradb-cluster_2 ... done
Creating hw29_percona-xtradb-cluster_3 ... done

$> docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                                                                              NAMES
8f6fb624f8bc        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh mysq…"   18 seconds ago      Up 16 seconds       3306/tcp, 4567-4568/tcp                                                            hw29_percona-xtradb-cluster_3
6c77baaf8bf5        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh mysq…"   18 seconds ago      Up 16 seconds       3306/tcp, 4567-4568/tcp                                                            hw29_percona-xtradb-cluster_2
4eddc63b2705        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh mysq…"   3 minutes ago       Up 18 seconds       3306/tcp, 4567-4568/tcp                                                            hw29_percona-xtradb-cluster_1
414051bf17e5        perconalab/proxysql                  "/entrypoint.sh "        3 minutes ago       Up 54 seconds       0.0.0.0:3306->3306/tcp, 0.0.0.0:6032->6032/tcp                                     hw29_proxy_1
e03eecbca6d8        quay.io/coreos/etcd                  "etcd"                   3 minutes ago       Up 53 seconds       0.0.0.0:2379-2380->2379-2380/tcp, 0.0.0.0:4001->4001/tcp, 0.0.0.0:7001->7001/tcp   hw29_galera_etcd_1
```

* You need to add monotir user to mysql. Run command on any percona-xtradb-cluster. Wait some time untill mysql startd.
```
$ docker exec hw29_percona-xtradb-cluster_1 /usr/bin/monitor_user_add.sh
mysql: [Warning] Using a password on the command line interface can be insecure.
User monitor added!
```

* Down
```
$ docker-compose down
Stopping hw29_percona-xtradb-cluster_1 ... done
Stopping hw29_galera_etcd_1            ... done
Stopping hw29_proxy_1                  ... done
Removing hw29_percona-xtradb-cluster_1 ... done
Removing hw29_galera_etcd_1            ... done
Removing hw29_proxy_1                  ... done
```

#### Check COMPOSE cluster state

##### Percona
```
$ docker exec -ti hw29_percona-xtradb-cluster_1 bash

bash-4.2$ mysql -h 127.0.0.1  -uroot -p'1MySQL(Password)'
...

mysql> create database bet;
Query OK, 1 row affected (0.02 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)
```

##### Sqlproxy
```
$> docker exec -ti hw29_proxy_1 bash

root@414051bf17e5:/# mysql -h 127.0.0.1 -P6032 -uadmin -padmin
...

mysql> show tables;
+--------------------------------------+
| tables                               |
+--------------------------------------+
| global_variables                     |
| mysql_collations                     |
| mysql_query_rules                    |
| mysql_replication_hostgroups         |
| mysql_servers                        |
| mysql_users                          |
| runtime_global_variables             |
| runtime_mysql_query_rules            |
| runtime_mysql_replication_hostgroups |
| runtime_mysql_servers                |
| runtime_mysql_users                  |
| runtime_scheduler                    |
| scheduler                            |
+--------------------------------------+
13 rows in set (0.00 sec)

mysql> SELECT * FROM mysql_servers;
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| hostgroup_id | hostname   | port | status | weight | compression | max_connections | max_replication_lag | use_ssl | max_latency_ms | comment |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| 0            | 172.18.0.3 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
| 0            | 172.18.0.5 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
| 0            | 172.18.0.6 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
3 rows in set (0.00 sec)

mysql> show variables like '%monitor%'
    -> ;
+----------------------------------------+---------+
| Variable_name                          | Value   |
+----------------------------------------+---------+
| mysql-monitor_enabled                  | true    |
| mysql-monitor_connect_timeout          | 200     |
| mysql-monitor_ping_max_failures        | 3       |
| mysql-monitor_ping_timeout             | 1000    |
| mysql-monitor_read_only_interval       | 1000    |
| mysql-monitor_read_only_timeout        | 800     |
| mysql-monitor_replication_lag_interval | 10000   |
| mysql-monitor_replication_lag_timeout  | 1000    |
| mysql-monitor_username                 | monitor |
| mysql-monitor_password                 | monitor |
| mysql-monitor_query_interval           | 60000   |
| mysql-monitor_query_timeout            | 100     |
| mysql-monitor_slave_lag_when_null      | 60      |
| mysql-monitor_writer_is_also_reader    | true    |
| mysql-monitor_history                  | 60000   |
| mysql-monitor_connect_interval         | 20000   |
| mysql-monitor_ping_interval            | 10000   |
+----------------------------------------+---------+
17 rows in set (0.00 sec)

```

##### Etcd

* quay.io/coreos/etcd
```
# /usr/local/bin/etcdctl cluster-health
member d55d15f6ea07ddc1 is healthy: got healthy result from http://galera_etcd:2379
cluster is healthy
```

#### Check Mysql cluster

* Curent state of containers
```
$> docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                                                                              NAMES
8f6fb624f8bc        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh mysq…"   7 minutes ago       Up 7 minutes        3306/tcp, 4567-4568/tcp                                                            hw29_percona-xtradb-cluster_3
6c77baaf8bf5        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh mysq…"   7 minutes ago       Up 7 minutes        3306/tcp, 4567-4568/tcp                                                            hw29_percona-xtradb-cluster_2
4eddc63b2705        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh mysq…"   10 minutes ago      Up 7 minutes        3306/tcp, 4567-4568/tcp                                                            hw29_percona-xtradb-cluster_1
414051bf17e5        perconalab/proxysql                  "/entrypoint.sh "        10 minutes ago      Up 7 minutes        0.0.0.0:3306->3306/tcp, 0.0.0.0:6032->6032/tcp                                     hw29_proxy_1
e03eecbca6d8        quay.io/coreos/etcd                  "etcd"                   10 minutes ago      Up 7 minutes        0.0.0.0:2379-2380->2379-2380/tcp, 0.0.0.0:4001->4001/tcp, 0.0.0.0:7001->7001/tcp   hw29_galera_etcd_1
```

##### Check db creation is replicated to other workers

* Login on worker `hw29_percona-xtradb-cluster_2` and create base `otus`
```
$> docker exec -ti hw29_percona-xtradb-cluster_2 bash

bash-4.2$ mysql -h 127.0.0.1  -uroot -p'1MySQL(Password)'
...

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.01 sec)

mysql>  create database otus;
Query OK, 1 row affected (0.02 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| otus               |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.01 sec)

```

* Login on another worker `hw29_percona-xtradb-cluster_1` and see `otus` database
```
$> docker exec -ti hw29_percona-xtradb-cluster_1 bash
bash-4.2$ mysql -h 127.0.0.1  -uroot -p'1MySQL(Password)'
mysql: [Warning] Using a password on the command line interface can be insecure.
...

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

!!!! After creatin on another worker !!!  <------

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| otus               |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.00 sec)

```

##### Check connection from mysqlproxy

* On mysqlproxy container
```
$> docker exec -ti hw29_proxy_1 bash

root@414051bf17e5:/# mysql -h 127.0.0.1 -P3306 -uproxyuser -p'1MySQL(Password)'
...

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| otus               |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.00 sec)

mysql> create database proxytest;
Query OK, 1 row affected (0.02 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| otus               |
| performance_schema |
| proxytest          |
| sys                |
+--------------------+
7 rows in set (0.00 sec)

```

* Check result on worker we can see `proxytest`
```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| otus               |
| performance_schema |
| proxytest          |
| sys                |
+--------------------+
7 rows in set (0.00 sec)
```

#### Check connection from local machine

```
$ mysql -h 127.0.0.1 -P3306 -uproxyuser -p'1MySQL(Password)'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 20
Server version: 5.5.30 (ProxySQL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| otus               |
| performance_schema |
| proxytest          |
| sys                |
+--------------------+
7 rows in set (0.00 sec)

```

#### Troubleshooting

* If after `docker-swarm up -d` you get no worker, run `docker-swarm up -d`  or `docker-compose scale percona-xtradb-cluster=3` againg.

* If after `docker-compose scale percona-xtradb-cluster=3` you get only one worker in mysql cluster

```
mysql> SELECT * FROM mysql_servers;
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| hostgroup_id | hostname   | port | status | weight | compression | max_connections | max_replication_lag | use_ssl | max_latency_ms | comment |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| 0            | 172.22.0.3 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
1 row in set (0.00 sec)
```

Manualy run `/usr/bin/add_cluster_nodes.sh` in mysqlproxy comtainer 

```
mysql> SELECT * FROM mysql_servers;
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| hostgroup_id | hostname   | port | status | weight | compression | max_connections | max_replication_lag | use_ssl | max_latency_ms | comment |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| 0            | 172.22.0.3 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
| 0            | 172.22.0.5 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
| 0            | 172.22.0.6 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
3 rows in set (0.00 sec)
```

----------------------------------------------------------------------------------------------------------------------

### SWARM (not complited yet)
 
Clone repo, run `vagrant up` you`ll get:
```
$ vagrant status
Current machine states:

manager                   running (virtualbox)
worker1                   running (virtualbox)
worker2                   running (virtualbox)
```

* Login to manager `docker ssh manager` and run `docker swarm init`

Example:
```
vagrant@manager:/vagrant$ docker swarm init --advertise-addr 192.168.10.2
Swarm initialized: current node (qriy6prjlfvuu8zfmakpsz1te) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-4lvwnzf4o9rc9ssdbq3367gc4d4wiuv387z1vd59bode9iy2l0-4sqn1hgghpeyhoii0p82yc40k \
    192.168.10.2:2377
```

* On all workers run `docker swarm join ...`
```
vagrant@worker1:~$  docker swarm join \
>     --token SWMTKN-1-4lvwnzf4o9rc9ssdbq3367gc4d4wiuv387z1vd59bode9iy2l0-4sqn1hgghpeyhoii0p82yc40k \
>     192.168.10.2:2377
This node joined a swarm as a worker.
```

* After on master  `docker stack deploy -c percona-cluster.yml percona`:
```
vagrant@manager:/vagrant$ docker stack deploy -c percona-cluster.yml percona
Creating network percona_galera
Creating service percona_proxy
Creating service percona_galera_etcd
Creating service percona_percona-xtradb-cluster

vagrant@manager:/vagrant$ docker service ls
ID                  NAME                             MODE                REPLICAS            IMAGE                                PORTS
5p78irdv68q6        percona_proxy                    replicated          1/1                 perconalab/proxysql:latest           *:3306->3306/tcp,*:6032->6032/tcp
70cxrjysb4wq        percona_galera_etcd              replicated          1/1                 quay.io/coreos/etcd:latest           
foe7d5auly6u        percona_percona-xtradb-cluster   global              2/2                 percona/percona-xtradb-cluster:5.7   

vagrant@manager:/vagrant$  docker service scale percona_percona-xtradb-cluster=3
percona_percona-xtradb-cluster scaled to 3

$ docker stack deploy -c percona-cluster.yml percona
Creating network percona_galera
Creating service percona_proxy
Creating service percona_galera_etcd
Creating service percona_percona-xtradb-cluster

vagrant@manager:/vagrant$ docker service ls
ID                  NAME                             MODE                REPLICAS            IMAGE                                PORTS
5uelvul61xdp        percona_proxy                    replicated          1/1                 perconalab/proxysql:latest           *:3306->3306/tcp,*:6032->6032/tcp
k94j89a5uohw        percona_galera_etcd              replicated          1/1                 quay.io/coreos/etcd:latest           
nba9jky02gje        percona_percona-xtradb-cluster   global              2/2                 percona/percona-xtradb-cluster:5.7  


vagrant@manager:/vagrant$  docker ps
CONTAINER ID        IMAGE                        COMMAND             CREATED             STATUS              PORTS                NAMES
b631dd00abca        perconalab/proxysql:latest   "/entrypoint.sh "   2 minutes ago       Up 2 minutes        3306/tcp, 6032/tcp   percona_proxy.1.yn5jmpdvqropewwerw01ssavx
e2c7a696bdcf        quay.io/coreos/etcd:latest   "etcd"              2 minutes ago       Up 2 minutes                             percona_galera_etcd.1.lsd46oqf95sgyv25erj3m57fr
```

* On workers:
```
vagrant@worker1:~$  docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS               NAMES
15b2c59a9426        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh my..."   22 seconds ago      Up 16 seconds                           percona_percona-xtradb-cluster.9jg58xzqb8owefm0fe0ngcuky.ne2kl705enzkff8tp81fjg28p
```

* For destroy
```
vagrant@manager:/vagrant$ docker stack rm percona
Removing service percona_galera_etcd
Removing service percona_percona-xtradb-cluster
Removing service percona_proxy
Removing network percona_galera

$ docker swarm leave --force
Node left the swarm.
```

#### Check SWARM cluster state

##### Percona
```
$ docker exec -ti 9d5bc0827516 bash

bash-4.2$ mysql -h 127.0.0.1  -uroot -p'1MySQL(Password)'
...

mysql> create database bet;
Query OK, 1 row affected (0.02 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| bet                |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)
```

##### Sqlproxy
```
vagrant@manager:~$ docker exec -ti b631dd00abca bash

root@b631dd00abca:/# mysql -h 127.0.0.1 -P6032 -uadmin -padmin
...

mysql> show tables;
+--------------------------------------+
| tables                               |
+--------------------------------------+
| global_variables                     |
| mysql_collations                     |
| mysql_query_rules                    |
| mysql_replication_hostgroups         |
| mysql_servers                        |
| mysql_users                          |
| runtime_global_variables             |
| runtime_mysql_query_rules            |
| runtime_mysql_replication_hostgroups |
| runtime_mysql_servers                |
| runtime_mysql_users                  |
| runtime_scheduler                    |
| scheduler                            |
+--------------------------------------+
13 rows in set (0.00 sec)

mysql>  SELECT * FROM mysql_servers;
+--------------+-----------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| hostgroup_id | hostname  | port | status | weight | compression | max_connections | max_replication_lag | use_ssl | max_latency_ms | comment |
+--------------+-----------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| 0            | 10.20.1.5 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
| 0            | 10.20.1.6 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
+--------------+-----------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
2 rows in set (0.00 sec)

```
##### Etcd

On local machine
```
$ curl -s localhost:2379/v2/members
{"members":[{"id":"d55d15f6ea07ddc1","name":"etcd-node-01","peerURLs":["http://galera_etcd:2380"],"clientURLs":["http://galera_etcd:2379","http://galera_etcd:4001"]}]}
```

In container:

* image: 'bitnami/etcd:latest'
```
I have no name!@72dcc6d1c1a8:/opt/bitnami/etcd$ etcdctl check perf --endpoints=127.0.0.1:2379
 60 / 60 Booooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo! 100.00% 1m0s
PASS: Throughput is 151 writes/s
PASS: Slowest request took 0.119672s
PASS: Stddev is 0.004519s
PASS
I have no name!@72dcc6d1c1a8:/opt/bitnami/etcd$ etcdctl endpoint status
127.0.0.1:2379, d55d15f6ea07ddc1, 3.4.3, 22 MB, true, false, 2, 9005, 9005, 
I have no name!@72dcc6d1c1a8:/opt/bitnami/etcd$ etcdctl endpoint health
127.0.0.1:2379 is healthy: successfully committed proposal: took = 1.978713ms

```

* quay.io/coreos/etcd
```
# /usr/local/bin/etcdctl cluster-health
member d55d15f6ea07ddc1 is healthy: got healthy result from http://galera_etcd:2379
```

### Troubleshooting

### Useful links

https://github.com/tdi/vagrant-docker-swarm

http://redgreenrepeat.com/2018/10/12/working-with-multiple-node-docker-swarm/

https://otus.ru/nest/post/527/

https://github.com/dmitry-lyutenko/innodb-cluster

http://www.developermarch.com/developersummit/2017/report/downloadPDF/GIDS17_Sujatha%20Sivakumar_Fault-Tolerant%20Systems%20Through%20Group-based%20Replication.pdf

https://galeracluster.com/library/galera-documentation.pdf

https://habr.com/ru/post/423587/

https://www.percona.com/live/17/sites/default/files/slides/EverythingYouNeedToKnowAboutMySQLGroupReplication.pdf

https://github.com/dmitry-lyutenko/percona-proxysql

