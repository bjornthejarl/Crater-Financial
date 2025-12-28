FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libmagickwand-dev \
    mariadb-client \
    nodejs \
    npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP-FPM to run as root (for Dokploy environment)
RUN sed -i 's/user = www-data/user = root/g' /usr/local/etc/php-fpm.d/www.conf
RUN sed -i 's/group = www-data/group = root/g' /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www

# Copy application code
COPY . /var/www

# Mark directory as safe for git (prevents dubious ownership errors)
RUN git config --global --add safe.directory /var/www

# Install Composer dependencies (skip scripts to avoid dev dependency issues)
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Install npm dependencies and build frontend
RUN npm install && npm run build

# Set proper permissions
RUN chown -R root:root /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm", "-R"]
