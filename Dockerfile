FROM php:7.4-fpm

RUN apt-get update && apt-get install -y \
      wget \
      git \
      gnupg \
      fish

RUN apt-get update && apt-get install -y libzip-dev libicu-dev && docker-php-ext-install pdo zip intl opcache

# Support de apcu
RUN pecl install apcu && docker-php-ext-enable apcu

# Support de redis
RUN pecl install redis && docker-php-ext-enable redis

# Support de Postgre
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo_pgsql

# Support de MySQL (pour la migration)
RUN docker-php-ext-install mysqli pdo_mysql

# Imagick
RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && pecl install imagick && docker-php-ext-enable imagick

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Install phpunit and put binary into $PATH
RUN curl -sSLo phpunit.phar https://phar.phpunit.de/phpunit.phar \
    && chmod 755 phpunit.phar \
    && mv phpunit.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit

# Install PHP Code sniffer
RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && chmod 755 phpcs.phar \
    && mv phpcs.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcs.phar /usr/local/bin/phpcs \
    && curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar \
    && chmod 755 phpcbf.phar \
    && mv phpcbf.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/phpcbf.phar /usr/local/bin/phpcbf

# Install Node.js & Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_15.x | bash - \
    && apt-get install -y nodejs build-essential yarn \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Pour la récupération des durées
RUN apt-get update && apt-get install -y ffmpeg

# Xdebug (disabled by default, but installed if required)
RUN pecl install xdebug-2.9.7 && docker-php-ext-enable xdebug
ADD xdebug.ini /usr/local/etc/php/conf.d/

WORKDIR /var/www

EXPOSE 9000