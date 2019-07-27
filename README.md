
# OTUS Linux admin course

## HW-1 Linux Kernel

### Setup vagrant

```
git clone git@github.com:erlong15/otus-linux.git  
cd otuslinux  
vagrant up  
vagrant ssh otuslinux  
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

See files [.config](.config) and [yum.log](yum.log)


# Инструкции

* [Как начать Git](git_quick_start.md)
* [Как начать Vagrant](vagrant_quick_start.md)

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.
