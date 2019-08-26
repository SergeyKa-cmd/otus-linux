
# OTUS Linux admin course

## Packages and soft distribution 

### RPM build example

Create dirs tree. Run `rpmdev-setuptree` in your home dir.
```
$ rpmdev-setuptree
```

Get sources
```
$ cd ~/rpmbuild/SOURCES
$ wget http://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz
```

Create new spec file
```
$ cd ~/rpmbuild/SPECS
$ rpmdev-newspec hello
$ cat hello.spec 
Name:           hello
Version:        
Release:        1%{?dist}
Summary:        

License:        
URL:            
Source0:        

BuildRequires:  
Requires:       

%description


%prep
%setup -q


%build
%configure
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
%make_install


%files
%doc
```

Edit spec
```
Name:     hello
Version:  2.8
Release:  1
Summary:  The "Hello World" program from GNU
License:  GPLv3+
URL:      http://ftp.gnu.org/gnu/hello    
Source0:  http://ftp.gnu.org/gnu/hello/hello-2.8.tar.gz

%description
The "Hello World" program, done with all bells and whistles of a proper FOSS 
project, including configuration, build, internationalization, help files, etc.

%changelog
```

Try build
```
$ rpmbuild -ba hello.spec
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.NfJikI
+ umask 022
+ cd /home/vagrant/rpmbuild/BUILD
+ cd /home/vagrant/rpmbuild/BUILD
...
RPM build errors:
    Installed (but unpackaged) file(s) found:
   /usr/bin/hello
   /usr/share/info/dir
   /usr/share/info/hello.info.gz
   /usr/share/locale/bg/LC_MESSAGES/hello.mo
...
```

Need to declare in `%files`. Example of spec file:
```
Name:           hello
Version:        2.10
Release:        1%{?dist}
Summary:        The "Hello World" program from GNU

License:        GPLv3+
URL:            http://ftp.gnu.org/gnu/%{name}
Source0:        http://ftp.gnu.org/gnu/%{name}/%{name}-%{version}.tar.gz

BuildRequires: gettext
      
Requires(post): info
Requires(preun): info

%description 
The "Hello World" program, done with all bells and whistles of a proper FOSS 
project, including configuration, build, internationalization, help files, etc.

%prep
%autosetup

%build
%configure
make %{?_smp_mflags}

%install
%make_install
%find_lang %{name}
rm -f %{buildroot}/%{_infodir}/dir

%post
/sbin/install-info %{_infodir}/%{name}.info %{_infodir}/dir || :

%preun
if [ $1 = 0 ] ; then
/sbin/install-info --delete %{_infodir}/%{name}.info %{_infodir}/dir || :
fi

%files -f %{name}.lang
%{_mandir}/man1/hello.1.*
%{_infodir}/hello.info.*
%{_bindir}/hello

%doc AUTHORS ChangeLog NEWS README THANKS TODO
%license COPYING

%changelog
* Fri Aug 23 2019 alf 2.10
- Test rpm build
```

Then build again
```
$ rpmbuild -ba hello.spec
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.l5vrEj
+ umask 022
+ cd /home/vagrant/rpmbuild/BUILD
+ cd /home/vagrant/rpmbuild/BUILD
...
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.Oix9B7
+ umask 022
+ cd /home/vagrant/rpmbuild/BUILD
+ cd hello-2.10
+ /usr/bin/rm -rf /home/vagrant/rpmbuild/BUILDROOT/hello-2.10-1.el7.x86_64
+ exit 0
```

Run `rpmlint`
```
[vagrant@otuslinux SPECS]$ rpmlint hello.spec ../SRPMS/hello* ../RPMS/*/hello*
hello.x86_64: W: incoherent-version-in-changelog 2.10 ['2.10-1.el7', '2.10-1']
hello.x86_64: W: file-not-utf8 /usr/share/doc/hello-2.10/THANKS
hello-debuginfo.x86_64: W: only-non-binary-in-usr-lib
3 packages and 1 specfiles checked; 0 errors, 3 warnings.
```

Now we have such tree
```
[vagrant@otuslinux rpmbuild]$ tree
.
├── BUILD
│   └── hello-2.10
│       ├── ABOUT-NLS
│       ├── aclocal.m4
│       ├── AUTHORS
│       ├── build-aux
│...
│       ├── README
│       ├── README-dev
│       ├── README-release
│       ├── src
│       │   ├── hello.c
│       │   ├── hello.o
│       │   └── system.h
│       ├── stamp-h1
│       ├── tests
│       │   ├── greeting-1
│       │   ├── greeting-2
│       │   ├── hello-1
│       │   ├── last-1
│       │   └── traditional-1
│       ├── THANKS
│       └── TODO
├── BUILDROOT
├── RPMS
│   └── x86_64
│       ├── hello-2.10-1.el7.x86_64.rpm
│       └── hello-debuginfo-2.10-1.el7.x86_64.rpm
├── SOURCES
│   └── hello-2.10.tar.gz
├── SPECS
│   └── hello.spec
└── SRPMS
    └── hello-2.10-1.el7.src.rpm

```

