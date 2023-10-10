#!/bin/bash 
FILE="db_conn.php"
cp db_conn_tmpl.php $FILE
sed  -i -E 's/^(\$DBHOST)\s*=.*/\1 = '"\"$1\""';/g' $FILE
sed  -i -E 's/^(\$DBNAME)\s*=.*/\1 = '"\"$2\""';/g' $FILE
sed  -i -E 's/^(\$USERNAME)\s*=.*/\1 = '"\"$3\""';/g' $FILE
sed  -i -E 's/^(\$PASSWORD)\s*=.*/\1 = '"\"$4\""';/g' $FILE
