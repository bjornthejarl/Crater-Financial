FROM php:8.1-fpm-alpine

RUN apk add --no-cache shadow

# Install PHP extensions needed for Laravel
RUN docker-php-ext-install pdo pdo_mysql bcmath

# Set working directory
WORKDIR /var/www

# Copy application code
COPY . /var/www

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Mark directory as safe for git
RUN git config --global --add safe.directory /var/www || true

# Install Composer dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Set up crontab for Laravel scheduler (runs every minute)
RUN echo "* * * * * cd /var/www && /usr/local/bin/php artisan schedule:run >> /dev/null 2>&1" > /etc/crontabs/root

CMD ["crond", "-f", "-l", "2"]
