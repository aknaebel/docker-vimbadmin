# docker-vimbadmin

## Description:

This docker image provide a [vimbadmin](http://www.vimbadmin.net/) service based on [Alpine Linux edge](https://hub.docker.com/_/alpine/) using php7-fpm

## Usage:
```
docker run --name memcached -d --restart=always memcached

docker run --name mariadb -d \
-e MYSQL_ROOT_PASSWORD=password \
-e MYSQL_DATABASE=vimbadmin \
-e MYSQL_USER=vimbadmin \
-e MYSQL_PASSWORD=vimbadmin_password \
--restart=always mariadb

docker run --name vimbadmin -d -p 9000:9000 \
--link mariadb \
--link memcached \
-e VIMBADMIN_PASSWORD=vimbadmin_password \
-e DBHOST=mariadb \
-e MEMCACHE_HOST=memcached \
-e ADMIN_EMAIL=admin@example.com \
-e ADMIN_PASSWORD=admin_password \
-e SMTP_HOST=smtp.example.com \
-e APPLICATION_ENV=production \
-e OPCACHE_MEM_SIZE=128 \
--restart=always aknaebel/vimbadmin
```

## Docker-compose:
``` 
version: '2'
services:
    memcached:
        image: memcached

    mariadb:
        image: mariadb
        volumes:
            - ./mariadb/data:/var/lib/mysql
        environment:
            - MYSQL_ROOT_PASSWORD=password
            - MYSQL_DATABASE=vimbadmin
            - MYSQL_USER=vimbadmin
            - MYSQL_PASSWORD=vimbadmin_password

    vimbadmin:
        image: aknaebel/vimbadmin:latest
        links:
            - mariadb
            - memcached
        env_file:
            - ./env
        environment:
            VIMBADMIN_PASSWORD=vimbadmin_password
            DBHOST=mariadb
            MEMCACHE_HOST=memcached
            ADMIN_EMAIL=admin@example.com
            ADMIN_PASSWORD=admin_password
            SMTP_HOST=smtp.example.com
            APPLICATION_ENV=production
            OPCACHE_MEM_SIZE=128
```

```
docker-compose up -d
```

## Vimbadmin stuff:

### Environment variables:
- VIMBADMIN_PASSWORD : password for the vimdadmin user in database (the user name MUST be vimbadmin) 
- DBHOST: hostname of the databases host 
- MEMCACHE_HOST: hostname for the memcached host 
- ADMIN_EMAIL: login for the admin user (MUST look like an email address) 
- ADMIN_PASSWORD: password for the admin user
- SMTP_HOST: hostname of the SMTP server
- OPCACHE_MEM_SIZE : opcache memory size in megabytes (default : 128)

### Volume:
The image provide a volume in **/var/www/vimbadmin**. You must use it with your web server to get the CSS and JS files

### Documentation
See the [official documentation](http://www.vimbadmin.net/) to configure a specific option of your vimbadmin image
