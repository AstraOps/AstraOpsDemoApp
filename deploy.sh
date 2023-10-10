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
