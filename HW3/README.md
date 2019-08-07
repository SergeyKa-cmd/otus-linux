
# OTUS Linux admin course

## LVM 

### Resize root disk

#### Prepare temp volume

```
[vagrant@otuslinux ~]$ df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00   38G  766M   37G   2% /
devtmpfs                         487M     0  487M   0% /dev
tmpfs                            496M     0  496M   0% /dev/shm
tmpfs                            496M  6.8M  490M   2% /run
tmpfs                            496M     0  496M   0% /sys/fs/cgroup
/dev/sda2                       1014M   63M  952M   7% /boot
tmpfs                            100M     0  100M   0% /run/user/1000
[vagrant@otuslinux ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
|-sda1                    8:1    0    1M  0 part 
|-sda2                    8:2    0    1G  0 part /boot
`-sda3                    8:3    0   39G  0 part 
  |-VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  `-VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   40G  0 disk 
sdc                       8:32   0  250M  0 disk 
sdd                       8:48   0  250M  0 disk 
sde                       8:64   0  250M  0 disk 
sdf                       8:80   0  250M  0 disk 
sdg                       8:96   0  250M  0 disk 
[vagrant@otuslinux ~]$ sudo -s

[root@otuslinux vagrant]# yum install xfsdump
...

[root@otuslinux vagrant]#  pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[root@otuslinux vagrant]# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created
[root@otuslinux vagrant]#  lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.
[root@otuslinux vagrant]# mkfs.xfs /dev/vg_root/lv_root
meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=2621184 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=10484736, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=5119, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@otuslinux vagrant]# mount /dev/vg_root/lv_root /mnt

[root@otuslinux vagrant]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
xfsdump: using file dump (drive_simple) strategy
xfsdump: version 3.1.7 (dump format 3.0)
...
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 11 seconds elapsed
xfsrestore: Restore Status: SUCCESS

[root@otuslinux vagrant]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

[root@otuslinux vagrant]#  chroot /mnt/
[root@otuslinux /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
[root@otuslinux /]#  cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;
> s/.img//g"` --force; done
Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
...
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***

[root@otuslinux boot]# sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/g' /boot/grub2/grub.cfg
[root@otuslinux boot]# reboot


[root@otuslinux vagrant]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
|-sda1                    8:1    0    1M  0 part 
|-sda2                    8:2    0    1G  0 part /boot
`-sda3                    8:3    0   39G  0 part 
  |-VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  `-VolGroup00-LogVol00 253:2    0 37.5G  0 lvm  
sdb                       8:16   0   40G  0 disk 
`-vg_root-lv_root       253:0    0   40G  0 lvm  /
sdc                       8:32   0  250M  0 disk 
sdd                       8:48   0  250M  0 disk 
sde                       8:64   0  250M  0 disk 
sdf                       8:80   0  250M  0 disk 
sdg                       8:96   0  250M  0 disk 
```

#### Resize origin root volume 

```
[root@otuslinux vagrant]# lvremove /dev/VolGroup00/LogVol00
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
  Logical volume "LogVol00" successfully removed
[root@otuslinux vagrant]#  lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  Logical volume "LogVol00" created.
[root@otuslinux vagrant]#  mkfs.xfs /dev/VolGroup00/LogVol00
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@otuslinux vagrant]#  mount /dev/VolGroup00/LogVol00 /mnt
[root@otuslinux vagrant]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
xfsdump: using file dump (drive_simple) strategy
xfsrestore: using file dump (drive_simple) strategy
...
xfsrestore: restore complete: 19 seconds elapsed
xfsrestore: Restore Status: SUCCESS
[root@otuslinux vagrant]#  for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@otuslinux vagrant]# chroot /mnt/
[root@otuslinux /]#  grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
[root@otuslinux /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;
> s/.img//g"` --force; done
Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
...
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```

#### Move var to new volume

```
[root@otuslinux boot]# pvcreate /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.
[root@otuslinux boot]# vgcreate vg_var /dev/sdc /dev/sdd
  Volume group "vg_var" successfully created
[root@otuslinux boot]#  lvcreate -L 240M -m1 -n lv_var vg_var
  Logical volume "lv_var" created.
[root@otuslinux boot]# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.42.9 (28-Dec-2013)
...         
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

[root@otuslinux boot]# mount /dev/vg_var/lv_var /mnt
[root@otuslinux boot]# cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/
[root@otuslinux boot]# ls /mnt/
adm  cache  db  empty  games  gopher  kerberos  lib  local  lock  log  lost+found  mail  nis  opt  preserve  run  spool  tmp  yp
[root@otuslinux boot]# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
[root@otuslinux boot]# umount /mnt
[root@otuslinux boot]# mount /dev/vg_var/lv_var /var
[root@otuslinux boot]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
[root@otuslinux boot]# grep var /etc/fstab 
UUID="95be82e8-4712-426a-815b-e6cd9f0c9860" /var ext4 defaults 0 0

