
# OTUS Linux admin course

## Monitoring Alerting

### How to use this repo

Clone repo. Use `vagrant up` for create VM. 

Use `zabbix` dir for zabbix server installation. 

Use `mon-prom` dir for monitoring stand instalation. First read [Readme](mon-prom/README.md)

For manual install use instruction bellow.

### Zabbix 4.2

#### Server installation

Use official docs:
https://www.zabbix.com/documentation/4.2/manual/installation
https://www.zabbix.com/download?zabbix=4.2&os_distribution=red_hat_enterprise_linux&os_version=7&db=mysql

For RHEL 7:
```
# rpm -ivh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
# yum-config-manager --enable rhel-7-server-optional-rpms
# yum install zabbix-server-mysql zabbix-agent zabbix-web-mysql mariadb httpd
```

Create DB:
```
# /etc/httpd/conf.d/zabbix.conf  <--- set the right timezone for you, by default # php_value date.timezone Europe/Riga
# systemctl start mariadb
# mysql -uroot -p<пароль>
mysql> create database zabbix character set utf8 collate utf8_bin;
mysql> grant all privileges on zabbix.* to zabbix@localhost identified by '<passwd>';
mysql> quit;
```

Import DB:
```
# zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p zabbix
```

Start:
```
# systemctl restart zabbix-server zabbix-agent httpd
# systemctl enable zabbix-server zabbix-agent httpd
```

Web interface http://localhost/zabiix (Admin/zabbix)

#### Install zabbix agent

Install like server but `zabbix-agent` only.

Edit server IP in config `/etc/zabbix/zabbix_agentd.conf`:
```
root@mon:~# egrep -v "^#|^$" /etc/zabbix/zabbix_agentd.conf  
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=192.168.11.150
ServerActive=192.168.11.150
Hostname=Zabbix server
Include=/etc/zabbix/zabbix_agentd.d/*.conf
```

### Prometheus

#### Manual install 

Last releases https://github.com/prometheus/prometheus/releases

Manual https://prometheus.io/docs/prometheus/latest/getting_started/
```
useradd --no-create-home --shell /bin/false prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.12.0/prometheus-2.12.0.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz
cp prometheus-2.12.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.12.0.linux-amd64/promtool /usr/local/bin/
mkdir /etc/prometheus
cp -r prometheus-2.12.0.linux-amd64/consoles /etc/prometheus/consoles
cp -r prometheus-2.12.0.linux-amd64/console_libraries/ /etc/prometheus/console_libraries
cp prometheus-2.12.0.linux-amd64/prometheus.yml /etc/prometheus/
chown -R prometheus:prometheus /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /var/lib/prometheus
vi /etc/systemd/system/prometheus.service         <--- See bellow
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl status prometheus
sudo systemctl enable prometheus
curl 'localhost:9090'
```

/etc/systemd/system/prometheus.service
```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=default.target
```

### Node_exporter 

#### Manual install 

Last releases https://github.com/prometheus/node_exporter/releases

Manual https://www.fosslinux.com/10398/how-to-install-and-configure-prometheus-on-centos-7.htm
```
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar -xvzf node_exporter-0.18.1.linux-amd64.tar.gz
useradd -rs /bin/false nodeusr
vi /etc/systemd/system/node_exporter.service  <--- add to your config node_exporter section see bellow
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
curl 'localhost:9090/metrics'
```

/etc/systemd/system/node_exporter.service
```
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
```

#### Prometheus config with Node exporter

```
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']

# NODE EXPORTER
  - job_name: 'node_exporter_centos'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
```

### Grafana  

#### Manual install 

https://grafana.com/docs/installation/rpm/
```
wget https://dl.grafana.com/oss/release/grafana-6.3.6-1.x86_64.rpm
yum localinstall grafana-6.3.6-1.x86_64.rpm -y
curl 'localhost:3000'  (admin,admin)
```

### Grafite (NOT COMPLETED)

#### Manual install https://graphite.readthedocs.io/en/latest/install-pip.html
```
apt-get install python-dev libcairo2-dev libffi-dev build-essential
mkdir /opt/graphite/
export PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/"
pip install --no-binary=:all: https://github.com/graphite-project/whisper/tarball/master
pip install --no-binary=:all: https://github.com/graphite-project/carbon/tarball/master
pip install --no-binary=:all: https://github.com/graphite-project/graphite-web/tarball/master
mkdir /srv/graphite/
pip install https://github.com/graphite-project/carbon/tarball/master --install-option="--prefix=/srv/graphite" --install-option="--install-lib=/srv/graphite/lib"
pip install https://github.com/graphite-project/graphite-web/tarball/master --install-option="--prefix=/srv/graphite" --install-option="--install-lib=/srv/graphite/webapp"
pip install https://github.com/graphite-project/ceres/tarball/master
```

#### nginx + gunicorn

```
pip install gunicorn
sudo apt install nginx
sudo touch /var/log/nginx/graphite.access.log
sudo touch /var/log/nginx/graphite.error.log
sudo chmod 640 /var/log/nginx/graphite.*
sudo chown www-data:www-data /var/log/nginx/graphite.*
sudo vi /etc/nginx/sites-available/graphite
sudo ln -s /etc/nginx/sites-available/graphite /etc/nginx/sites-enabled
sudo rm -f /etc/nginx/sites-enabled/default
sudo service nginx reload
```

/etc/nginx/sites-available/graphite
```
upstream graphite {
    server 127.0.0.1:8080 fail_timeout=0;
}

server {
    listen 80 default_server;

    server_name HOSTNAME;

    root /opt/graphite/webapp;

    access_log /var/log/nginx/graphite.access.log;
    error_log  /var/log/nginx/graphite.error.log;

    location = /favicon.ico {
        return 204;
    }

    # serve static content from the "content" directory
    location /static {
        alias /opt/graphite/webapp/content;
        expires max;
    }

    location / {
        try_files $uri @graphite;
    }

    location @graphite {
        proxy_pass_header Server;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Scheme $scheme;
        proxy_connect_timeout 10;
        proxy_read_timeout 10;
        proxy_pass http://graphite;
    }
}
```

### Useful links

https://perf.wiki.kernel.org/index.php/Tutorial

https://habr.com/ru/company/otus/blog/459234/

https://www.insight-it.ru/linux/2015/chto-stoit-znat-o-pamiati-v-linux/

https://access.redhat.com/solutions/406773

https://www.geeksforgeeks.org/free-command-linux-examples/

http://catap.ru/blog/2009/05/03/about-memory-oom-killer/

https://www.ibm.com/developerworks/ru/library/au-unix-perfmonsar/index.html

https://otus.ru/nest/post/284/