
# OTUS Linux admin course

## Ansible

### Usage

Clone this repo, run `vagrant up` and you`ll get virtualbox machine with nginz on 8080 port. Provisioning powered by ansible roles and vagrant. 

```
$> vagrant up
Bringing machine 'nginx' up with 'virtualbox' provider...
==> nginx: Importing base box 'centos/7'...
...
PLAY RECAP *********************************************************************
nginx                      : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

==> nginx: Running provisioner: shell...
    nginx: Running: inline script
```

### Create palybook for nginx

#### Config files

* [Ansible config file ansible.cfg](ansible.cfg)
* [Inventory file hosts](stage/hosts)

#### Dir structure

```
$> tree
.
├── ansible.cfg
├── playbooks
│   ├── epel.yml
│   └── nginx.yml
├── README.md
├── staging
│   └── hosts
├── templates
│   └── nginx.conf.j2
└── Vagrantfile
```

#### Playbook example

```
---
- name: NGINX | Install and configure NGINX
  hosts: nginx
  become: true
  vars:
    nginx_listen_port: 8080

  tasks:
    - name: NGINX | Install EPEL Repo package from standart repo
      yum:
        name: epel-release
        state: present
      tags:
        - epel-package
        - packages

    - name: NGINX | Install NGINX package from EPEL Repo
      yum:
        name: nginx
        state: latest
      notify:
        - restart nginx
      tags:
        - nginx-package
        - packages

    - name: NGINX | Create NGINX config file from template
      template:
        src: ../templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify:
        - reload nginx
      tags:
        - nginx-configuration

  handlers:
    - name: restart nginx
      systemd:
        name: nginx
        state: restarted
        enabled: yes
    
    - name: reload nginx
      systemd:
        name: nginx
        state: reloaded
```

#### Some useful commands

Adhoc
```
$> ansible nginx -m ping
nginx | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

Tags (--tags,--skip-tags TAG)
```
$>  ansible-playbook playbooks/nginx.yml --list-tags

playbook: playbooks/nginx.yml

  play #1 (nginx): NGINX | Install and configure NGINX  TAGS: []
      TASK TAGS: [epel-package, nginx-configuration, nginx-package, packages]
```

Run playbook
```
$> ansible-playbook playbooks/nginx.yml

PLAY [NGINX | Install and configure NGINX] **************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************
ok: [nginx]

TASK [NGINX | Install EPEL Repo package from standart repo] *********************************************************************************************************************************
ok: [nginx]

TASK [NGINX | Install NGINX package from EPEL Repo] **********************************************************************************************************************************
ok: [nginx]

TASK [NGINX | Create NGINX config file from template] **********************************************************************************************************************************
changed: [nginx]

RUNNING HANDLER [reload nginx] **********************************************************************************************************************************
changed: [nginx]

PLAY RECAP ***********************************************************************************************************************
nginx                      : ok=5    changed=2    unreachable=0    failed=0 
```

#### Result, check nginx

```
$> curl http://192.168.11.150:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
        <title>Test Page for the Nginx HTTP Server on Fedora</title>
```

### Roles

####  Init nginx role dir

```
$> ansible-galaxy init nginx-role
- nginx-role was created successfully
```

#### Edit files and get
```
$> tree roles/nginx
roles/nginx
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   ├── main.yml
│   └── nginx.yml
├── templates
│   └── nginx.conf.j2
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 10 files
```

#### Play role

```
$> ansible-playbook playbooks/nginx-role.yml 

PLAY [all] *************************************************************************************************

TASK [Gathering Facts] *************************************************************************************
ok: [nginx]

TASK [nginx : NGINX | Install EPEL Repo package from standart repo] ************************************************************************************************************
ok: [nginx]

TASK [nginx : NGINX | Install NGINX package from EPEL Repo] ************************************************************************************************************
ok: [nginx]

TASK [nginx : NGINX | Create NGINX config file from template] *************************************************************************************************************
ok: [nginx]

PLAY RECAP **************************************************************************************************
nginx                      : ok=4    changed=0    unreachable=0    failed=0
```

### Usefull links

https://docs.ansible.com/ansible/latest/user_guide/index.html

https://www.gitbook.com/book/natenka/ansible-dlya-setevih-inzhenerov

http://jinja.pocoo.org/docs/2.10/

https://medium.com/@Nklya/%D0%B4%D0%B8%D0%BD%D0%B0%D0%BC%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5-%D0%B8%D0%BD%D0%B2%D0%B5%D0%BD%D1%82%D0%BE%D1%80%D0%B8-%D0%B2-ansible-9ee880d540d6