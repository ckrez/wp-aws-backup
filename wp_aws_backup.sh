#!/bin/bash
#set -xv
 
#Edit these variables
backupDir="/var/backups/"
siteName="<site_name>"
siteFolder="/var/www/"
LEFolder="/etc/letsencrypt/"
dbHost="localhost"
dbName="<db_name>"
dbUser="db_user"
dbPass="<db_password>"
s3bucket="s3://<s3_bucket>"
#Stop editing
 
dateTimeStamp=`date '+%Y%m%d_%H%M'`
dbBackupFile="${backupDir}${dbName}_${dateTimeStamp}.sql"
 
#Create database dump
/usr/bin/mysqldump --user=$dbUser --password=$dbPass --host=$dbHost $dbName > $dbBackupFile
 
#Zip files
/usr/bin/zip -r "${backupDir}/${siteName}_${dateTimeStamp}.zip" $siteFolder $dbBackupFile $LEFolder
 
#Remove database dump
/bin/rm -f $dbBackupFile

# Rotate Files
/bin/find $backupDir -type f -mtime +7 -print -exec rm -f {} \;

# Sync with S3
/usr/bin/aws s3 sync $backupDir $s3bucket --delete --sse AES256
