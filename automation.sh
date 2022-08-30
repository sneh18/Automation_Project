#!/bin/bash

#Declaring reusable variables
name="Sneh"

echo "Initiated automation.sh script execution"
echo -n "Updating packages"
sudo apt update -y > /dev/null 2>&1
echo " : Done"

is_apache_installed=$(dpkg -s apache2 | grep 'Status:' | awk {'print $4'})

if [ $is_apache_installed = "installed" ];
then
        echo "Apache2 is already installed."
else
        echo -n "Apache2 is not installed, installing same"
        sudo apt-get install apache2 -y > /dev/null 2>&1
        echo " : Done"
fi

service apache2 status > /dev/null 2>&1
if [ $? -eq 0 ];
then
        echo "Apache2 is already running"
else
        echo -n "Starting Apache2 service"
        sudo service apache2 start > /dev/null 2>&1
        echo " : Done"
fi

systemctl is-enabled apache2 > /dev/null 2>&1
if [ $? -eq 0 ];
then
        echo "Apache2 is already enabled to run at startup"
else
        echo -n "Enabling Apache2 to run at startup"
        sudo systemctl enable apache2 > /dev/null 2>&1
        echo " : Done"
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
archive_file_name="${name}-httpd-logs-${timestamp}.tar"
echo -n "Compressing apache2 log files into /tmp directory"
tar -cf /tmp/$archive_file_name /var/log/apache2/*.log > /dev/null 2>&1
echo " : Done (Exported tar file named ${archive_file_name})"
