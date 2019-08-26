#!/bin/bash

# Vars

rpmSrcLink=http://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz

# Main

# Create rpm hello
sudo rpmdev-setuptree
cd ~/rpmbuild/SOURCES
wget $rpmSrcLink
cd ~/rpmbuild/SPECS
sudo bash -c 'cat << EOF > hello.spec
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

EOF'
rpmbuild -ba hello.spec

# create repo
sudo mkdir /usr/share/nginx/html/repo
sudo cp ~/rpmbuild/RPMS/x86_64/hello-* /usr/share/nginx/html/repo
sudo createrepo /usr/share/nginx/html/repo/
sudo bash -c 'cat << EOF > /etc/yum.repos.d/alf.repo
[alf]
name=alf
baseurl=http://192.168.11.101/repo
enabled=1
gpgcheck=0
EOF'
sudo systemctl start nginx
yum repolist enabled