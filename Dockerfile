FROM nginx:latest
MAINTAINER Ruzhentsev Alexandr noc@mirafox.ru

RUN apt-get update && apt-get install -y wget \
    && echo deb http://packages.dotdeb.org jessie all | tee /etc/apt/sources.list.d/dotdeb.list \
    && wget https://www.dotdeb.org/dotdeb.gpg  -O- | apt-key add - \
    && echo deb http://httpredir.debian.org/debian jessie-backports main | tee /etc/apt/sources.list.d/backports.list \
    && apt-get update && apt-get -y upgrade \
    && apt-get install -y ssl-cert supervisor nginx \
        php7.0-fpm php7.0-curl php7.0-gd php7.0-imagick php7.0-intl php7.0-json \
        php7.0-mbstring php7.0-mcrypt php7.0-memcached php7.0-mysql php7.0-opcache php7.0-readline \
        php7.0-redis php7.0-soap php7.0-sqlite3 php7.0-tidy php7.0-xml php7.0-xmlrpc \
        php7.0-xsl php7.0-zip php7.0-mongodb php7.0-ldap php7.0-imap php7.0-bcmath \
    && apt-get install -y python-certbot-nginx -t jessie-backports \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx-vhost.conf /etc/nginx/conf.d/default.conf
COPY config/nginx-vhost-ssl.conf /etc/nginx/conf.d/default-ssl.conf
COPY config/opcache.ini /etc/php/7.0/fpm/conf.d/20-opcache.ini
COPY config/supervisord.conf /etc/supervisord.conf
COPY scripts/ /usr/local/bin/
COPY src/ /var/www/html/

RUN chmod 755 /usr/local/bin/letsencrypt-init \
    && chmod 755 /usr/local/bin/letsencrypt-renew \
    && chmod 755 /usr/local/bin/docker-entrypoint.sh

VOLUME /var/www/html

EXPOSE 80 443

CMD ["/usr/local/bin/docker-entrypoint.sh"]
