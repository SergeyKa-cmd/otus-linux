
# OTUS Linux admin course

## Bridges Tunels VPN

### How to use this repo

Clone repo, cd need dir (tap,tun,ras) and run `vagrant up`.

### OpenVPN

![Net](./openvpn.png?raw=true "Principal scheme")

#### Tunel type - TUN

In openvpn config - `dev tun`

Server
```
[vagrant@vpnserver ~]$ systemctl status openvpn-server@server
● openvpn-server@server.service - OpenVPN service for server
   Loaded: loaded (/usr/lib/systemd/system/openvpn-server@.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-11-23 14:06:06 MSK; 3min 18s ago
...
```

Client
```
[vagrant@client01 ~]$ systemctl status openvpn-client@client
● openvpn-client@client.service - OpenVPN tunnel for client
   Loaded: loaded (/usr/lib/systemd/system/openvpn-client@.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-11-23 14:07:06 MSK; 3min 34s ago
...
```

#### Test connections

* On server

##### Interfaces
```
[vagrant@vpnserver ~]$ ip -c -h -4 a
...
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.100.1/24 brd 192.168.100.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.252.1/28 brd 192.168.252.15 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    inet 10.8.0.1/24 brd 10.8.0.255 scope global tun0
       valid_lft forever preferred_lft forever
```


##### Check internal link on client01
```
[vagrant@vpnserver ~]$ ping 192.168.252.2 -c 3
PING 192.168.252.2 (192.168.252.2) 56(84) bytes of data.
64 bytes from 192.168.252.2: icmp_seq=1 ttl=64 time=0.736 ms
64 bytes from 192.168.252.2: icmp_seq=2 ttl=64 time=0.816 ms
64 bytes from 192.168.252.2: icmp_seq=3 ttl=64 time=0.357 ms

--- 192.168.252.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 0.357/0.636/0.816/0.201 ms
```

##### Check external link on client01
```
[vagrant@vpnserver ~]$ ping 192.168.101.1 -c 3
PING 192.168.101.1 (192.168.101.1) 56(84) bytes of data.
64 bytes from 192.168.101.1: icmp_seq=1 ttl=64 time=1.60 ms
64 bytes from 192.168.101.1: icmp_seq=2 ttl=64 time=0.722 ms
64 bytes from 192.168.101.1: icmp_seq=3 ttl=64 time=1.52 ms

--- 192.168.101.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2014ms
rtt min/avg/max/mdev = 0.722/1.285/1.609/0.399 ms
```

##### Check tunel IP on client01
```
vagrant@vpnserver ~]$ ping 10.8.0.2 -c 3
PING 10.8.0.2 (10.8.0.2) 56(84) bytes of data.
64 bytes from 10.8.0.2: icmp_seq=1 ttl=64 time=0.578 ms
64 bytes from 10.8.0.2: icmp_seq=2 ttl=64 time=1.44 ms
64 bytes from 10.8.0.2: icmp_seq=3 ttl=64 time=1.41 ms

--- 10.8.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 0.578/1.146/1.446/0.403 ms
```

* On client

##### Interfaces
```
[vagrant@client01 ~]$ ip -c -h -4 a
...
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.101.1/24 brd 192.168.101.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.252.2/28 brd 192.168.252.15 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    inet 10.8.0.2/24 brd 10.8.0.255 scope global tun0
       valid_lft forever preferred_lft forever
```

##### Check internal link on vpnserver
```
[vagrant@client01 ~]$ ping 192.168.252.1 -c 3
PING 192.168.252.1 (192.168.252.1) 56(84) bytes of data.
64 bytes from 192.168.252.1: icmp_seq=1 ttl=64 time=0.810 ms
64 bytes from 192.168.252.1: icmp_seq=2 ttl=64 time=0.781 ms
64 bytes from 192.168.252.1: icmp_seq=3 ttl=64 time=0.407 ms

--- 192.168.252.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2007ms
rtt min/avg/max/mdev = 0.407/0.666/0.810/0.183 ms
```

##### Check external link on vpnserver
```
[vagrant@client01 ~]$ ping 192.168.100.1 -c3
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=1.49 ms
64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.626 ms
64 bytes from 192.168.100.1: icmp_seq=3 ttl=64 time=1.53 ms

--- 192.168.100.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 0.626/1.218/1.531/0.421 ms
```

#### Check tunel IP on vpnserver
```
[vagrant@client01 ~]$ ping 10.8.0.1 -c3
PING 10.8.0.1 (10.8.0.1) 56(84) bytes of data.
64 bytes from 10.8.0.1: icmp_seq=1 ttl=64 time=0.475 ms
64 bytes from 10.8.0.1: icmp_seq=2 ttl=64 time=1.48 ms
64 bytes from 10.8.0.1: icmp_seq=3 ttl=64 time=1.46 ms

--- 10.8.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2008ms
rtt min/avg/max/mdev = 0.475/1.140/1.480/0.471 ms
```

#### Test performance

