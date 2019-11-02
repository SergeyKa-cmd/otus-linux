
# OTUS Linux admin course

## Ldap

### How to use this repo

Vagrant uses ansible roles for deploy FreeIpa. Clone repo, run `cd HW19`.

Clone ansible freeipa `git clone https://github.com/freeipa/ansible-freeipa.git`

Run `vagrant up`. You will get two machines, ipaserver and ipaclient.

![FreeIPA](./ipa_ldap.jpg?raw=true "Free IPA web page example")

### Client install

#### Manual run (example)

```
[root@ipaclient vagrant]# ipa-client-install --domain=test.local --server=ipaserver.test.local --realm=TEST.LOCAL --principal=admin --password=ADMPassword1 --hostname=ipaclient.test.local --no-ntp  --unattended
Client hostname: ipaclient.test.local
Realm: TEST.LOCAL
DNS Domain: test.local
IPA Server: ipaserver.test.local
BaseDN: dc=test,dc=local

Skipping synchronizing time with NTP server.
Successfully retrieved CA cert
    Subject:     CN=Certificate Authority,O=TEST.LOCAL
    Issuer:      CN=Certificate Authority,O=TEST.LOCAL
    Valid From:  2019-11-02 13:40:27
    Valid Until: 2039-11-02 13:40:27

Enrolled in IPA realm TEST.LOCAL
Created /etc/ipa/default.conf
New SSSD config will be created
Configured sudoers in /etc/nsswitch.conf
Configured /etc/sssd/sssd.conf
Configured /etc/krb5.conf for IPA realm TEST.LOCAL
trying https://ipaserver.test.local/ipa/json
[try 1]: Forwarding 'schema' to json server 'https://ipaserver.test.local/ipa/json'
trying https://ipaserver.test.local/ipa/session/json
[try 1]: Forwarding 'ping' to json server 'https://ipaserver.test.local/ipa/session/json'
[try 1]: Forwarding 'ca_is_enabled' to json server 'https://ipaserver.test.local/ipa/session/json'
Systemwide CA database updated.
Hostname (ipaclient.test.local) does not have A/AAAA record.
Failed to update DNS records.
Missing A/AAAA record(s) for host ipaclient.test.local: 192.168.50.42.
Missing reverse record(s) for address(es): 192.168.50.42.
Adding SSH public key from /etc/ssh/ssh_host_rsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ecdsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ed25519_key.pub
[try 1]: Forwarding 'host_mod' to json server 'https://ipaserver.test.local/ipa/session/json'
Could not update DNS SSHFP records.
SSSD enabled
Configured /etc/openldap/ldap.conf
Configured /etc/ssh/ssh_config
Configured /etc/ssh/sshd_config
Configuring test.local as NIS domain.
Client configuration complete.
The ipa-client-install command was successful
```

### Tips

FreeIpa web redirects to FQDN name. To get web page on local macine run `echo "192.168.50.41 ipaserver.test.local ipaserver" >> /etc/hosts`

### Useful links

https://github.com/freeipa/ansible-freeipa

https://medium.com/netdef/using-vagrants-ansible-provisioner-to-build-a-freeipa-server-1007fbafd595