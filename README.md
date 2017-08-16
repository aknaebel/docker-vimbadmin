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

networks:
  extnet:
    external: true
  intnet:
    driver: bridge

volumes:
  vimbadminvol:

services:

  vimbadmin-memcached:
    image: memcached
    container_name: vimbadmin-memcached
    networks:
      - intnet
    restart: always

  vimbadmin-mariadb:
    image: mariadb
    container_name: vimbadmin-mariadb
    volumes:
      - ./vimbadmin-mariadb/data:/var/lib/mysql
    networks:
      - intnet
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=vimbadmin
      - MYSQL_USER=vimbadmin
      - MYSQL_PASSWORD=vimbadmin_password
    restart: always

  vimbadmin:
    image: aknaebel/vimbadmin:latest
    container_name: vimbadmin
    links:
      - vimbadmin-mariadb
      - vimbadmin-memcached
    networks:
      - intnet
    volumes:
      - vimbadminvol:/var/www/vimbadmin
    environment:
      - VIMBADMIN_PASSWORD=vimbadmin_password
      - DBHOST=vimbadmin-mariadb
      - MEMCACHE_HOST=vimbadmin-memcached
      - ADMIN_EMAIL=admin@example.com
      - ADMIN_PASSWORD=admin_password
      - SMTP_HOST=smtp.example.com
      - APPLICATION_ENV=production
      - OPCACHE_MEM_SIZE=128
    restart: always

  nginx:
    image: nginx
    container_name: nginx
    volumes:
      - ./nginx/config/nginx.conf:/etc/nginx/nginx.conf:ro
      - vimbadminvol:/var/www/vimbadmin
    environment:
      - VIRTUAL_HOST=www.example.com
    networks:
      - intnet
      - extnet
    ports:
      - 80:80
    restart: always
```

## nginx.conf
```
user www-data;

events {
        worker_connections 768;
}

http {

        include /etc/nginx/mime.types;

        server {
                listen 80;
                server_name www.example.com;
                root /var/www/vimbadmin/public;
                index index.php;
                location / {
                        try_files $uri $uri/ /index.php?$args;
                }
                location ~ \.php$ {
                        try_files $uri =404;
                        fastcgi_split_path_info ^(.+\.php)(/.+)$;
                        fastcgi_pass    vimbadmin:9000;
                        fastcgi_index   index.php;
                        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
                        include         fastcgi_params;
                }
        }

}

```

```
docker-compose up -d
```

Vimbadmin will now be accessible at `http://www.example.com/`.

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
The image provide a volume in **/var/www/vimbadmin**. You must use it with your web server to get the CSS and JS files in whatever web server container you run.

### Documentation
The above example assumes nginx as the web server. See the [official documentation](http://www.vimbadmin.net/) to configure a specific option of your vimbadmin image. 
