FROM php:7.0-apache

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEFAULT_TIMEZONE="Australia/Melbourne" \
    COMPOSER_ALLOW_SUPERUSER=1

RUN set -xe && \
    apt-get -qq update && \
    apt-get -qq install \
        apt-transport-https \
        --no-install-recommends && \
    curl -sL 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key' | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_7.x jessie main' > /etc/apt/sources.list.d/nodesource.list && \
    apt-get -qq update && \
    apt-get -qq install nodejs --no-install-recommends && \
    apt-get purge -qq --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        -o APT::AutoRemove::SuggestsImportant=false \
        apt-transport-https \
        && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    rm /etc/apt/sources.list.d/nodesource.list && \
    apt-key del 68576280 && \
    true

RUN set -xe && \
    fetchDeps=' \
        zlib1g-dev \
        libpng12-dev \
        libjpeg-dev \
        libicu-dev \
        libmagickwand-dev \
        libxml2-dev \
        ' && \
    apt-get -qq update && \
    apt-get -qq install --no-install-recommends \
        git \
        zlib1g \
        libpng12-0 \
        libjpeg62-turbo \
        libmemcached-dev \
        libicu52 \
        libmagickwand-6.q16-2 \
        libxml2 \
        $fetchDeps \
        && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
    git clone --branch php7 https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached && \
    echo "memcached" >> /usr/src/php-available-exts && \
    docker-php-ext-configure memcached && \
    docker-php-ext-install zip pdo pdo_mysql gd opcache mbstring bcmath intl pcntl memcached soap && \
    pecl install apcu && \
    echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini && \
    pecl install -o redis && \
    echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini && \
    pecl install -o imagick && \
    echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini && \
    rm -rf /tmp/pear && \
    apt-get purge -qq --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        -o APT::AutoRemove::SuggestsImportant=false \
        $fetchDeps && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    true

RUN set -xe && \
    apt-get -qq update && \
    apt-get -qq install --no-install-recommends \
        libfontconfig1 \
        libfreetype6 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        xz-utils \
        && \
    mkdir -p /opt && \
    cd /opt && \
    curl http://download.gna.org/wkhtmltopdf/0.12/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz | tar -xJv && \
    ln -s /opt/wkhtmltox/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf && \
    ln -s /opt/wkhtmltox/bin/wkhtmltoimage /usr/local/bin/wkhtmltoimage && \
    true

RUN set -xe && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    true

COPY config/opcache.ini config/config.ini /usr/local/etc/php/conf.d/