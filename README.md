# VRS-flights-db
Code to export Virtual Radar Server flight records and track logs to a MySQL database. 

These instructions are for a simplified “all on one box” Linux deployment that is most likely not secured enough for public access i.e. I was not aiming to replicate public web server like http://flights.hillhome.org but rather run a version of this running on my private network. It works great BTW.

##Prerequisites
- VRS installed and running
- VRS database writer plugin configured and enabled
- A web server running PHP and MySQL. These instructions assume you will be using a Linux host, although you can use any OS.
- [phpMyAdmin](https://www.phpmyadmin.net) is very helpful for viewing your MySQL tables to ensure records are being populated correctly.
- On Raspbian php5-msql has a bug that throws an exception with flightimport.php so instead use
```
sudo apt-get install php5-mysqlnd 
```
  

##Instructions
Note: These instructions are not exhaustive.  You will need to be handy with Linux, MySQL, etc.  If you encounter issues, please log them here and I will update the documentation.

### Database schema
You will need to create a database and two tables on your MySQL database host.

```
mysql -u root
$create database adsb;
grant usage on *.* to vrsdbwriter@localhost identified by 'somepasswordhere';
grant all privileges on adsb.* to vrsdbwriter@localhost;
```

Now import the two .sql files in this repository:
```
use adsb;
source path/to/flights.sql
source path/to/track_mlat_lookup.sql
```

###Install sqlite for Linux
On Ubuntu this is typically done as follows : 
```
sudo apt-get install sqlite3
```

###Linux scripts
Place the files from the scripts directory of this repository in a directory of your choice on the VRS host:
- db_query.sh
- dbquerycommands.txt

The file db_query needs to be executable so do this :
```
sudo chmod +x db_query.sh
```
Double check all the paths in these files, as your setup may differ.

###PHP scripts
Place all the files from the webserver directory of this repository onto your web server in a flights directory under the web server's document root (example: Under Ubuntu this is /var/www/html/flights)

You will need to edit the config-example.php file and fill in your database connection information and your VRS hostname and port, plus username and password if your setup is password protected.  *Then rename the file to config.php.*

Now login to your web server and edit the crontab as follows:
```
crontab -e
```
Enter the following line into the file - this will run the getTrackMlat.php file every minute.
```
*/1 * * * * /usr/bin/php /var/www/html/flights/getTrackMlat.php >/dev/null
```
Save the file, and the new crontab will be installed.  After a few minutes, you should observe rows being added to the track_mlat_lookup table in your database.

You will now need to use schedule the script db_query.sh to run every 5 minutes, again using cron.

This time enter the following line :

```
*/5 * * * * [path to]/db_query.sh >/dev/null
```

That should complete the setup.  New flight records will be added to the flights table every 5 minutes, and the track log and MLAT flag will be merged in from the track_mlat_lookup table as part of the import process.

##Displaying Flight Data
(Work in Progress)

###flights.php
Displays a flight log with clickable links to the map page

###map.php
Displays the route and full track log
- Usage: http://webserver/flights/map.php?id=123456
  - Where 123456 is the flight's ID number from the database

###search.php
Search the database based on flight/aircraft details