Server
```
[vagrant@vpnserver ~]$ iperf -s -f M
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 0.08 MByte (default)
------------------------------------------------------------
[  4] local 192.168.100.1 port 5001 connected with 10.8.0.2 port 36022
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-32.3 sec  1000 MBytes  31.0 MBytes/sec
```

CLient
```
[vagrant@client01 ~]$  iperf -c 192.168.100.1 -n 1000M -f M
------------------------------------------------------------
Client connecting to 192.168.100.1, TCP port 5001
TCP window size: 0.07 MByte (default)
------------------------------------------------------------
[  3] local 10.8.0.2 port 36022 connected with 192.168.100.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-32.2 sec  1000 MBytes  31.1 MBytes/sec

```


#### Tunel type - TAP

##### Test performance

In openvpn config - `dev tap`

Server
```
[vagrant@vpnserver ~]$ iperf -s -f M
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 0.08 MByte (default)
------------------------------------------------------------
[  4] local 192.168.100.1 port 5001 connected with 10.8.0.2 port 51952
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-33.6 sec  1000 MBytes  29.8 MBytes/sec
```

CLient
```
[vagrant@client01 ~]$ iperf -c 192.168.100.1 -n 1000M -f M
------------------------------------------------------------
Client connecting to 192.168.100.1, TCP port 5001
TCP window size: 0.10 MByte (default)
------------------------------------------------------------
[  3] local 10.8.0.2 port 51952 connected with 192.168.100.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-33.5 sec  1000 MBytes  29.8 MBytes/sec
```

#### Results

As you can see `tun` is has higher Bandwidth than `tap`.

### RAS OpenVPN with local machine client

Interfaces:

* eth0: inet
* eth1 (public): 192.168.0.200/24 - for vpn-connection (ip from local net)
* eth2 (private): 172.16.0.1/24  - internal

On local machine (Ubuntu)

```
# Install soft
sudo apt install bridge-utils openvpn sshpass -y

# Mkdir if needed
mkdir /var/log/openvpn && mkdir /etc/openvpn/keys

# Copy 
sshpass -p "vagrant" scp -o "StrictHostKeyChecking=no" root@192.168.1.200:/vagrant/client.conf /etc/openvpn/client/ &&
sshpass -p "vagrant" scp -o "StrictHostKeyChecking=no" root@192.168.1.200:/usr/share/easy-rsa/3/pki/ca.crt /etc/openvpn/keys/ &&
sshpass -p "vagrant" scp -o "StrictHostKeyChecking=no" root@192.168.1.200:/usr/share/easy-rsa/3/pki/issued/client01.crt /etc/openvpn/keys/ &&
sshpass -p "vagrant" scp -o "StrictHostKeyChecking=no" root@192.168.1.200:/usr/share/easy-rsa/3/pki/private/client01.key /etc/openvpn/keys/ &&
sshpass -p "vagrant" scp -o "StrictHostKeyChecking=no" root@192.168.1.200:/usr/share/easy-rsa/3/ta.key /etc/openvpn/keys/

# restart openvpn-client
systemctl restart openvpn-client@client
```

#### Check status

* Server
```
[vagrant@vpnras ~]$ ip -c -h -4 a
...

3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.1.200/24 brd 192.168.1.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 172.16.0.1/24 brd 172.16.0.255 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
5: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    inet 10.8.0.1/24 brd 10.8.0.255 scope global tun0
       valid_lft forever preferred_lft forever
```

* Client
```
$> ip -c -h -4 a
...
3: wlp5s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.1.1/24 brd 192.168.1.255 scope global dynamic noprefixroute wlp5s0
       valid_lft 76722sec preferred_lft 76722sec
6: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 100
    inet 10.8.0.2/24 brd 10.8.0.255 scope global tun0
       valid_lft forever preferred_lft forever
```

#### Test vpn

```
# On local machine try ping internal ip of rasserver

$> sudo systemctl stop openvpn-client@client

$> ping 172.16.0.1
PING 172.16.0.1 (172.16.0.1) 56(84) bytes of data.
^C
--- 172.16.0.1 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4092ms

# Start vpn

$> sudo systemctl start openvpn-client@client

# Now ping internal ip on rasserver and it works

$> ping 172.16.0.1
PING 172.16.0.1 (172.16.0.1) 56(84) bytes of data.
64 bytes from 172.16.0.1: icmp_seq=1 ttl=64 time=0.468 ms
64 bytes from 172.16.0.1: icmp_seq=2 ttl=64 time=1.00 ms
64 bytes from 172.16.0.1: icmp_seq=3 ttl=64 time=1.10 ms
64 bytes from 172.16.0.1: icmp_seq=4 ttl=64 time=1.35 ms
64 bytes from 172.16.0.1: icmp_seq=5 ttl=64 time=1.10 ms
^C
--- 172.16.0.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4010ms
rtt min/avg/max/mdev = 0.468/1.003/1.346/0.290 ms
```

### Useful links

https://openvpn.net/

https://www.wireguard.com/