#!/bin/bash 


HOST=$1
PORT=$2
USER=$3
PASSWD=$4
DB=$5

echo "Installing dependencies, Postgres client binaries.."
apt-get install postgresql-client-common

echo "Checking connectivity to $HOST:$PORT.."
pg_isready  -h $HOST -p $PORT
if pg_isready  -h $HOST -p $PORT -q; then
  echo "Database Server connection to $HOST:$PORT was successful.."
else
  echo "Database Server connection to $HOST:$PORT was failed.. Need to exit"
  exit 0
fi


export PGPASSWORD=$PASSWD
echo "Listing Available Databases.."
psql -h $HOST -p $PORT -U $USER -w -lq
#psql -h $HOST -p $PORT -U $USER  -w  -XAc "SELECT * FROM pg_database"

if psql -h $HOST -p $PORT -U $USER -w -lqt | cut -d \| -f 1 | grep -qw $DB; then
    # $? is 0, Database Exists
    echo "Database \"$DB\" already exists,dropping the database"
    dropdb -h $HOST -p $PORT -U $USER -w $DB 
    echo "Database \"$DB\" dropped"
    echo "#########################################"
fi
echo "Creating the database $DB .."
createdb -h $HOST -p $PORT -U $USER -w $DB
echo "Created the database $DB .."
echo "Listing Databases after creation.."
psql -h $HOST -p $PORT -U $USER -w -lq
echo "Creating necessary tables from SQL Dump to $DB.."
psql -h $HOST -p $PORT -U $USER -w $DB -f DB__to_do_list.sql 


FILE="db_conn.php"
cp db_conn_tmpl.php $FILE
sed  -i -E 's/^(\$DBHOST)\s*=.*/\1 = '"\"$HOST\""';/g' $FILE
sed  -i -E 's/^(\$DBNAME)\s*=.*/\1 = '"\"$DB\""';/g' $FILE
sed  -i -E 's/^(\$USERNAME)\s*=.*/\1 = '"\"$USER\""';/g' $FILE
sed  -i -E 's/^(\$PASSWORD)\s*=.*/\1 = '"\"$PASSWD\""';/g' $FILE


#installinf php8.1  
sudo apt-get install php -y
sudo systemctl status php8.1-fpm.service
status=`systemctl status php8.1-fpm.service| grep Loaded| cut -d " " -f7`; 
if [ $status == "masked" ]; then systemctl unmask php8.1-fpm.service && systemctl start php8.1-fpm.service && echo "PHP Service Unmasked & Started";else systemctl start php8.1-fpm.service; fi
sudo systemctl enable php8.1-fpm.service
#installing php-pgsql
sudo apt-get install -y php-pgsql
# clone the repo in the path /home/ubuntu/repos
git clone https://github.com/AstraOps/AstraOpsDemoApp.git
#copy the index.php file in to the /var/www/html and rename as info.php
cd /home/ubuntu/repos/AstraOpsDemoApp
cp index.php /var/www/html/info.php
#provide the full permission to info.php
chmod 777 /var/www/html/info.php 
#backup the defalut file 
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default_bck
#paste the follow for hosting in nginx 
echo "server {
  # Example PHP Nginx FPM config file
  listen 80 default_server;
  listen [::]:80 default_server;
  root /var/www/html;

  # Add index.php to setup Nginx, PHP & PHP-FPM config
  index index.php index.html index.htm index.nginx-debian.html;

  server_name _;

  location / {
    try_files $uri $uri/ =404;
  }

  # pass PHP scripts on Nginx to FastCGI (PHP-FPM) server
  location ~ \.php$ {
    include snippets/fastcgi-php.conf;

    # Nginx php-fpm sock config:
    fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    # Nginx php-cgi config :
    # Nginx PHP fastcgi_pass 127.0.0.1:9000;
  }

  # deny access to Apache .htaccess on Nginx with PHP, 
  # if Apache and Nginx document roots concur
  location ~ /\.ht {
    deny all;
  }
} # End of PHP FPM Nginx config example" > /etc/nginx/sites-available/default
#check the syntax 
sudo nginx -t
#reload the nginx
sudo systemctl reload nginx
curl localhost:80







