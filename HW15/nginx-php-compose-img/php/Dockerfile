FROM php:fpm
RUN apt-get update
COPY fpm.conf /usr/local/etc/php-fpm.d/fpm.conf
CMD ["php-fpm"]