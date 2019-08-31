
# OTUS Linux admin course

## Boot process

### Change unknown root passwd

#### Interrupt boot with RO fs
Boot GRUB stage, press `e` for edit. Add `rd.break console=tty1` or `init=/bin/sh` to the end of line with `vmlinuz`.

Then remount root with rw option and change passwd
```
switch_root:/# mount | grep sysroot
switch_root:/# mount -o remount,rw /sysroot/
switch_root:/# mount | grep sysroot
switch_root:/# chroot /sysroot
# passwd
```

Swich on autorelabel for se-linux if used
```
# touch /.autorelabel
```

#### Interrupt boot with RW fs

Boot GRUB stage, press `e` for edit. Add `rw init=/sysroot/bin/sh`. Now you`ll have RW fs, no need to remount.

#### Tips

IF boot process hang with `failed to load selinux policy freezing` you can swich off se-linux in grub menu when edit `e` using option `selinux=0`

### Rename root VG

#### Check status
```
[root@otuslinux vagrant]# vgs
  VG               #PV #LV #SN Attr   VSize    VFree
  centos_centoslvm   1   3   0 wz--n- <119,00g 4,00m
[root@otuslinux vagrant]# lvs centos_centoslvm
  LV   VG               Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home centos_centoslvm -wi-ao---- 66,99g                                                    
  root centos_centoslvm -wi-ao---- 50,00g                                                    
  swap centos_centoslvm -wi-ao----  2,00g                                                    
```

#### Rename VG
```
[root@otuslinux vagrant]# vgrename centos_centoslvm root_vg
  Volume group "centos_centoslvm" successfully renamed to "root_vg"
[root@otuslinux vagrant]# vgs
  VG      #PV #LV #SN Attr   VSize    VFree
  root_vg   1   3   0 wz--n- <119,00g 4,00m
```
#### Edit vfstab and grub config

```
[root@otuslinux vagrant]# sed -i 's/centos_centoslvm/root_vg/g' /etc/fstab
[root@otuslinux vagrant]# cat /etc/fstab
...
/dev/mapper/root_vg-root /                       xfs     defaults        0 0
UUID=126a1c52-c5d0-48ec-b2b0-9cb2fda28d89 /boot                   xfs     defaults        0 0
/dev/mapper/root_vg-home /home                   xfs     defaults        0 0
/dev/mapper/root_vg-swap swap                    swap    defaults        0 0

[root@otuslinux vagrant]# sed -i 's/centos_centoslvm/root_vg/g' /boot/grub2/grub.cfg
[root@otuslinux vagrant]# cat /boot/grub2/grub.cfg | grep root_vg
	linux16 /vmlinuz-3.10.0-957.12.2.el7.x86_64 root=/dev/mapper/root_vg-root ro crashkernel=auto rd.lvm.lv=root_vg/root rd.lvm.lv=root_vg/swap rhgb quiet LANG=en_NZ.UTF-8
	linux16 /vmlinuz-0-rescue-c76ad8c81fff4aaf877e1846ef94f610 root=/dev/mapper/root_vg-root ro crashkernel=auto rd.lvm.lv=root_vg/root rd.lvm.lv=root_vg/swap rhgb quiet

```

#### Activate VG and refresh volumes
```
[root@otuslinux vagrant]# vgchange -ay
  3 logical volume(s) in volume group "root_vg" now active
[root@otuslinux vagrant]# lvchange /dev/root_vg/root --refresh
[root@otuslinux vagrant]# lvchange /dev/root_vg/home --refresh
[root@otuslinux vagrant]# lvchange /dev/root_vg/swap --refresh
[root@otuslinux vagrant]# lvs
  LV   VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home root_vg -wi-ao---- 66,99g                                                    
  root root_vg -wi-ao---- 50,00g                                                    
  swap root_vg -wi-ao----  2,00g                 
