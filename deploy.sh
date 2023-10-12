#!/bin/bash 


HOST=$1
PORT=$2
USER=$3
PASSWD=$4
DB=$5
ASTRAOPSUSER=$6
ASTRAOPSPROJECT=$7


echo "Installing dependencies, Postgres client binaries.."
apt-get update
apt-get install nginx php-fpm php-pgsql postgresql-client-common php -y

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


systemctl status php8.1-fpm.service
status=`systemctl status php8.1-fpm.service| grep Loaded| cut -d " " -f7`; 
if [ $status == "masked" ]; then systemctl unmask php8.1-fpm.service && systemctl start php8.1-fpm.service && echo "PHP Service Unmasked & Started";else systemctl start php8.1-fpm.service; fi
sudo systemctl enable php8.1-fpm.service

#provide the full permission to info.php
chmod 777 /var/www/html/app.php 
#backup the defalut file 
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default_bck
cp demo-nginx.conf /etc/nginx/sites-available/default

#check the syntax 
sudo nginx -t
#reload the nginx
sudo systemctl reload nginx


