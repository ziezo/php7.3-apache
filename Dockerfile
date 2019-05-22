FROM php:7.3-apache

##########################################################################
# php modules: pdo soap gd mysqli
##########################################################################
RUN apt-get update \
    && apt-get install -y \
        libmcrypt-dev \
        libjpeg62-turbo-dev \
        libpcre3-dev \
        libpng-dev \
        libfreetype6-dev \
        libxml2-dev \
        libicu-dev \
        mysql-client \
        wget \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install intl pdo pdo_mysql mbstring soap gd mysqli


##########################################################################
# apache module: rewrite headers
##########################################################################
RUN a2enmod rewrite
RUN a2enmod headers
# expose remote address, not proxy address - NOTE use %a as LogFormat, not %h
RUN echo "RemoteIPHeader X-Forwarded-For" > /etc/apache2/conf-enabled/remoteip.conf
RUN a2enmod remoteip


##########################################################################
# linux programs: cron vim openssh-client(sftp)
##########################################################################
RUN apt-get update && apt-get install -y --no-install-recommends \
        cron \
        vim \
        openssh-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


##########################################################################
# enable running php shell scripts with #!/usr/bin/php
##########################################################################
RUN ln -s /usr/local/bin/php /usr/bin/php


##########################################################################
# enable php mail() -> use "link <mailserver_container_name>:exim" in docker-compose.yml
# https://github.com/RickWieman/Dockerfiles/tree/master/php-apache-ssmtp
##########################################################################
RUN apt-get update && apt-get install -y ssmtp && rm -r /var/lib/apt/lists/*
ADD ssmtp.conf /etc/ssmtp/ssmtp.conf
ADD php-smtp.ini /usr/local/etc/php/conf.d/php-smtp.ini


##########################################################################
# opcache
##########################################################################
#RUN docker-php-source extract \
#    && if [ -d "/usr/src/php/ext/mysql" ]; then docker-php-ext-install mysql; fi \
#    && if [ -d "/usr/src/php/ext/opcache" ]; then docker-php-ext-install opcache; fi \
#    && docker-php-source delete


##########################################################################
# geoip
##########################################################################
##re-create sources.list to include contrib
#RUN (echo "deb http://deb.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list) && \
#    (echo "deb http://deb.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list) && \
#    (echo "deb http://security.debian.org jessie/updates main contrib non-free" >> /etc/apt/sources.list)
#
#RUN apt-get update && apt-get install -y \
#        geoip-database-contrib \
#    && apt-get clean && rm -rf /var/lib/apt/lists/*
#
##does not work - can't find php5-geoip ...
##RUN apt-get update && apt-get install -y \
##        php5-geoip \
##    && apt-get clean && rm -rf /var/lib/apt/lists/*
#
## Install GeoIP PHP extension.
#RUN apt-get update \
#    && apt-get install -y  libgeoip-dev wget \
#    && rm -rf /var/lib/apt/lists/* \
#    && pecl install geoip-1.1.1 \
#    && docker-php-ext-enable geoip


##########################################################################
# start cron background and php:5.6-apache ENTRYPOINT
##########################################################################
#COPY docker-php-entrypoint-new /usr/local/bin
#ENTRYPOINT ["docker-php-entrypoint-new"]
#CMD ["apache2-foreground"]
