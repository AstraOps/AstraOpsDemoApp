<?php 

$DBHOST = "localhost";
$DBPORT = 5678;
$USERNAME = "root";
$PASSWORD = "";
$DBNAME = "to_do_list";

try {
    $conn = new PDO("mysql:host=$DBHOST;dbname=$DBNAME", 
                    $USERNAME, $PASSWORD);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}catch(PDOException $e){
  echo "Connection failed : ". $e->getMessage();
}
