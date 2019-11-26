
# OTUS Linux admin course

## Web server (Nginx)

### How to use this repo

Clone repo, run `vagrant up`. You will have machine `webserver` with nginx modified config.

![Net](./cookie.png?raw=true "Principal scheme")

### Nginx secret cookie against dumb bots

Can see setting in config `templates/nginx.conf`

#### Check by curl

```
[vagrant@webserver ~]$ curl --cookie no  --location 192.168.1.100 --head
HTTP/1.1 302 Moved Temporarily
Server: nginx/1.16.1
Date: Tue, 26 Nov 2019 19:12:59 GMT
Content-Type: text/html
Content-Length: 145
Connection: keep-alive
Location: http://192.168.1.100/addcookie

HTTP/1.1 302 Moved Temporarily
Server: nginx/1.16.1
Date: Tue, 26 Nov 2019 19:12:59 GMT
Content-Type: text/html
Content-Length: 145
Connection: keep-alive
Location: http://192.168.1.100/
Set-Cookie: access=secretCookie

HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Tue, 26 Nov 2019 19:12:59 GMT
Content-Type: text/html
Content-Length: 240
Last-Modified: Tue, 26 Nov 2019 19:10:42 GMT
Connection: keep-alive
ETag: "5ddd78b2-f0"
Accept-Ranges: bytes
```

### Useful links

https://nginx.org/

https://nginx.org/ru/docs/http/ngx_http_headers_module.html

https://nginx.org/ru/docs/http/ngx_http_rewrite_module.html