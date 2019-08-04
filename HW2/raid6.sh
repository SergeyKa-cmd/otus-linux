#!/bin/bash

# !WARNING! check disk names to be in sure that you will`t lost important data!

# Create Raid5
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
sudo mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
sudo mkdir /etc/mdadm
sudo chmod o+w /etc/mdadm
sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# Create and mount FS
sudo parted -s /dev/md0 mklabel gpt

for i in "0% 20%" "20% 40%" "40% 60%" "60% 80%" "80% 100%"; do
   sudo parted /dev/md0 mkpart primary ext4 $i 
done

for i in $(seq 1 5); do 
   sudo mkfs.ext4 /dev/md0p$i
done

sudo mkdir -p /raid/part{1,2,3,4,5}

for i in $(seq 1 5);do 
   sudo mount /dev/md0p$i /raid/part$i
   echo "/dev/md0p$i     /raid/part$i     ext4    defaults    0   0" >> /etc/fstab
done