## Описание

Это Dockerfile, позволяющие собрать простой образ для Docker с Nginx, PHP-FPM и поддержкой Let's Encrypt. PHP версии 7.0 из репозитория [Dotdeb](https://www.dotdeb.org/). Собран на основе официального образа nginx:latest.

### Установлены следующие расширения PHP

 - **Расширения, включенные по умолчанию:** curl, dg, imagick, intl, json, mbstring, mcrypt, mysql, readline, soap,  sqlite3, tidy, xml, xmlrpc, xsl, zip, bcmath
 - **Расширения, отключенные по умолчанию:** memcached, opcache, redis, mongodb, ldap, imap

## Репозиторий Git

Репозиторий исходных файлов данного проекта: [https://github.com/MiraFox/nginx-php-fpm](https://github.com/MiraFox/nginx-php-fpm)

## Репозиторий Docker Hub

Расположение образа в Docker Hub: [https://hub.docker.com/r/mirafox/nginx-php-fpm/](https://hub.docker.com/r/mirafox/nginx-php-fpm/)

## Использование Docker Hub

```
sudo docker pull mirafox/nginx-php-fpm
```

## Запуск

```
sudo docker run -d -p 80:80 -p 443:443 \
    -v /home/username/sitename/www/:/var/www/html/ \
    -v /home/username/sitename/logs/:/var/log/nginx/ \
    mirafox/nginx-php-fpm
```

## Доступные параметры конфигурации

### Параметры изменяющие настройки PHP

| Параметр | Изменяемая директива | По умолчанию |
|----------|----------------------|--------------|
|**PHP_ALLOW_URL_FOPEN**| allow_url_fopen | On |
|**PHP_DISPLAY_ERRORS**| display_errors | Off |
|**PHP_MAX_EXECUTION_TIME**| max_execution_time | 30 |
|**PHP_MAX_INPUT_TIME**| max_input_time | 60 |
|**PHP_MEMORY_LIMIT**| memory_limit | 128M |
|**PHP_POST_MAX_SIZE**| post_max_size | 8M |
|**PHP_SHORT_OPEN_TAG**| short_open_tag | On |
|**PHP_TIMEZONE**| date.timezone | Europe/Moscow |
|**PHP_UPLOAD_MAX_FILEZIZE**| upload_max_filesize | 2M |

#### Пример использования

```
sudo docker run -d \
    -e 'PHP_TIMEZONE=Europe/Moscow' \
    -e 'PHP_MEMORY_LIMIT=512' \
    -e 'PHP_SHORT_OPEN_TAG=On' \
    -e 'PHP_UPLOAD_MAX_FILEZIZE=16' \
    -e 'PHP_MAX_EXECUTION_TIME=120' \
    -e 'PHP_MAX_INPUT_TIME=120' \
    -e 'PHP_DISPLAY_ERRORS=On' \
    -e 'PHP_POST_MAX_SIZE=32' \
    -e 'PHP_ALLOW_URL_FOPEN=Off' \
    mirafox/nginx-php-fpm
```

### Параметры подключения расширений PHP

 - **PHP_MODULE_MEMCACHED**: при установки в значение On подключается расширение memcached
 - **PHP_MODULE_OPCACHE**: при установки в значение On подключается расширение OPcache
 - **PHP_MODULE_REDIS**: при установки в значение On подключается расширение Redis
 - **PHP_MODULE_MONGO**: при установки в значение On подключается расширение MongoDB
 - **PHP_MODULE_IMAP**: при установки в значение On подключается расширение IMAP
 - **PHP_MODULE_LDAP**: при установки в значение On подключается расширение LDAP

#### Пример использования

```
sudo docker run -d -e 'PHP_MODULE_MEMCACHED=On' -d mirafox/nginx-php-fpm
```

## Поддержка Let's Encrypt

Данный образ имеет поддержку SSL сертификатов Let's Encrypt. Для установки сертификата необходимо при запуске контейнера добавить параметры:

 - **SSL_DOMAIN**: имя домена, на который будет выдан SSL сертификат
 - **SSL_EMAIL**: E-Mail администратора домена

**Оба параметра обязательны, если Вы желаете использовать Let's Encrypt**

#### Пример использования

```
sudo docker run -d \
    -e 'SSL_DOMAIN=example.com,www.example.com' \
    -e 'SSL_EMAIL=admin@example.com' \
    mirafox/nginx-php-fpm
```

### Установка сертификата

```
docker exec -it <CONTAINER_NAME> /usr/local/bin/letsencrypt-init
```

### Перевыпуск сертификата

```
docker exec -it <CONTAINER_NAME> /usr/local/bin/letsencrypt-renew
```

## Использование PHP Composer

```
docker exec -it <CONTAINER_NAME> /usr/local/bin/composer
```

## Использование собственных конфигурационных файлов

Вы можете использовать собственные конфигурационные файлы для nginx и php. Для этого Вам необходимо создать их в директории **/var/www/html/config/**. При их обнаружении, Ваши конфигурационные файлы будут скопированы и заменят существующие.

### Nginx

 - **/var/www/html/config/nginx/nginx.conf** - данным файлом будет заменен /etc/nginx/nginx.conf
 - **/var/www/html/config/nginx/nginx-vhost.conf** - данным файлом будет заменен /etc/nginx/conf.d/default.conf
 - **/var/www/html/config/nginx/nginx-vhost-ssl.conf** - данным файлом будет заменен /etc/nginx/conf.d/default-ssl.conf

### PHP

 - **/var/www/html/config/php/php.ini** - данным файлом будет заменен /etc/php/7.0/fpm/php.ini (при этом параметры, изменяющие настройки PHP, переданные при запуске контейнера, будут игнорированы)
 - **/var/www/html/config/php/pool.conf** - данным файлом будет заменен /etc/php/7.0/fpm/pool.d/www.conf

