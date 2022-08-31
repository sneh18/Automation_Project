# Automation Project
This repo contains script named automation.sh which will be responsible for automating below mentioned tasks,
* Install the Apache2 webserver
* Start the Apache2 Webserver
* Enable Apache2 Webserver to run at startup
* Creates a tar file of apache2 log files and exports it to given AWS S3 Bucket
* Keeps track of created logs archive files by writing details to inventory.html file
* Sets cron job to run this script everyday at 12:00 AM