[root@otuslinux vagrant]# reboot 

[root@otuslinux vagrant]# df -h
Filesystem                       Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00  8.0G  765M  7.3G  10% /
devtmpfs                         488M     0  488M   0% /dev
tmpfs                            496M     0  496M   0% /dev/shm
tmpfs                            496M  6.7M  490M   2% /run
tmpfs                            496M     0  496M   0% /sys/fs/cgroup
/dev/sda2                       1014M   61M  954M   6% /boot
/dev/mapper/vg_var-lv_var        229M  136M   78M  64% /var
```

#### Remove unneeded stuf

```
[root@otuslinux vagrant]# lvremove /dev/vg_root/lv_root
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed
[root@otuslinux vagrant]#  vgremove /dev/vg_root
  Volume group "vg_root" successfully removed
[root@otuslinux vagrant]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
```

#### Move home on lvm volume

```
[root@otuslinux vagrant]#  lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
  Logical volume "LogVol_Home" created.
[root@otuslinux vagrant]#  mkfs.xfs /dev/VolGroup00/LogVol_Home
meta-data=/dev/VolGroup00/LogVol_Home isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@otuslinux vagrant]#  mount /dev/VolGroup00/LogVol_Home /mnt/
[root@otuslinux vagrant]# cp -aR /home/* /mnt/ 
[root@otuslinux vagrant]# rm -rf /home/*
[root@otuslinux vagrant]# umount /mnt
[root@otuslinux vagrant]# mount /dev/VolGroup00/LogVol_Home /home
[root@otuslinux vagrant]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
[root@otuslinux vagrant]# grep home /etc/fstab 
UUID="b9829b6e-38d8-4289-822f-9317b5a48c15" /home xfs defaults 0 0
[root@otuslinux vagrant]# df -h
Filesystem                          Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00     8.0G  765M  7.3G  10% /
devtmpfs                            488M     0  488M   0% /dev
tmpfs                               496M     0  496M   0% /dev/shm
tmpfs                               496M  6.7M  490M   2% /run
tmpfs                               496M     0  496M   0% /sys/fs/cgroup
/dev/sda2                          1014M   61M  954M   6% /boot
/dev/mapper/vg_var-lv_var           229M  136M   78M  64% /var
/dev/mapper/VolGroup00-LogVol_Home  2.0G   33M  2.0G   2% /home
```

#### Playing with snapshoot

```
[root@otuslinux vagrant]#  touch /home/file{1..20}
[root@otuslinux vagrant]#  lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
  Rounding up size to full physical extent 128.00 MiB
  Logical volume "home_snap" created.
[root@otuslinux vagrant]#  rm -f /home/file{11..20}
[root@otuslinux vagrant]#  umount /home
[root@otuslinux vagrant]# lvconvert --merge /dev/VolGroup00/home_snap
  Merging of volume VolGroup00/home_snap started.
  VolGroup00/LogVol_Home: Merged: 100.00%
[root@otuslinux vagrant]# mount /home
[root@otuslinux vagrant]# ls /home/
file1  file10  file11  file12  file13  file14  file15  file16  file17  file18  file19  file2  file20  file3  file4  file5  file6  file7  file8  file9  vagrant
```

#### Results

```
[root@otuslinux vagrant]# df -h
Filesystem                          Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00     8.0G  765M  7.3G  10% /
devtmpfs                            488M     0  488M   0% /dev
tmpfs                               496M     0  496M   0% /dev/shm
tmpfs                               496M  6.7M  490M   2% /run
tmpfs                               496M     0  496M   0% /sys/fs/cgroup
/dev/sda2                          1014M   61M  954M   6% /boot
/dev/mapper/vg_var-lv_var           229M  137M   76M  65% /var
/dev/mapper/VolGroup00-LogVol_Home  2.0G   33M  2.0G   2% /home
[root@otuslinux vagrant]# lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
|-sda1                       8:1    0    1M  0 part 
|-sda2                       8:2    0    1G  0 part /boot
`-sda3                       8:3    0   39G  0 part 
  |-VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  |-VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  `-VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  /home
sdb                          8:16   0   40G  0 disk 
sdc                          8:32   0  250M  0 disk 
|-vg_var-lv_var_rmeta_0    253:3    0    4M  0 lvm  
| `-vg_var-lv_var          253:7    0  240M  0 lvm  /var
`-vg_var-lv_var_rimage_0   253:4    0  240M  0 lvm  
  `-vg_var-lv_var          253:7    0  240M  0 lvm  /var
sdd                          8:48   0  250M  0 disk 
|-vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm  
| `-vg_var-lv_var          253:7    0  240M  0 lvm  /var
`-vg_var-lv_var_rimage_1   253:6    0  240M  0 lvm  
  `-vg_var-lv_var          253:7    0  240M  0 lvm  /var
