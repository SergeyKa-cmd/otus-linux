#!/bin/bash

sudo useradd day && \
sudo useradd night && \
sudo useradd friday

echo "Otus2019" | sudo passwd --stdin day &&\
echo "Otus2019" | sudo passwd --stdin night &&\
echo "Otus2019" | sudo passwd --stdin friday

sudo bash -c "sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service"