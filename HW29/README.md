
# OTUS Linux admin course

## Mysql InnoDB cluster

### How to use this repo

### Swarm

Clone repo, run `vagrant up` you`ll get:
```
$ vagrant status
Current machine states:

manager                   running (virtualbox)
worker1                   running (virtualbox)
worker2                   running (virtualbox)
```

#### Login to manager `docker ssh manager` and run `docker swarm init`

Example:
```
vagrant@manager:/vagrant$ docker swarm init --advertise-addr 192.168.10.2
Swarm initialized: current node (qriy6prjlfvuu8zfmakpsz1te) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-4lvwnzf4o9rc9ssdbq3367gc4d4wiuv387z1vd59bode9iy2l0-4sqn1hgghpeyhoii0p82yc40k \
    192.168.10.2:2377
```

#### On all workers run `docker swarm join ...`
```
vagrant@worker1:~$  docker swarm join \
>     --token SWMTKN-1-4lvwnzf4o9rc9ssdbq3367gc4d4wiuv387z1vd59bode9iy2l0-4sqn1hgghpeyhoii0p82yc40k \
>     192.168.10.2:2377
This node joined a swarm as a worker.
```

#### After on master  `docker stack deploy -c percona-cluster.yml percona`:
```
vagrant@manager:/vagrant$ docker stack deploy -c percona-cluster.yml percona
Creating network percona_galera
Creating service percona_proxy
Creating service percona_galera_etcd
Creating service percona_percona-xtradb-cluster
vagrant@manager:/vagrant$ docker service ls
ID                  NAME                             MODE                REPLICAS            IMAGE                                PORTS
349i3uarhk3l        percona_galera_etcd              replicated          0/1                 quay.io/coreos/etcd:latest           
8g0t496c0nrx        percona_percona-xtradb-cluster   replicated          0/3                 percona/percona-xtradb-cluster:5.7   
ciya8wz39wkq        percona_proxy                    replicated          0/1                 perconalab/proxysql:latest           *:3306->3306/tcp,*:6032->6032/tcp

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


vagrant@manager:/vagrant$ docker ps
CONTAINER ID        IMAGE                        COMMAND             CREATED             STATUS              PORTS                NAMES
83544a622370        perconalab/proxysql:latest   "/entrypoint.sh "   17 seconds ago      Up 17 seconds       3306/tcp, 6032/tcp   percona_proxy.1.nei1pxce1ttfj5izywkmxoy39
f1ab16a7f319        quay.io/coreos/etcd:latest   "etcd"              21 seconds ago      Up 21 seconds                            percona_galera_etcd.1.z7tm2uybs906i3zna3nhhnsjq
```

On workers:
```
vagrant@worker1:~$ docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS               NAMES
a7e2358ff917        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh my..."   27 seconds ago      Up 21 seconds                           percona_percona-xtradb-cluster.m7ycem64frbyxs2bhjbbiczbn.03op6sij7nr3dq74f1ppdtns2
```

For destroy
```
vagrant@manager:/vagrant$ docker stack rm percona
Removing service percona_galera_etcd
Removing service percona_percona-xtradb-cluster
Removing service percona_proxy
Removing network percona_galera

$ docker swarm leave --force
Node left the swarm.
```

### Docker-compose

* UP
```
$ docker-compose up -d
Creating network "hw29_default" with the default driver
Creating hw29_proxy_1 ... 
Creating hw29_galera_etcd_1 ... 
Creating hw29_percona-xtradb-cluster_1 ... 
Creating hw29_galera_etcd_1
Creating hw29_proxy_1
Creating hw29_percona-xtradb-cluster_1 ... done

$ docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                                                NAMES
d69d726cdb4d        perconalab/proxysql                  "/entrypoint.sh "        4 seconds ago       Up 3 seconds        127.0.0.1:3306->3306/tcp, 127.0.0.1:6032->6032/tcp   hw29_proxy_1
44498214017a        percona/percona-xtradb-cluster:5.7   "/entrypoint.sh mysq…"   4 seconds ago       Up 3 seconds        3306/tcp, 4567-4568/tcp                              hw29_percona-xtradb-cluster_1
c7aa2367c204        quay.io/coreos/etcd                  "etcd"                   4 seconds ago       Up 3 seconds        127.0.0.1:2379->2379/tcp, 2380/tcp                   hw29_galera_etcd_1
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

### Check cluster state

#### Percona
```
$ docker exec -ti 9d5bc0827516 bash

bash-4.2$ mysql  mysql -h 127.0.0.1  -uroot -p'1MySQL(Password)'
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

#### Sqlproxy
```
$ docker exec -ti d69d726cdb4d bash

root@8e822f06ae82:/# /usr/bin/add_cluster_nodes.sh
Waiting proxysql
waiting_discovery_service
Nodes - 0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   262  100   262    0     0  48844      0 --:--:-- --:--:-- --:--:-- 52400
172.23.0.4
mysql: [Warning] Using a password on the command line interface can be insecure.
mysql: [Warning] Using a password on the command line interface can be insecure.
mysql: [Warning] Using a password on the command line interface can be insecure.
mysql: [Warning] Using a password on the command line interface can be insecure.

^C

root@d69d726cdb4d:/# mysql -h 127.0.0.1 -P6032 -uadmin -padmin
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.5.30 (ProxySQL Admin Module)
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
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| hostgroup_id | hostname   | port | status | weight | compression | max_connections | max_replication_lag | use_ssl | max_latency_ms | comment |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
| 0            | 172.23.0.4 | 3306 | ONLINE | 1      | 0           | 1000            | 20                  | 0       | 0              |         |
+--------------+------------+------+--------+--------+-------------+-----------------+---------------------+---------+----------------+---------+
1 row in set (0.00 sec)
```

#### Etcd
 
```
$ curl -s localhost:2379/v2/members
{"members":[{"id":"d55d15f6ea07ddc1","name":"etcd-node-01","peerURLs":["http://galera_etcd:2380"],"clientURLs":["http://galera_etcd:2379","http://galera_etcd:4001"]}]}
```

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

![Net](./name.jpg?raw=true "Principal scheme")

### Stend config


### Troubleshooting


### Useful links

https://github.com/tdi/vagrant-docker-swarm

http://redgreenrepeat.com/2018/10/12/working-with-multiple-node-docker-swarm/