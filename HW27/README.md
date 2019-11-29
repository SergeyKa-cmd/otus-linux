
# OTUS Linux admin course

## Postfix Dovecot

### How to use this repo

Clone repo, run `vagrant up`. 

### Test sending mail

#### Send mail from local machine

```
$ telnet  localhost 8025
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 server.test.local ESMTP Postfix
ehlo server.test.local
250-server.test.local
250-PIPELINING
250-SIZE 10240000
250-VRFY
250-ETRN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN
mail from: tgz@test.local
250 2.1.0 Ok
rcpt to: vagrant@server.test.local
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
Subject: test mail from telnet                                                           
Check mail sendings.           
OTUS
.
250 2.0.0 Ok: queued as 815C0126
quit
221 2.0.0 Bye
Connection closed by foreign host.
```

#### Check letters on server 

```
$ telnet localhost 8143
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
* OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE AUTH=PLAIN] Dovecot ready.
a login "vagrant" "password"
a OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE SORT SORT=DISPLAY THREAD=REFERENCES THREAD=REFS THREAD=ORDEREDSUBJECT MULTIAPPEND URL-PARTIAL CATENATE UNSELECT CHILDREN NAMESPACE UIDPLUS LIST-EXTENDED I18NLEVEL=1 CONDSTORE QRESYNC ESEARCH ESORT SEARCHRES WITHIN CONTEXT=SEARCH LIST-STATUS BINARY MOVE SNIPPET=FUZZY SPECIAL-USE] Logged in
b select inbox
* FLAGS (\Answered \Flagged \Deleted \Seen \Draft NonJunk)
* OK [PERMANENTFLAGS (\Answered \Flagged \Deleted \Seen \Draft NonJunk \*)] Flags permitted.
* 2 EXISTS
* 0 RECENT
* OK [UIDVALIDITY 1575025468] UIDs valid
* OK [UIDNEXT 3] Predicted next UID
b OK [READ-WRITE] Select completed (0.002 + 0.000 + 0.002 secs).
```

#### Check by mail client

![Mail](./postfix.png?raw=true "Postfix")

### Useful links

http://www.postfix.org/

https://www.dovecot.org/

https://habr.com/ru/post/193220/

http://dummyluck.com/page/postfix_konfiguracia_nastroika

https://whatismyipaddress.com/blacklist-check

http://www.anti-abuse.org/multi-rbl-check

https://mxtoolbox.com

https://www.wormly.com/test-smtp-server