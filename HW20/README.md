
# OTUS Linux admin course

## Net Filters

### How to use this repo

Clone repo, run `vagrant up`.

![Net](./hw-ip-traf.jpg?raw=true "Principal scheme")

#### Port knocking

All rules in inetrouter.rules.

```
[vagrant@centralRouter ~]$ telnet 192.168.255.1 22
Trying 192.168.255.1...
^C
[vagrant@centralRouter ~]$ sudo ./knock.sh 192.168.255.1 8881 7777 9991

Starting Nmap 6.40 ( http://nmap.org ) at 2019-11-06 15:51 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00028s latency).
PORT     STATE    SERVICE
8881/tcp filtered unknown
MAC Address: 08:00:27:78:75:9D (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.17 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2019-11-06 15:51 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00032s latency).
PORT     STATE    SERVICE
7777/tcp filtered cbt
MAC Address: 08:00:27:78:75:9D (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.16 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2019-11-06 15:51 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00025s latency).
PORT     STATE    SERVICE
9991/tcp filtered issa
MAC Address: 08:00:27:78:75:9D (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.16 seconds

[vagrant@centralRouter ~]$  ssh vagrant@192.168.255.1
vagrant@192.168.255.1's password:
Last login: Wed Nov  6 15:49:45 2019 from 192.168.255.2
[vagrant@inetRouter ~]$

```

#### Test nginx on centralServer

```
[root@centralServer vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2019-11-06 16:26:36 UTC; 5min ago
...

[root@centralServer vagrant]# curl 192.168.0.2:80
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
  <style rel="stylesheet" type="text/css">
...
```

#### Firewalld port forwarding

```
[root@inetRouter2 vagrant]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth2 eth0
  sources:
  services: ssh dhcpv6-client
  ports:
  protocols:
  masquerade: no
  forward-ports: port=8080:proto=tcp:toport=80:toaddr=192.168.0.2
  source-ports:
  icmp-blocks:
  rich rules:

[root@inetRouter2 vagrant]# firewall-cmd --list-all --zone=internal
internal (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth1
  sources:
  services: ssh mdns samba-client dhcpv6-client
  ports:
  protocols:
  masquerade: yes
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

![Port forwarding](./port-forward.jpg?raw=true "Nginx web page")

#### Default router to internet

```
[vagrant@centralServer ~]$ tracepath -n yandex.ru
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.0.1                                           1.131ms 
 1:  192.168.0.1                                           0.961ms 
 2:  192.168.255.1                                         1.934ms 
 3:  no reply
 4:  no reply
 5:  no reply
 6:  10.109.11.6                                          11.079ms asymm 64 
 7:  212.188.1.5                                           9.476ms asymm 63 
 8:  195.34.50.73                                         10.986ms asymm 62 
 9:  212.188.55.2                                         10.072ms asymm 61 
10:  212.188.2.230                                        11.505ms asymm 60 
11:  no reply

```

### Useful links

https://www.opennet.ru/docs/RUS/iptables/

https://www.kernel.org/doc/Documentation/networking/nf_conntrack-sysctl.txt

https://ru.wikibooks.org/wiki/Iptables

https://habr.com/post/136871/

https://fedoraproject.org/wiki/FirewallD/ru

https://14bytes.ru/blokirovat-li-icmp-trafik-bezopasno-li/

https://www.kernel.org/doc/Documentation/networking/tproxy.txt

http://ipset.netfilter.org/features.html

https://wiki.archlinux.org/index.php/Port_knocking

https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html

https://binarylife.ru/iptables-u32-uchebnik/

https://www.opennet.ru/tips/2928_linux_iptables_synflood_synproxy_ddos.shtml
