FROM php:8.1-fpm-alpine

ARG user
ARG uid

RUN apk add --no-cache \
    shadow

# Create system user to run Cron
RUN addgroup -g $uid $user && adduser -u $uid -G $user -h /home/$user -D $user

RUN docker-php-ext-install pdo pdo_mysql bcmath

COPY docker-compose/crontab /etc/crontabs/root

CMD ["crond", "-f"]
