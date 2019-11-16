
# OTUS Linux admin course

## DNS & DHCP

### How to use this repo

Clone repo, run `vagrant up`. 

#### Vagrant DNS Lab

A Bind's DNS lab with Vagrant and Ansible, based on CentOS 7.

#### Playground

<code>
    vagrant ssh client
</code>

  * zones: dns.lab, reverse dns.lab and ddns.lab
  * ns01 (192.168.50.10)
    * master, recursive, allows update to ddns.lab
  * ns02 (192.168.50.11)
    * slave, recursive
  * client (192.168.50.15)
    * used to test the env, runs rndc and nsupdate
  * zone transfer: TSIG key


### Dns settings

 * ns01 - master DNS-server (192.168.50.10)
 * ns02 - slave DNS-server (192.168.50.11)
 * client - client1 (192.168.50.15)
 * client2 - client2 (192.168.50.16)

#### Zone dns.lab

```
$TTL 3600
$ORIGIN dns.lab.
@               IN      SOA     ns01.dns.lab. root.dns.lab. (
                            2711201407 ; serial
                            3600       ; refresh (1 hour)
                            600        ; retry (10 minutes)
                            86400      ; expire (1 day)
                            600        ; minimum (10 minutes)
                        )

                IN      NS      ns01.dns.lab.
                IN      NS      ns02.dns.lab.

; DNS Servers
ns01            IN      A       192.168.50.10
ns02            IN      A       192.168.50.11
; Web hosts
web1            IN      A       192.168.50.15
web2            IN      A       192.168.50.16
```

Test:

```
[root@ns01 vagrant]# nslookup web1
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web1.dns.lab
Address: 192.168.50.15

[root@ns02 vagrant]# nslookup web1
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web1.dns.lab
Address: 192.168.50.15
```

#### Zone dns.lab Round-robin balanced.

```
$TTL 3600
$ORIGIN newdns.lab.
@               IN      SOA     ns01.newdns.lab. root.newdns.lab. (
                            2711201432 ; serial
                            3600       ; refresh (1 hour)
                            600        ; retry (10 minutes)
                            86400      ; expire (1 day)
                            600        ; minimum (10 minutes)
                        )

                IN      NS      ns01.newdns.lab.
                IN      NS      ns02.newdns.lab.

; DNS Servers
ns01                  IN      A       192.168.50.10
ns02                  IN      A       192.168.50.11
; Web hosts
web           30s     IN      A       192.168.50.15
web           30s     IN      A       192.168.50.16
www                   IN      CNAME   web.newdns.lab.
```

Test:

```
[root@ns02 vagrant]# dig www.newdns.lab +short
web.newdns.lab.
192.168.50.15
192.168.50.16
[root@ns02 vagrant]# dig www.newdns.lab +short
web.newdns.lab.
192.168.50.16
192.168.50.15
```

####  Split-dns configuration

 * client1 - see two zones (dns.lab & newdns.lab), but only web1 in dns.lab
 * client2 - see only dns.lab

split-dns use (view) in /etc/named.conf on master and slave servers (see master-named.conf and slave-named.conf)

Views:

 * client1;
 * client2;
 * internal_subnet;

##### Client 1
```
[root@client vagrant]# nslookup web1
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web1.dns.lab
Address: 192.168.50.15

[root@client vagrant]# nslookup web2
Server:		192.168.50.10
Address:	192.168.50.10#53

** server can't find web2: NXDOMAIN

[root@client vagrant]# nslookup www.newdns.lab
Server:		192.168.50.10
Address:	192.168.50.10#53

www.newdns.lab	canonical name = web.newdns.lab.
Name:	web.newdns.lab
Address: 192.168.50.15
Name:	web.newdns.lab
Address: 192.168.50.16
```

###### Client2
```
[root@client2 vagrant]# nslookup web1
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web1.dns.lab
Address: 192.168.50.15

[root@client2 vagrant]# nslookup web2
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web2.dns.lab
Address: 192.168.50.16

[root@client2 vagrant]#  nslookup www.newdns.lab
Server:		192.168.50.10
Address:	192.168.50.10#53

www.newdns.lab	canonical name = web.newdns.lab.
Name:	web.newdns.lab
Address: 192.168.50.16
Name:	web.newdns.lab
Address: 192.168.50.15
```

### Troubleshooting

If you get error like `/etc/named.conf:161: writeable file '/etc/named/named.newdns.lab': already in use: /etc/named.conf:109` use `in-view`:

```
zone "newdns.lab" {
    in-view "internal_subnet";   <------
};
```

http://www.zytrax.com/books/dns/ch7/zone.html#in-view

### Useful links

http://bundy-dns.de/documentation.html

https://github.com/erlong15/vagrant-bind

http://it2web.ru/index.php/dns/77-split-dns-nauchim-bind-rabotat-na-dva-tri-chetyre-i-bolee-frontov

https://kb.isc.org/article/AA-00851/0/Understanding-views-in-BIND-9-by-example.html

https://habr.com/post/137587/

http://sudouser.com/nastrojka-dynamic-dns-na-baze-bind9-i-nsupdate.html

http://xgu.ru/wiki/%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0_DNS-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0_BIND

https://habr.com/ru/company/oleg-bunin/blog/350550/

https://www.cloudflare.com/dns/dnssec/how-dnssec-works/