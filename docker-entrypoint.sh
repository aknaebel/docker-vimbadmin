#!/bin/bash -eux

echo >&2 "Setting Permissions:"
path='/var/www/vimbadmin'
htuser='www-data'

chown -R root:${htuser} ${path}/
chown -R ${htuser}:${htuser} ${path}/*

cp ${INSTALL_PATH}/public/.htaccess.dist ${INSTALL_PATH}/public/.htaccess

sed -i "s/##VIMBADMIN_PASSWORD##/${VIMBADMIN_PASSWORD}/g" ${INSTALL_PATH}/application/configs/application.ini
sed -i "s/##DBHOST##/${DBHOST}/g" ${INSTALL_PATH}/application/configs/application.ini
sed -i "s/##MEMCACHE_HOST##/${MEMCACHE_HOST}/g" ${INSTALL_PATH}/application/configs/application.ini
#sed -i "s/##HOSTNAME##/${HOSTNAME}/g" ${INSTALL_PATH}/application/configs/application.ini
sed -i "s/##ADMIN_EMAIL##/${ADMIN_EMAIL}/g" ${INSTALL_PATH}/application/configs/application.ini
sed -i "s/##SMTP_HOST##/${SMTP_HOST}/g" ${INSTALL_PATH}/application/configs/application.ini

sed -i "s/##OPCACHE_MEM_SIZE##/${OPCACHE_MEM_SIZE}/g" /etc/php7/conf.d/00_opcache.ini

for ((i=0;i<10;i++))
do
    DB_CONNECTABLE=$(mysql -u vimbadmin -p${VIMBADMIN_PASSWORD} -h ${DBHOST} -P3306 -e 'status' >/dev/null 2>&1; echo "$?")
    if [[ DB_CONNECTABLE -eq 0 ]]; then
      if [ $(mysql -N -s -u vimbadmin -p${VIMBADMIN_PASSWORD} -h ${DBHOST} -e \
        "select count(*) from information_schema.tables where \
          table_schema='vimbadmin' and table_name='domain';") -eq 1 ]; then
        exec "$@"
      else
        echo "Creating DB and Superuser"
        HASH_PASS=`php -r "echo password_hash('${ADMIN_PASSWORD}', PASSWORD_DEFAULT);"`
        ./bin/doctrine2-cli.php orm:schema-tool:create
        mysql -u vimbadmin -p${VIMBADMIN_PASSWORD} -h ${DBHOST} vimbadmin -e \
          "INSERT INTO admin (username, password, super, active, created, modified) VALUES ('${ADMIN_EMAIL}', '$HASH_PASS', 1, 1, NOW(), NOW())" && \
        echo "Vimbadmin setup completed successfully"
        exec "$@"
      fi
    fi
    sleep 5
done
exit 1
