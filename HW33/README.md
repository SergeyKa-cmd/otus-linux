
# OTUS Linux admin course

## Dynamic web content

### How to use this repo

Clone repo, run `vagrant up`. 

Check this ports http://VMIP:[port]

| Port | App |
--------------
| 8080 | TomCat |
| 8081 | Go |
| 8082 | Ruby |

![Dweb](./dynoweb.png?raw=true "Dynamic web")

### Stend config

Web server nginx + java (tomcat) + go + ruby

```
[vagrant@docker ~]$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                              NAMES
4e9f9ddd007b        dcompose_tomcatserver   "catalina.sh run"        15 minutes ago      Up 15 minutes       5000/tcp, 0.0.0.0:8080->8080/tcp   dcompose_tomcatserver_1
a88d5f96d1d2        dcompose_rubyserver     "bundle exec racku..."   15 minutes ago      Up 15 minutes       0.0.0.0:8082->8082/tcp, 9002/tcp   dcompose_rubyserver_1
87108b2ac01c        dcompose_goserver       "./myapp"                15 minutes ago      Up 15 minutes       0.0.0.0:8081->8081/tcp             dcompose_goserver_1
```

### Useful links

https://habr.com/post/416669/

https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_72/rzab6/xnonblock.htm

https://otus.ru/media/f2/a0/UNIX_Professionalnoe_programmirovanie_3_e_izd_2018-4560-f2a055.pdf?filename=UNIX_Professionalnoe_programmirovanie_3-e_izd_2018.pdf

https://www.opennet.ru/base/dev/epoll_example.txt.html

https://medium.com/@copyconstruct/the-method-to-epolls-madness-d9d2d6378642

https://notes.shichao.io/unp/ch6/

https://oxnz.github.io/2016/05/03/performance-tuning/

https://jvns.ca/blog/2017/06/03/async-io-on-linux--select--poll--and-epoll/

https://medium.com/@copyconstruct/nonblocking-i-o-99948ad7c957

https://www.ietf.org/proceedings/80/slides/hybi-2.pdf

https://www.tutorialspoint.com/laravel/laravel_installation.htm

https://codex.wordpress.org/Installing_WordPress

https://reactjs.org/docs/create-a-new-react-app.html

http://php.net/manual/en/install.fpm.php

https://github.com/gothinkster/django-realworld-example-app

https://www.gurdeepbangar.com/php-fpm-pool-tweaking/

https://codeburst.io/build-a-weather-website-in-30-minutes-with-node-js-express-openweather-a317f904897b