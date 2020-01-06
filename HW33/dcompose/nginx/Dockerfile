FROM alpine:3.9

RUN apk update \
    && apk add --update --no-cache nginx \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /run/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.server.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]