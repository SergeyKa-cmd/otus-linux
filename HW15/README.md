
# OTUS Linux admin course

## Docker

### How to use this repo

Clone repo, install docker and enjoy containers.

In root dir setup for nginx container with custom start page. 

Dir `nginx-php-compose` nginx and php containers with docker-compose using public images.

Dir `nginx-php-compose-img` nginx and php containers with docker-compose using my custom images.

Use localhost:8080 link to see result.

### Build nginx alpine container with own start page and push in docker hub

#### Build
```
$> docker build -t nginx-alpine .
Sending build context to Docker daemon  26.62kB
Step 1/2 : FROM nginx:alpine
alpine: Pulling from library/nginx
9d48c3bd43c5: Pull complete 
1ae95a11626f: Pull complete 
Digest: sha256:77f340700d08fd45026823f44fc0010a5bd2237c2d049178b473cd2ad977d071
Status: Downloaded newer image for nginx:alpine
 ---> 4d3c246dfef2
Step 2/2 : COPY index.html /usr/share/nginx/html/index.html
 ---> a87816e74c09
Successfully built a87816e74c09
Successfully tagged nginx-alpine:latest
```

#### Run and visit page `curl localhost:8080` to see some logs
```
$> docker run --rm -it -p 8080:80 nginx-alpine
172.17.0.1 - - [01/Oct/2019:18:26:18 +0000] "GET / HTTP/1.1" 200 623 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36" "-"
2019/10/01 18:26:19 [error] 6#6: *1 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 172.17.0.1, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "localhost:8080", referrer: "http://localhost:8080/"
172.17.0.1 - - [01/Oct/2019:18:26:19 +0000] "GET /favicon.ico HTTP/1.1" 404 555 "http://localhost:8080/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36" "-"

```

#### Push to docker hub

```
$> docker tag nginx-alpine revard/nginx-alpine:1.0
$> docker push revard/nginx-alpine:1.0
The push refers to repository [docker.io/revard/nginx-alpine]
d9b06b138e3d: Pushed 
e2a556e0495e: Mounted from library/nginx 
03901b4a2ea8: Mounted from library/nginx 
1.0: digest: sha256:e3ae64eed3ead25c3c976d5e3716d6839c79b6e9eff7bb6053eb46ea67428dc3 size: 946
```

### Docker-compose

#### Run 

```
$> cd nginx-php-compose-img 
$> docker-compose up -d
Creating network "nginx-php-compose-img_web_net" with the default driver
Creating nginx-php-compose-img_php_1_732a0b05cfd5 ... done
Creating nginx-php-compose-img_nginx_1_ef230c2e3dad ... done

$> curl localhost:8080 | grep php
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<title>PHP 7.3.10 - phpinfo()</title><meta name="ROBOTS" content="NOINDEX,NOFOLLOW,NOARCHIVE" /></head>
...

$> docker-compose down
Stopping nginx-php-compose-img_nginx_1_9f741b53465e ... done
Stopping nginx-php-compose-img_php_1_57649b1e4da5   ... done
Removing nginx-php-compose-img_nginx_1_9f741b53465e ... done
Removing nginx-php-compose-img_php_1_57649b1e4da5   ... done
Removing network nginx-php-compose-img_web_net

```

#### Some usefull docker commands

```
$> docker ps
CONTAINER ID        IMAGE                         COMMAND                  CREATED             STATUS              PORTS                                        NAMES
125cf49ea1f4        revard/nginx-alpine-php:1.0   "nginx -g 'daemon of…"   5 minutes ago       Up 5 minutes        0.0.0.0:443->443/tcp, 0.0.0.0:8080->80/tcp   nginx-php-compose-img_nginx_1_9f741b53465e
1e0994343073        revard/php-nginx:1.0          "docker-php-entrypoi…"   5 minutes ago       Up 5 minutes        0.0.0.0:9000->9000/tcp                       nginx-php-compose-img_php_1_57649b1e4da5

$> docker inspect -f '{{ .Mounts }}' 125cf49ea1f4
[{bind  /home/alf/otus-linux/HW15/nginx-php-compose-img/www /var/www  rw true rprivate} {bind  /home/alf/otus-linux/HW15/nginx-php-compose-img/logs /var/log/nginx  rw true rprivate}]

$> docker exec -ti 1e0994343073 sh
# ^C

$> docker logs 1e0994343073 
[02-Oct-2019 17:43:06] NOTICE: fpm is running, pid 1
[02-Oct-2019 17:43:06] NOTICE: ready to handle connections
192.168.112.3 -  02/Oct/2019:17:43:10 +0000 "GET /index.php" 200

```

### Useful links

https://github.com/moul/docker-kernel-builder