
# OTUS Linux admin course

## HW-2 Disk system

Useful commands: 

● fdisk -l

● lsblk

● lshw

● lsscsi

### mdadm

#### Create RAID6
```
[vagrant@otuslinux ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  250M  0 disk 
sdc      8:32   0  250M  0 disk 
sdd      8:48   0  250M  0 disk 
sde      8:64   0  250M  0 disk 
sdf      8:80   0  250M  0 disk

[vagrant@otuslinux ~]$ sudo  lshw -short | grep disk
/0/100/1.1/0.0.0    /dev/sda   disk        42GB VBOX HARDDISK
/0/100/d/0          /dev/sdb   disk        262MB VBOX HARDDISK
/0/100/d/1          /dev/sdc   disk        262MB VBOX HARDDISK
/0/100/d/2          /dev/sdd   disk        262MB VBOX HARDDISK
/0/100/d/3          /dev/sde   disk        262MB VBOX HARDDISK
/0/100/d/0.0.0      /dev/sdf   disk        262MB VBOX HARDDISK
[vagrant@otuslinux ~]$ sudo fdisk -l

Disk /dev/sda: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x0009ef88

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048    83886079    41942016   83  Linux

Disk /dev/sdb: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
...

[vagrant@otuslinux ~]$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf

[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>

[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid6 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=5aca707f:f4100f38:55fc2109:645115cb
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf
```

#### Make config file

```
[vagrant@otuslinux ~]$ sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
[vagrant@otuslinux ~]$ cat /etc/mdadm/mdadm.conf
DEVICE partitions
ARRAY /dev/md0 level=raid6 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=5aca707f:f4100f38:55fc2109:645115cb
```

### Repair failed disk

```
[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --fail /dev/sde
mdadm: set /dev/sde faulty in /dev/md0

[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UUU_U]
      
unused devices: <none>

[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sde
mdadm: hot removed /dev/sde from /dev/md0

[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sde
mdadm: added /dev/sde

[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sde[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
      [========>............] recovery = 44.6% (113664/253952) finish=0.0min
speed=113664K/sec

unused devices: <none>

[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Wed Jul 31 18:14:15 2019
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Wed Jul 31 18:39:34 2019
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 5aca707f:f4100f38:55fc2109:645115cb
            Events : 39

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       5       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
```

#### Script for configure RAID

```
[vagrant@otuslinux ~]$ cat /tmp/raid.sh
!#/bin/bash

sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
sudo mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
sudo mkdir /etc/mdadm
sudo chmod o+w /etc/mdadm
sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
```

### Create GPT partitions

```
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 0% 20%
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 20% 40%
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 40% 60%
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 60% 80%
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.

[root@otuslinux ~]#  for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks: 
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done
...

[root@otuslinux ~]# mkdir -p /raid/part{1,2,3,4,5}
[root@otuslinux ~]# for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
[root@otuslinux ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        40G  4.1G   36G  11% /
devtmpfs        488M     0  488M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M  6.7M  489M   2% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
tmpfs           100M     0  100M   0% /run/user/1000
/dev/md0p1      139M  1.6M  127M   2% /raid/part1
/dev/md0p2      140M  1.6M  128M   2% /raid/part2
/dev/md0p3      142M  1.6M  130M   2% /raid/part3
/dev/md0p4      140M  1.6M  128M   2% /raid/part4
/dev/md0p5      139M  1.6M  127M   2% /raid/part5
```



### Move root on RAID (CentOS)

#### Turn off SElinux before if it`s on.
```
Edit the /etc/selinux/config file to set the  SELINUX parameter to  disabled, and then reboot the server.
```

#### Create partition
```
parted /dev/sdb mklabel
parted /dev/sdb mkpart primary ext4 0% 100%
```
or
```
sfdisk -d /dev/sda | sfdisk /dev/sdb
fdisk /dev/sdb (change by t:  id 83 on fd )
```

#### Create raid1 on one disk
```
mdadm --create --verbose /dev/md0 --level=mirror --raid-devices=2 --metadata=0.90 missing /dev/sdb1
mkfs.ext4 /dev/md0
```

#### Mount and copy data
```
mount /dev/md0 /mnt
cd /mnt
mkdir -p dev/ mnt/ proc/ sys/ run/
rsync -avx -n --delete --exclude /dev --exclude /mnt --exclude /proc --exclude /run --exclude /sys / /mnt
rsync -avx  --delete --exclude /dev --exclude /mnt --exclude /proc --exclude /run --exclude /sys / /mnt
```
or
```
dd if=/dev/sda of=/dev/md0 bs=4k
xfs_admin -U generate /dev/md0
```

#### Mount new partition for chroot
```
mount --bind /proc /mnt/proc && mount --bind /dev /mnt/dev && mount --bind /sys /mnt/sys && mount --bind /run /mnt/run && chroot /mnt/
```

#### Change UUID in fstab
```
blkid | grep /dev/md
sed -i 's/old_UUID/new_UUID/g' /mnt/etc/fstab
```
or
```
sed -i 's/UUID=old_UUID/\/dev\/md0/g' /mnt/etc/fstab
```

#### Set new config and create new initrd and grub
```
mdadm --detail --scan > /etc/mdadm.conf
vim /etc/default/grub (add rd.auto=1 to GRUB_CMDLINE_LINUX)
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-install /dev/sdb
dracut --force
touch /SECOND_DISK
reboot
```

#### After reboot add second disk to raid
```
fdisk /dev/sdc (change by t:  id 83 on fd )
mdadm --manage /dev/md0 --add /dev/sdc1
grub2-install /dev/sdc
```

#### Example of console log from real system can be seen here [root_move_log.txt](root_move_log.txt)