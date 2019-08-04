#!/bin/bash

# !WARNING! check disk names to be in sure that you will`t lost important data!

# Create Raid5

sudo mdadm --zero-superblock --force /dev/sd{b,c}
sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 --metadata=0.90 /dev/sd{b,c}
sudo mkdir /etc/mdadm
sudo chmod o+w /etc/mdadm
sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# Create and mount FS
sudo parted -s /dev/md0 mklabel gpt

sudo parted /dev/md0 mkpart primary ext4 "0% 100%"

sudo mkfs.ext4 /dev/md0p1
