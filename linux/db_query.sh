#!/bin/bash
THEDATABASE=/path_to/BaseStation.sqb
echo $THEDATABASE
THECSVFILE=/var/www/html/flights/flights.csv
SQLFILE=/path_to/dbquerycommands.txt
echo $THECSVFILE
if test -e $THECSVFILE;  then rm $THECSVFILE; fi
# :: allow time for the csv file to be deleted
sleep 2s
/usr/local/bin/sqlite3 $THEDATABASE < $SQLFILE
# ::allow time for the csv to be written to file
sleep 2s
#
# Initiate processing of this CSV file
/usr/bin/php /var/www/html/flights/flightimport.php
