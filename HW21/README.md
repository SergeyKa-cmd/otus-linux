
# OTUS Linux admin course

## OSFP

### How to use this repo

Clone repo, run `vagrant up`. 

![Net](./hw-ip-traf.jpg?raw=true "Principal scheme")

### Stand config

#### Check config of routers

```
[vagrant@router1 ~]$ ip -h -4 -c a
...
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute eth3
       valid_lft forever preferred_lft forever
6: vlan30@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.30.2/24 brd 192.168.30.255 scope global noprefixroute vlan30
       valid_lft forever preferred_lft forever
7: vlan10@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.10.1/24 brd 192.168.10.255 scope global noprefixroute vlan10
       valid_lft forever preferred_lft forever

```

```
[vagrant@router2 ~]$ ip -h -4 -c a
...
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.20.20.1/24 brd 10.20.20.255 scope global noprefixroute eth3
       valid_lft forever preferred_lft forever
6: vlan20@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.20.1/24 brd 192.168.20.255 scope global noprefixroute vlan20
       valid_lft forever preferred_lft forever
7: vlan10@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.10.2/24 brd 192.168.10.255 scope global noprefixroute vlan10
       valid_lft forever preferred_lft forever

```

```
[vagrant@router3 ~]$ ip -h -4 -c a
...
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 10.30.30.1/24 brd 10.30.30.255 scope global noprefixroute eth3
       valid_lft forever preferred_lft forever
6: vlan20@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.20.2/24 brd 192.168.20.255 scope global noprefixroute vlan20
       valid_lft forever preferred_lft forever
7: vlan30@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.30.1/24 brd 192.168.30.255 scope global noprefixroute vlan30
       valid_lft forever preferred_lft forever

```

#### OSPF commands

```
[vagrant@router1 ~]$ sudo vtysh

Hello, this is Quagga (version 0.99.22.4).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# show ip ospf database

       OSPF Router with ID (10.10.10.1)

                Router Link States (Area 0.0.0.0)

Link ID         ADV Router      Age  Seq#       CkSum  Link count
10.10.10.1      10.10.10.1       929 0x80000039 0x4c70 2
10.20.20.1      10.20.20.1       851 0x80000038 0xf5b4 2
10.30.30.1      10.30.30.1       590 0x80000038 0x0852 2

                Net Link States (Area 0.0.0.0)

Link ID         ADV Router      Age  Seq#       CkSum
192.168.10.2    10.20.20.1       360 0x8000002e 0xd25f
192.168.20.1    10.20.20.1       880 0x8000002e 0x14ec
192.168.30.2    10.10.10.1       949 0x8000002e 0xe637

                Summary Link States (Area 0.0.0.0)

Link ID         ADV Router      Age  Seq#       CkSum  Route
10.10.10.0      10.10.10.1       849 0x8000002f 0x13d4 10.10.10.0/24
10.20.20.0      10.20.20.1      1201 0x8000002f 0x952a 10.20.20.0/24
10.30.30.0      10.30.30.1       870 0x8000002f 0x187f 10.30.30.0/24

                Router Link States (Area 0.0.0.1)

Link ID         ADV Router      Age  Seq#       CkSum  Link count
10.10.10.1      10.10.10.1       859 0x80000032 0xa614 1

                Summary Link States (Area 0.0.0.1)

Link ID         ADV Router      Age  Seq#       CkSum  Route
10.20.20.0      10.10.10.1       869 0x8000002e 0x9238 10.20.20.0/24
10.30.30.0      10.10.10.1      1089 0x8000002e 0xab0b 10.30.30.0/24
192.168.10.0    10.10.10.1       339 0x8000002f 0x5c36 192.168.10.0/24
192.168.20.0    10.10.10.1      1359 0x8000002e 0x542b 192.168.20.0/24
192.168.30.0    10.10.10.1       909 0x8000002f 0x7ffe 192.168.30.0/24


router1# show ip ospf neighbor

    Neighbor ID Pri State           Dead Time Address         Interface            RXmtL RqstL DBsmL
10.30.30.1        1 Full/Backup       39.087s 192.168.30.1    vlan30:192.168.30.2      0     0     0
10.20.20.1        1 Full/DR           36.853s 192.168.10.2    vlan10:192.168.10.1      0     0     0
router1# show ip ospf border-routers
============ OSPF router routing table =============
R    10.20.20.1            [10] area: 0.0.0.0, ABR
                           via 192.168.10.2, vlan10
R    10.30.30.1            [10] area: 0.0.0.0, ABR
                           via 192.168.30.1, vlan30

router1# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, A - Babel,
       > - selected route, * - FIB route

K>* 0.0.0.0/0 via 10.0.2.2, eth0
C>* 10.0.2.0/24 is directly connected, eth0
O   10.10.10.0/24 [110/10] is directly connected, eth3, 22:47:06
C>* 10.10.10.0/24 is directly connected, eth3
O>* 10.20.20.0/24 [110/20] via 192.168.10.2, vlan10, 22:46:07
O>* 10.30.30.0/24 [110/20] via 192.168.30.1, vlan30, 22:45:32
C>* 127.0.0.0/8 is directly connected, lo
O   192.168.10.0/24 [110/10] is directly connected, vlan10, 22:47:08
C>* 192.168.10.0/24 is directly connected, vlan10
O>* 192.168.20.0/24 [110/20] via 192.168.30.1, vlan30, 22:45:23
  *                          via 192.168.10.2, vlan10, 22:45:23
O   192.168.30.0/24 [110/10] is directly connected, vlan30, 22:47:08
C>* 192.168.30.0/24 is directly connected, vlan30

router1# show ip ospf route
============ OSPF network routing table ============
N    10.10.10.0/24         [10] area: 0.0.0.1
                           directly attached to eth3
N IA 10.20.20.0/24         [20] area: 0.0.0.0
                           via 192.168.10.2, vlan10
N IA 10.30.30.0/24         [20] area: 0.0.0.0
                           via 192.168.30.1, vlan30
N    192.168.10.0/24       [10] area: 0.0.0.0
                           directly attached to vlan10
N    192.168.20.0/24       [20] area: 0.0.0.0
                           via 192.168.30.1, vlan30
                           via 192.168.10.2, vlan10
N    192.168.30.0/24       [10] area: 0.0.0.0
                           directly attached to vlan30

============ OSPF router routing table =============
R    10.20.20.1            [10] area: 0.0.0.0, ABR
                           via 192.168.10.2, vlan10
R    10.30.30.1            [10] area: 0.0.0.0, ABR
                           via 192.168.30.1, vlan30

============ OSPF external routing table ===========

```