sde                          8:64   0  250M  0 disk 
sdf                          8:80   0  250M  0 disk 
sdg                          8:96   0  250M  0 disk 
```

### Playing with ZFS

Useful link - https://pve.proxmox.com/wiki/ZFS_on_Linux

Don`t forget about to limit zfs memory cache size!

Minumum free space for volume must be more then 20% or you`ll have performance degradation.

#### Install zfs on CentOS

```
[root@otuslinux vagrant]# yum install http://download.zfsonlinux.org/epel/zfs-release.el7_6.noarch.rpm
...
[root@otuslinux vagrant]# yum install kernel-devel zfs
...
[root@otuslinux vagrant]# yum -y update
...
[root@otuslinux vagrant]# reboot

```

#### Create pool and volume

```
[root@otuslinux vagrant]# zpool create testpool sdb sdc sdd
[root@otuslinux vagrant]# zpool status
  pool: testpool
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	testpool    ONLINE       0     0     0
	  sdb       ONLINE       0     0     0
	  sdc       ONLINE       0     0     0
	  sdd       ONLINE       0     0     0

errors: No known data errors

[root@otuslinux vagrant]# zfs create testpool/vol1

[root@otuslinux vagrant]# zfl list
bash: zfl: command not found
[root@otuslinux vagrant]# zfs list
NAME            USED  AVAIL  REFER  MOUNTPOINT
testpool        116K   544M  25,5K  /testpool
testpool/vol1    24K   544M    24K  /testpool/vol1
[root@otuslinux home]# zfs list -o space
NAME           AVAIL   USED  USEDSNAP  USEDDS  USEDREFRESERV  USEDCHILD
testpool        543M   694K        0B     24K             0B       670K
testpool/vol1   543M    40K        0B     40K             0B         0B
```

#### Move opt on zfs volume

```
[root@otuslinux home]# ll /opt
total 0
[root@otuslinux home]# touch /opt/file{1..20}
[root@otuslinux home]# cp -aR /opt/* /testpool/vol1
[root@otuslinux home]# mv /opt /opt_orig
[root@otuslinux home]# zfs set mountpoint=/opt testpool/vol1
[root@otuslinux home]# zfs mount testpool/vol1
[root@otuslinux home]# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        40G  3,4G   37G   9% /
devtmpfs        489M     0  489M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M  6,7M  489M   2% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
tmpfs           100M     0  100M   0% /run/user/1000
testpool        544M  128K  544M   1% /testpool
testpool/vol1   544M  128K  544M   1% /opt
[root@otuslinux home]# ls /opt
file1  file10  file11  file12  file13  file14  file15  file16  file17  file18  file19  file2  file20  file3  file4  file5  file6  file7  file8  file9
```

#### ZFS snapshoots

```
[root@otuslinux home]# zfs snapshot -r testpool/vol1@now
[root@otuslinux home]# zfs list -t snapshot
NAME                USED  AVAIL  REFER  MOUNTPOINT
testpool/vol1@now     0B      -    40K  -
[root@otuslinux home]# rm -f /opt/file{11..20}
[root@otuslinux home]# ls /opt
file1  file10  file2  file3  file4  file5  file6  file7  file8  file9
[root@otuslinux home]# zfs rollback testpool/vol1@now
[root@otuslinux home]# ls /opt
file1  file10  file11  file12  file13  file14  file15  file16  file17  file18  file19  file2  file20  file3  file4  file5  file6  file7  file8  file9
[root@otuslinux home]# zfs list -t snapshot
NAME                USED  AVAIL  REFER  MOUNTPOINT
testpool/vol1@now    15K      -    40K  -
[root@otuslinux home]# zfs list -r -t snapshot -o name,creation 
NAME               CREATION
testpool/vol1@now  Ср авг  7 17:13 2019
[root@otuslinux home]# zfs destroy testpool/vol1@now
[root@otuslinux home]# zfs list -t snapshot
no datasets available

```

#### Add cache to zfs pool

```
[root@otuslinux home]# zpool add -f testpool cache sde
[root@otuslinux home]# zpool status
  pool: testpool
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	testpool    ONLINE       0     0     0
	  sdb       ONLINE       0     0     0
	  sdc       ONLINE       0     0     0
	  sdd       ONLINE       0     0     0
	cache
	  sde       ONLINE       0     0     0

errors: No known data errors

```

#### Create RAIDZ1

```
[root@otuslinux home]# zpool remove  testpool sde
[root@otuslinux home]# zpool create raidpool raidz1 sde sdf sdg
[root@otuslinux home]# zpool status
  pool: raidpool
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	raidpool    ONLINE       0     0     0
	  raidz1-0  ONLINE       0     0     0
	    sde     ONLINE       0     0     0
	    sdf     ONLINE       0     0     0
	    sdg     ONLINE       0     0     0

errors: No known data errors

```

[root_move_log.txt](root_move_log.txt)