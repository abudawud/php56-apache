FROM php:5.6-apache

LABEL Description="Apache and php5.6 with pdo_postgres, gd, and ldap" \
	Maintener="abudawud<warishafidz@gmail.com>" \
	License="GNU GPLv2" \
	Verson="1.0"

# Update package
RUN apt-get update

# Prepare package
RUN apt-get install -y wget libpng-dev libpq-dev libldb-dev libldap2-dev

# Link ldap libraries
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
	&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

#  Download and extract php
RUN set -eux; \
	cd /tmp; \
	wget https://www.php.net/distributions/php-5.6.40.tar.gz; \
	tar xzf php-5.6.40.tar.gz

WORKDIR /tmp/php-5.6.40/ext

# Install extension

# Install php-gd
RUN set -eux; \
	cd gd; \
	phpize; \
	./configure; \
	make; \
	make install

# Install php-pdo_pgsql
RUN set -eux; \
	cd pdo_pgsql; \
	phpize; \
	./configure; \
	make; \
	make install

# Install pgsql
RUN set -eux; \
	cd pgsql; \
	phpize; \
	./configure; \
	make; \
	make install

# Install ldap
RUN set -eux; \
	cd ldap; \
	phpize; \
	./configure; \
	make; \
	make install

# Enable php.ini configuration and do some config
RUN set -eux; \
	mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini; \
	# Enable gd and pgsql ext etc
	sed -ri \
		's/;extension=php_pdo_pgsql.dll/extension=pdo_pgsql.so/; \
		s/;extension=php_gd2.dll/extension=gd.so/; \
		s/;extension=php_pgsql.dll/extension=pgsql.so/; \
		s/;extension=php_ldap.dll/extension=ldap.so/; \
		s/short_open_tag = Off/short_open_tag = On/' \
		/usr/local/etc/php/php.ini

RUN a2enmod rewrite

WORKDIR /var/www/html

# CLEANUP
RUN set -eux; \
	apt-get clean -y; \
    apt-get autoclean -y; \
    apt-get remove -y wget; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

VOLUME [ "/var/www/html" ]

EXPOSE 80