#### Check route paths

```
[vagrant@router1 ~]$ tracepath 10.10.10.1;tracepath 10.20.20.1;tracepath 10.30.30.1
 1:  router1                                               0.077ms reached
     Resume: pmtu 65535 hops 1 back 1 
 1?: [LOCALHOST]                                         pmtu 1500
 1:  10.20.20.1                                            0.433ms reached
 1:  10.20.20.1                                            0.958ms reached
     Resume: pmtu 1500 hops 1 back 1 
 1?: [LOCALHOST]                                         pmtu 1500
 1:  10.30.30.1                                            1.097ms reached
 1:  10.30.30.1                                            0.262ms reached
```

### Set asymetric route 

Add COST 1000 on vlan30 on router1. Run `$ ansible-playbook -i ./hosts ./playbook-asymm-route.yml` 

Check

```
router1# show ip ospf database router

       OSPF Router with ID (10.10.10.1)


                Router Link States (Area 0.0.0.0)

  LS age: 281
  Options: 0x2  : *|-|-|-|-|-|E|*
  LS Flags: 0x3  
  Flags: 0x1 : ABR
  LS Type: router-LSA
  Link State ID: 10.10.10.1 
  Advertising Router: 10.10.10.1
  LS Seq Number: 8000006f
  Checksum: 0x2d78
  Length: 48
   Number of Links: 2

    Link connected to: a Transit Network
     (Link ID) Designated Router address: 192.168.10.2
     (Link Data) Router Interface address: 192.168.10.1
      Number of TOS metrics: 0
       TOS 0 Metric: 10

    Link connected to: a Transit Network
     (Link ID) Designated Router address: 192.168.30.1
     (Link Data) Router Interface address: 192.168.30.2
      Number of TOS metrics: 0
       TOS 0 Metric: 1000          <---------- COST

```
Check trace
```
[root@router1 vagrant]# tracepath 10.30.30.1
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.10.2                                          0.391ms 
 1:  192.168.10.2                                          0.313ms 
 2:  10.30.30.1                                            0.598ms reached
     Resume: pmtu 1500 hops 2 back 2 

[vagrant@router3 ~]$ tracepath -n 10.10.10.1
 1?: [LOCALHOST]                                         pmtu 1500
 1:  10.10.10.1                                            0.312ms reached
 1:  10.10.10.1                                            0.249ms reached
     Resume: pmtu 1500 hops 1 back 1 
```

### Set symetric route  with COST

Add COST 1000 on vlan30 on router1 and router3 . Run `$ ansible-playbook -i ./hosts ./palybook-symm-route-cost.yml` 

Result
```
[root@router1 vagrant]# tracepath -n 10.30.30.1
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.10.2                                          1.045ms 
 1:  192.168.10.2                                          0.815ms 
 2:  10.30.30.1                                            1.452ms reached
     Resume: pmtu 1500 hops 2 back 2 

[vagrant@router3 ~]$ tracepath -n 10.10.10.1
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.20.1                                          0.285ms 
 1:  192.168.20.1                                          0.173ms 
 2:  10.10.10.1                                            0.354ms reached
     Resume: pmtu 1500 hops 2 back 2 

```

### Troubleshooting

If you in console have ansible-playbook error with `Permission denied publickey` try run again `vagrant provision`

```
fatal: [router3]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: vagrant@127.0.0.1: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).\r\n", "unreachable": true}
```

### Useful links

https://www.cisco.com/c/dam/en/us/products/collateral/ios-nx-os-software/ip-multicast/prod_presentation0900aecd80310883.pdf

http://xgu.ru/wiki/IP_Multicast

http://blog.sbolshakov.ru/obzor-protocola-ospf/

http://blog.sbolshakov.ru/1-1-terminy-i-opredeleniya-v-ospf/

https://ru.bmstu.wiki/OSPF_(Open_Shortest_Path_First)

https://otus.ru/media/90/2b/%D0%9C%D0%B0%D1%80%D1%88%D1%80%D1%83%D1%82%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F_%D0%B2_%D1%81%D0%B5%D1%82%D1%8F%D1%85_ipv4__cut_version-54017-902be8.pdf

https://q05t9n.wordpress.com/2015/10/01/1-%D0%B2%D0%B2%D0%B5%D0%B4%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-ospf/

