
# OTUS Linux admin course

## HW-1 Linux Kernel

### Vagrant

#### Setup 

```
git clone git@github.com:erlong15/otus-linux.git  
cd otuslinux  
vagrant up  
vagrant ssh otuslinux  

$> vagrant status
Current machine states:

otuslinux                 running (virtualbox)
```

#### VBoxManage

```
$> VBoxManage list vms
...
"minikube" {775f362c-1857-452d-81bf-8f31b8d79639}
"otus-linux_otuslinux_1564221752726_9530" {79a54742-18d7-417f-ba48-c356bc321303}

$> VBoxManage showvminfo otus-linux_otuslinux_1564221752726_9530
Name:                        otus-linux_otuslinux_1564221752726_9530
Groups:                      /
Guest OS:                    Red Hat (64-bit)
UUID:                        79a54742-18d7-417f-ba48-c356bc321303
...
Memory size                  1024MB
...
Firmware:                    BIOS
Number of CPUs:              2
...

```

### Build kernel
```
cp /boot/config* .config &&
make oldconfig &&
make &&
make install &&
make modules_install
```

### Results 

Can be seen in files [.config](.config) and [yum.log](yum.log)



# Инструкции

* [Как начать Git](git_quick_start.md)
* [Как начать Vagrant](vagrant_quick_start.md)

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.
