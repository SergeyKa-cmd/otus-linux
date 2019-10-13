
# OTUS Linux admin course

## Logging (ELK)

### Important notice

This ansible playbooks inspired(modified clone) by https://github.com/sadsfae/ansible-elk 

For more info about roles read [README](ansible-elk/readme.md)

In this repo we use ELK 7.4.0

### How to use this repo

Clone repo, `cd ansible-elk`, run `vagrant up`. Vagrant will build two machines elk and elkclient. Be patient it can take long time. Make coffee and relax ;)

For manual install run:
```
$> ansible-playbook ./install/elk.yml
$> ansible-playbook ./install/elk_client.yml
```

Go to Kibana Dashboard http://192.168.50.31/app/kibana#/discover? (admin/admin)

![ELK](ansible-elk/image/kibana.png?raw=true "You will see page like this")

### Troubleshooting

If you get nothing in Kibana dashboard please check  and set correct date and TZ. For example:
```
date -s "Sat Oct 12 20:06:00"
timedatectl set-timezone Europe/Moscow
```

### Useful links

Nice roles for ELK:

https://github.com/geerlingguy/ansible-vagrant-examples/tree/master/elk

https://github.com/sadsfae/ansible-elk

---------

https://logz.io/learn/complete-guide-elk-stack

https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns

--------

https://habr.com/company/selectel/blog/267833/

https://www.rsyslog.com/doc/v8-stable/

https://habr.com/company/selectel/blog/226487/

http://geckich.blogspot.com/2013/11/linux-kernel-crash-dump.html

https://xakep.ru/2011/03/30/54897/

https://habr.com/company/southbridge/blog/317182/

https://wiki.russianfedora.pro/index.php?title=ABRT