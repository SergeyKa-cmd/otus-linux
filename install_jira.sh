#!/bin/bash

wget https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.2.3-x64.bin
chmod +x atlassian-jira-software-7.2.3-x64.bin
sudo bash -c './atlassian-jira-software-7.2.3-x64.bin << EOF
o
1
i
n
EOF'

touch /lib/systemd/system/jira.service
sudo bash -c 'cat << EOF > /usr/lib/systemd/system/jira.service
[Unit] 
Description=Atlassian Jira
After=network.target

[Service] 
Type=forking
User=jira
PIDFile=/opt/atlassian/jira/work/catalina.pid
ExecStart=/opt/atlassian/jira/bin/start-jira.sh
ExecStop=/opt/atlassian/jira/bin/stop-jira.sh

[Install] 
WantedBy=multi-user.target 
EOF'
chmod 664 /lib/systemd/system/jira.service
systemctl daemon-reload
systemctl enable jira.service
systemctl start jira.service
systemctl status jira.service