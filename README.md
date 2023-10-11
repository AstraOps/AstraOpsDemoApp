Quick start guide for your desktop (Just for ref)
# AstraOpsDemoApp
* Clone this repository
* Configure the db_conn.php file with your data base details
* Install xampp
* run the command "sudo nano /etc/hosts" in terminal (a file will be opened)
* add the line "127.0.0.1  your-ip-address" and write out the file
* Open xampp -> Open application folder -> open the folder "htdocs"
* Place the project file(cloned file) inside "htdocs" folder
* In browser search "your-ip-address/dashboard"
* Select "phpMyAdmin"
* Create a new database and table
* In browser search "your-ip-address/your-project-file-name(php-to-do-list-master in this project)" to access the database 



Deploy in UBUNTU
git clone git@github.com:AstraOps/AstraOpsDemoApp.git AstraOpsDemoApp
cd AstraOpsDemoApp.git
chmod +x deploy.sh
1 ./deploy.sh DBHOST DBPORT DBUSER DBPASS DBNAME(eg: ./deploy.sh 10.10.10.21 5678  postgres mypass todo_demo) 

Installs client binaries for Postgres
Creates DB
Verifies DB 
Dumps SQL Data
Creates db_conn.php from template, db_conn_tmpl.php. DB Details would be available for AstraOps Core JSON client file. Ensure, RDS is created before EC2.

* Clone this repository and rename the file index.php to info.php and move to the location var/www/html
* give full permission to the info.php file by using the command "chmod 777"
* Write a new file named php.conf in nginx. The file path is etc/nignx/sites-enabled
* Write the required contents inside php.conf
* Set syntax to the file php.conf using the command "sudo nginx -t"
* Reloaad nginx using the command "sudo systemctl reload nginx"
* Now the nginx listens to port 80


