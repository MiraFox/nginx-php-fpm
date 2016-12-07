#!/bin/bash

set -e

PHP_TZ=`echo ${PHP_TIMEZONE} |sed  's|\/|\\\/|g'`

phpini=/etc/php/7.0/fpm/php.ini

# применение пользовательских конфигурационных файлов nginx
if [ -f /var/www/html/config/nginx/nginx.conf ]; then
    cp /var/www/html/config/nginx/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f /var/www/html/config/nginx/nginx-vhost.conf ]; then
    cp /var/www/html/config/nginx/nginx-vhost.conf /etc/nginx/sites-available/default
fi

if [ -f /var/www/html/config/nginx/nginx-vhost-ssl.conf ]; then
    cp /var/www/html/config/nginx/nginx-vhost-ssl.conf /etc/nginx/sites-available/default-ssl
fi

# применение пользовательского конфигурационного файла php-fpm
if [ -f /var/www/html/config/php/pool.conf ]; then
    cp /var/www/html/config/php/pool.conf /etc/php/7.0/fpm/pool.d/www.conf
fi

sed -i "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf

# применение пользовательского конфигурационного файла php.ini
if [ -f /var/www/html/config/php/php.ini ]; then
    cp /var/www/html/config/php/php.ini /etc/php/7.0/fpm/php.ini
else

    if [ ! -z "${PHP_MEMORY_LIMIT}" ]; then
	sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEMORY_LIMIT}M/g" ${phpini}
    fi

    if [ ! -z "${PHP_SHORT_OPEN_TAG}" ]; then
	sed -i "s/short_open_tag = Off/short_open_tag = ${PHP_SHORT_OPEN_TAG}/g" ${phpini}
    else
	sed -i "s/short_open_tag = Off/short_open_tag = On/g" ${phpini}
    fi

    if [ ! -z "${PHP_UPLOAD_MAX_FILEZIZE}" ]; then
	sed -i "s/upload_max_filesize = 2M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILEZIZE}M/g" ${phpini}
    fi

    if [ ! -z "${PHP_MAX_EXECUTION_TIME}" ]; then
	sed -i "s/max_execution_time = 30/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/g" ${phpini}
    fi

    if [ ! -z "${PHP_MAX_INPUT_TIME}" ]; then
	sed -i "s/max_input_time = 60/max_input_time = ${PHP_MAX_INPUT_TIME}/g" ${phpini}
    fi

    if [ ! -z "${PHP_DISPLAY_ERRORS}" ]; then
	sed -i "s/display_errors = Off/display_errors = ${PHP_DISPLAY_ERRORS}/g" ${phpini}
    fi

    if [ ! -z "${PHP_POST_MAX_SIZE}" ]; then
	sed -i "s/post_max_size = 8M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" ${phpini}
    fi

    if [ ! -z "${PHP_ALLOW_URL_FOPEN}" ]; then
	sed -i "s/allow_url_fopen = On/allow_url_fopen = ${PHP_ALLOW_URL_FOPEN}/g" ${phpini}
    fi

    if [ ! -z "${PHP_TIMEZONE}" ]; then
	sed -i "s/;date.timezone =/date.timezone = ${PHP_TZ}/g" ${phpini}
    else
	sed -i "s/;date.timezone =/date.timezone = Europe\/Moscow/g" ${phpini}
    fi

    if [ -z "${PHP_MODULE_MEMCACHED}" ]; then
	rm -f /etc/php/7.0/fpm/conf.d/20-memcached.ini
    else
	if [ ${PHP_MODULE_MEMCACHED} == 'Off' ]; then
	    rm -f /etc/php/7.0/fpm/conf.d/20-memcached.ini
        fi
    fi

    if [ -z "${PHP_MODULE_REDIS}" ]; then
	rm -f /etc/php/7.0/fpm/conf.d/20-redis.ini
    else
	if [ ${PHP_MODULE_REDIS} == 'Off' ]; then
	    rm -f /etc/php/7.0/fpm/conf.d/20-redis.ini
        fi
    fi

    if [ -z "${PHP_MODULE_MONGO}" ]; then
        rm -f /etc/php/7.0/fpm/conf.d/20-mongodb.ini
    else
        if [ ${PHP_MODULE_MONGO} == 'Off' ]; then
	    rm -f /etc/php/7.0/fpm/conf.d/20-mongodb.ini
        fi
    fi

    if [ -z "${PHP_MODULE_IMAP}" ]; then
	rm -f /etc/php/7.0/fpm/conf.d/20-imap.ini
    else
	if [ ${PHP_MODULE_IMAP} == 'Off' ]; then
	    rm -f /etc/php/7.0/fpm/conf.d/20-imap.ini
	fi
    fi

    if [ -z "${PHP_MODULE_LDAP}" ]; then
        rm -f /etc/php/7.0/fpm/conf.d/20-ldap.ini
    else
	if [ ${PHP_MODULE_LDAP} == 'Off' ]; then
	    rm -f /etc/php/7.0/fpm/conf.d/20-ldap.ini
        fi
    fi

    if [ -z "${PHP_MODULE_OPCACHE}" ]; then
        rm -f /etc/php/7.0/fpm/conf.d/10-opcache.ini
    else
	if [ ${PHP_MODULE_OPCACHE} == 'Off' ]; then
	    rm -f /etc/php/7.0/fpm/conf.d/10-opcache.ini
        else
	    echo "opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
opcache.enable_cli=1" > /etc/php/7.0/fpm/conf.d/20-opcache.ini
        fi
    fi

fi

/usr/bin/supervisord -n -c /etc/supervisord.conf

exec "$@"
