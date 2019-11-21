
# OTUS Linux admin course

## VLAN & Bondig LACP

### How to use this repo

Clone repo, run `vagrant up`. 

- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1
- testServer2- 10.10.10.1

Vlans:
testClient1 <-> testServer1
testClient2 <-> testServer2


### Check VLANS

As you can see we ping same IP but MAC address is different.
#### testClient1
```
[root@testClient1 vagrant]# ip -c -4 -h a
...
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86120sec preferred_lft 86120sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.254.3/30 brd 192.168.254.3 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
5: vlan10@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.10.10.254/24 brd 10.10.10.255 scope global noprefixroute vlan10
       valid_lft forever preferred_lft forever

[root@testClient1 vagrant]# ip -c -4 -h neigh
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
10.10.10.1 dev vlan10 lladdr 08:00:27:3f:f8:bd STALE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE

[root@testClient1 vagrant]# ping  10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.374 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.723 ms
^C
--- 10.10.10.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.374/0.548/0.723/0.176 ms
```

#### testServer1
```
[root@testServer1 vagrant]# ip -c -4 -h a
...
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86066sec preferred_lft 86066sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.254.2/30 brd 192.168.254.3 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
5: vlan10@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute vlan10
       valid_lft forever preferred_lft forever

[root@testServer1 vagrant]# ip -c -4 -h neigh
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 DELAY
10.10.10.254 dev vlan10 lladdr 08:00:27:da:3e:47 STALE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE

```

#### testClient2
```
[root@testClient2 vagrant]# ip -c -4 -h a
...
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86171sec preferred_lft 86171sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.254.5/26 brd 192.168.254.63 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
5: vlan20@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.10.10.254/24 brd 10.10.10.255 scope global noprefixroute vlan20
       valid_lft forever preferred_lft forever

[root@testClient2 vagrant]# ip -c -4 -h neigh
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
10.10.10.1 dev vlan20 lladdr 08:00:27:02:2f:e2 REACHABLE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE

[root@testServer2 vagrant]# ping  10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.024 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.022 ms
^C
--- 10.10.10.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.022/0.023/0.024/0.001 ms
```

#### testServer2
```
[root@testServer2 vagrant]# ip -c -4 -h a
...
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86117sec preferred_lft 86117sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.254.4/28 brd 192.168.254.15 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
5: vlan20@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute vlan20
       valid_lft forever preferred_lft forever

[root@testServer2 vagrant]# ip -c -4 -h neigh
10.10.10.254 dev vlan20 lladdr 08:00:27:d9:65:70 STALE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 DELAY

```

### Bonding

##### centralRouter
```
[root@centralRouter vagrant]# ip -c a show dev bond0 && ip -c a show dev eth1  && ip -c a show dev eth2
2: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:98:13:68 brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.2/30 brd 192.168.255.3 scope global noprefixroute bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe98:1368/64 scope link 
       valid_lft forever preferred_lft forever
4: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:98:13:68 brd ff:ff:ff:ff:ff:ff
5: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:a2:31:61 brd ff:ff:ff:ff:ff:ff
[root@centralRouter vagrant]# cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:98:13:68
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:a2:31:61
Slave queue ID: 0

```

#### inetRouter
```
[root@inetRouter vagrant]# ip -c a show dev bond0 && ip -c a show dev eth1  && ip -c a show dev eth2
2: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:16:1d:64 brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global noprefixroute bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe16:1d64/64 scope link 
       valid_lft forever preferred_lft forever
4: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:16:1d:64 brd ff:ff:ff:ff:ff:ff
5: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:8e:91:2e brd ff:ff:ff:ff:ff:ff
[root@inetRouter vagrant]# cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:16:1d:64
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:8e:91:2e
Slave queue ID: 0
```

#### Test aviability

Run ping on centralRouter. As you can see after kill eth1 on inetRouter have latency but no packets lost.
```
[root@centralRouter vagrant]# ping 192.168.255.1
PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
...
64 bytes from 192.168.255.1: icmp_seq=24 ttl=64 time=0.419 ms
64 bytes from 192.168.255.1: icmp_seq=25 ttl=64 time=0.514 ms
64 bytes from 192.168.255.1: icmp_seq=26 ttl=64 time=1.00 ms  <----
64 bytes from 192.168.255.1: icmp_seq=27 ttl=64 time=1.07 ms  <----
64 bytes from 192.168.255.1: icmp_seq=28 ttl=64 time=0.215 ms
64 bytes from 192.168.255.1: icmp_seq=29 ttl=64 time=0.617 ms
^C
--- 192.168.255.1 ping statistics ---
30 packets transmitted, 30 received, 0% packet loss, time 29002ms
rtt min/avg/max/mdev = 0.215/0.564/1.342/0.243 ms

```

Kill eth1 on inetRouter
```
[root@inetRouter vagrant]# ifdown eth1
Device 'eth1' successfully disconnected.
[root@inetRouter vagrant]# cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:8e:91:2e
Slave queue ID: 0
```

### Troubleshooting


### Useful links