```

#### Create new initial ramdisk
```
[root@otuslinux vagrant]# cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.$(date +%m-%d-%H%M%S).bak
[root@otuslinux vagrant]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
Executing: /sbin/dracut -f -v /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img 3.10.0-957.12.2.el7.x86_64
...
*** Created microcode section ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-957.12.2.el7.x86_64.img' done ***
[root@otuslinux vagrant]# ls -al /boot/initramfs-3.10.0-957.12.2.el7.x86_64*
-rw-------. 1 root root 21253645 авг 29 08:02 /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img                    <--- NEW
-rw-------. 1 root root 20941385 авг 29 08:01 /boot/initramfs-3.10.0-957.12.2.el7.x86_64.img.08-29-080154.bak   <--- OLD
-rw-------. 1 root root 13114352 июн  3 15:26 /boot/initramfs-3.10.0-957.12.2.el7.x86_64kdump.img
```

#### Reboot and check if everything is ok
```
[root@otuslinux vagrant]# vgs
  VG      #PV #LV #SN Attr   VSize    VFree
  root_vg   1   3   0 wz--n- <119,00g 4,00m
```

### Add module to initrd

```
[root@otuslinux vagrant]# mkdir /usr/lib/dracut/modules.d/01test
[root@otuslinux vagrant]# vi /usr/lib/dracut/modules.d/01test/module_setup.sh
[root@otuslinux vagrant]# vi /usr/lib/dracut/modules.d/01test/test.sh
[root@otuslinux vagrant]# dracut -f -v
Executing: /sbin/dracut -f -v
...
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-957.12.2.el7.x86_64.img' done ***
[root@otuslinux vagrant]#  lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
test
```

### GRUB LVM without boot partition

### We have

```
[vagrant@localhost ~]$ lsblk
NAME                  MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda                     8:0    0  40G  0 disk 
`-sda1                  8:1    0  40G  0 part /
sdb                     8:16   0   8G  0 disk 
```

#### Prepare new disk for migration from sda to lvm on sdb
```
fdisk /dev/sdb (create partition sdb1)
yum install lvm2 lvmutils -y
pvcreate  --bootloaderareasize 1m /dev/sdb1
vgcreate vg-root /dev/sdb1
lvcreate -n lv-root -l +100%FREE /dev/vg-root
mkfs.xfs /dev/vg-root/lv-root
mount /dev/vg-root/lv-root /mnt
rsync -avx  --delete --exclude /dev --exclude /mnt --exclude /proc --exclude /run --exclude /sys / /mnt
for i in /proc/ /sys/ /dev/ /run/ ; do mkdir /mnt/$i; mount --bind $i /mnt/$i; done
```

#### Setup Grub
```
chroot /mnt
sed -i s/UUID=8ac075e3-1124-4bb6-bef7-a6811bf8b870/\/dev\/mapper\/vg--root-lv--root/g' /etc/fstab
sed -i 's/UUID=8ac075e3-1124-4bb6-bef7-a6811bf8b870/\/dev\/mapper\/vg--root-lv--root/g' /boot/grub2/grub.cfg
yum install yum-utils -y
yum-config-manager --add-repo https://yum.rumyantsev.com/centos/7/x86_64/
yum install grub2
dracut -f -v
grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-install /dev/sdb
```

#### Result after boot from second disk
```
[vagrant@localhost ~]$ df -h
Filesystem                     Size  Used Avail Use% Mounted on
/dev/mapper/vg--root-lv--root  8.0G  2.9G  5.1G  37% /
devtmpfs                       488M     0  488M   0% /dev
tmpfs                          496M     0  496M   0% /dev/shm
tmpfs                          496M  6.7M  489M   2% /run
tmpfs                          496M     0  496M   0% /sys/fs/cgroup
tmpfs                          100M     0  100M   0% /run/user/100

[vagrant@localhost ~]$ lsblk
NAME                  MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda                     8:0    0  40G  0 disk 
`-sda1                  8:1    0  40G  0 part 
sdb                     8:16   0   8G  0 disk 
`-sdb1                  8:17   0   8G  0 part 
  `-vg--root-lv--root 253:0    0   8G  0 lvm  /

[root@localhost vagrant]# pvs
  PV         VG      Fmt  Attr PSize  PFree
  /dev/sdb1  vg-root lvm2 a--  <8.00g    0 

[root@localhost vagrant]# lvs
  LV      VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv-root vg-root -wi-ao---- <8.00g           

[root@localhost vagrant]# grep linux16 /boot/grub2/grub.cfg 
	linux16 /boot/vmlinuz-3.10.0-957.12.2.el7.x86_64 root=/dev/mapper/vg--root-lv--root ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto 

```