### Create local repo adn publis our rpm

Install nginx first. 

Copy rpm to destination.
```
cp RPMS/x86_64/hello-* /usr/share/nginx/html/RPMS
```

Create repo config
```
$ cat << EOF > /etc/yum.repos.d/alf.repo
[alf]
name=alf
baseurl=http://192.168.11.101/
enabled=1
gpgcheck=0
EOF
$ yum repolist enabled
```

Then create local repo.
```
$ yum install createrepo -y -q
# createrepo /usr/share/nginx/html
Spawning worker 0 with 1 pkgs
Spawning worker 1 with 1 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete

```

List our repo
```
[root@otuslinux rpmbuild]# yum repolist
...
alf                                                | 2.9 kB  00:00:00     
alf/primary_db                                     | 2.2 kB  00:00:00     
repo id           repo name                   status
alf               alf                              2
base/7/x86_64     CentOS-7 - Base             10 019
...
```

Try search our package
```
[root@otuslinux rpmbuild]# yum search hello
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.yandex.ru
 * epel: mirror.yandex.ru
 * extras: mirror.yandex.ru
 * updates: mirror.sale-dedic.com
======================= N/S matched: hello =================
hello.x86_64 : The "Hello World" program from GNU
hello-debuginfo.x86_64 : Debug information for package hello

```

Install
```
[root@otuslinux rpmbuild]# yum install hello
...

Dependencies Resolved

======================================================================
 Package       Arch        Version          Repository         Size
======================================================================
Installing:
 hello         x86_64      2.10-1.el7       alf                 73 k

Transaction Summary
======================================================================
Install  1 Package

Total download size: 73 k
Installed size: 197 k
Is this ok [y/d/N]:
```

### How to test project

#### Prepear

Clone this repo.

Run `vagrant up` to start vbox building hello app and run local repo with it.

Run `docker build --tag=hello .` to build new image witch install hello app inside from vbox local repo.

```
$> docker build --tag=hello .
Sending build context to Docker daemon  758.8kB
Step 1/4 : FROM centos:latest
 ---> 67fa590cfc1c
Step 2/4 : COPY alf.repo /etc/yum.repos.d/alf.repo
 ---> 81fe7de37652
Step 3/4 : RUN yum repolist
 ---> Running in 62edabaf7822
Loaded plugins: fastestmirror, ovl
Determining fastest mirrors
 * base: centos-mirror.rbc.ru
 * extras: centos-mirror.rbc.ru
 * updates: mirror.reconn.ru
repo id                             repo name                             status
alf                                 alf                                       2
base/7/x86_64                       CentOS-7 - Base                       10019
extras/7/x86_64                     CentOS-7 - Extras                       435
updates/7/x86_64                    CentOS-7 - Updates                     2500
repolist: 12956
Removing intermediate container 62edabaf7822
 ---> eb80c84e845a
Step 4/4 : RUN yum install -y hello
 ---> Running in 1cf4d243524b
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: centos-mirror.rbc.ru
 * extras: centos-mirror.rbc.ru
 * updates: mirror.reconn.ru
Resolving Dependencies
--> Running transaction check
---> Package hello.x86_64 0:2.10-1.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package          Arch              Version                Repository      Size
================================================================================
Installing:
 hello            x86_64            2.10-1.el7             alf             73 k

Transaction Summary
================================================================================
Install  1 Package

Total download size: 73 k
Installed size: 197 k
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : hello-2.10-1.el7.x86_64                                      1/1 
install-info: No such file or directory for /usr/share/info/hello.info
  Verifying  : hello-2.10-1.el7.x86_64                                      1/1 

Installed:
  hello.x86_64 0:2.10-1.el7                                                     

Complete!
Removing intermediate container 1cf4d243524b
 ---> 37cb00a31c05
Successfully built 37cb00a31c05
Successfully tagged hello:latest
```

#### Run and check container
 
```
#> docker run -it  hello 
[root@09aa2f6df759 /]# rpm -q hello
hello-2.10-1.el7.x86_64
```


## Useful links

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/rpm_packaging_guide/index

https://rpm-packaging-guide.github.io/

http://wiki.rosalab.ru/ru/index.php/%D0%A1%D0%B1%D0%BE%D1%80%D0%BA%D0%B0_RPM_-_%D0%B1%D1%8B%D1%81%D1%82%D1%80%D1%8B%D0%B9_%D1%81%D1%82%D0%B0%D1%80%D1%82

http://www.opennet.ru/docs/RUS/rpm_guide/
