<?php 


$host = "localhost";
$port = "5432";  // PostgreSQL default port
$dbname = "to_do_list";
$user = "postgres";
$password = "deepak";

try {
    $conn = new PDO("pgsql:host=$host;port=$port;dbname=$dbname;user=$user;password=$password");
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
