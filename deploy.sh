#!/bin/bash 
set -x

apt install -y openssh-server net-tools
apt list --installed | grep -i openssh
netstat -tpln | grep 22
systemctl status ssh
systemctl enable ssh
systemctl start ssh
netstat -tpln | grep 22

HOST=$1
PORT=$2
USER=$3
PASSWD=$4
DB=$5
ASTRAOPSUSER=$6
ASTRAOPSPROJECT=$7
NGINX_VERSION=$8

echo "HOST = $HOST"
echo "PORT = $PORT"
echo "USER = $USER"
echo "PASSWD = $PASSWD"
echo "DB = $DB"
echo "ASTRAOPSUSER = $ASTRAOPSUSER"
echo "ASTRAOPSPROJECT = $ASTRAOPSPROJECT"
echo "NGINX_VERSION = $NGINX_VERSION"

apt install -y php-fpm php-pgsql postgresql-client postgresql-client-common php
apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
apt update -y
apt install nginx="$NGINX_VERSION-1~`cat /etc/os-release | grep -i version_codename| cut -d "=" -f2`"
echo "Checking connectivity to $HOST:$PORT.."
pg_isready  -h $HOST -p $PORT
if pg_isready  -h $HOST -p $PORT -q; then
  echo "Database Server connection to $HOST:$PORT was successful.."
else
  echo "Database Server connection to $HOST:$PORT was failed.. Need to exit"
  exit 0
fi

echo "Checking Nginx configuration"
ls -altr /etc/nginx/
ls -altr /etc/nginx/sites-enabled/
ls -altr /etc/nginx/sites-available/
ls -ltra /etc/nginx/conf.d
cat /etc/nginx/conf.d/default.conf




export PGPASSWORD=$PASSWD
echo "Listing Available Databases.."
psql -h $HOST -p $PORT -U $USER -w -lq

if psql -h $HOST -p $PORT -U $USER -w -lqt | cut -d \| -f 1 | grep -qw $DB; then
    # $? is 0, Database Exists
    echo "Database \"$DB\" already exists,dropping the database"
    #psql -h $HOST -p $PORT -U $USER  -w  -XAc "ALTER TABLE ONLY public.todos DROP CONSTRAINT todos_pkey;"
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
sed  -i -E 's/^(\$host)\s*=.*/\1 = '"\"$HOST\""';/g' $FILE
sed  -i -E 's/^(\$port)\s*=.*/\1 = '"\"$PORT\""';/g' $FILE
sed  -i -E 's/^(\$dbname)\s*=.*/\1 = '"\"$DB\""';/g' $FILE
sed  -i -E 's/^(\$user)\s*=.*/\1 = '"\"$USER\""';/g' $FILE
sed  -i -E 's/^(\$password)\s*=.*/\1 = '"\"$PASSWD\""';/g' $FILE

cp index-tmpl.html index.html
sed  -i -E 's/\$astraopsuser\$/'"$ASTRAOPSUSER"'/g' index.html
sed  -i -E 's/\$astraopsproject\$/'"$ASTRAOPSPROJECT"'/g' index.html


# systemctl status php8.1-fpm.service
# status=`systemctl status php8.1-fpm.service| grep Loaded| cut -d " " -f7`; 
# if [ $status == "masked" ]; then systemctl unmask php8.1-fpm.service && systemctl start php8.1-fpm.service && echo "PHP Service Unmasked & Started";else systemctl start php8.1-fpm.service; fi
systemctl unmask php8.1-fpm.service && systemctl start php8.1-fpm.service && echo "PHP Service Unmasked & Started"
sudo systemctl enable php8.1-fpm.service
cp index-tmpl.html /var/www/html/info.php
#provide the full permission to info.php
chmod 777 /var/www/html/info.php 
#backup the defalut file 
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default_bck
cp demo-nginx.conf /etc/nginx/sites-available/default

#check the syntax 
sudo nginx -t
#reload the nginx
sudo systemctl reload nginx


