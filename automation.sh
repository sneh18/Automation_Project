#!/bin/bash

#Declaring reusable variables
name="Sneh"
s3_bucket="upgrad-sneh"

echo "Initiated automation.sh script execution"

# Update list of available packages
echo -n "Updating packages"
sudo apt update -y > /dev/null 2>&1
if [ $? -eq 0 ];
then
        echo " : Done"
else
        echo " : Failed (Exiting the script)"
        exit
fi

# Ensuring apache2 package is installed
is_apache_installed=$(dpkg -s apache2 2>/dev/null | grep 'Status:' | awk {'print $4'})
if [ "$is_apache_installed" = "installed" ];
then
        echo "Apache2 is already installed"
else
        echo -n "Apache2 is not installed, installing the same"
        sudo apt-get install apache2 -y > /dev/null 2>&1
        if [ $? -eq 0 ];
        then
                echo " : Done"
        else
                echo " : Failed (Exiting the script)"
                exit
        fi
fi

# Ensuring apache2 webserver is up & running
service apache2 status > /dev/null 2>&1
if [ $? -eq 0 ];
then
        echo "Apache2 is already running"
else
        echo -n "Starting Apache2 service"
        sudo service apache2 start > /dev/null 2>&1
        if [ $? -eq 0 ];
        then
                echo " : Done"
        else
                echo " : Failed (Exiting the script)"
                exit
        fi
fi

# Ensuring apache2 webserver is enabled to run at startup
systemctl is-enabled apache2 > /dev/null 2>&1
if [ $? -eq 0 ];
then
        echo "Apache2 is already enabled to run at startup"
else
        echo -n "Enabling Apache2 to run at startup"
        sudo systemctl enable apache2 > /dev/null 2>&1
        if [ $? -eq 0 ];
        then
                echo " : Done"
        else
                echo " : Failed (Exiting the script)"
                exit
        fi
fi

# Creating a tar archive of apache2 logs
timestamp=$(date '+%d%m%Y-%H%M%S')
archive_file_name="${name}-httpd-logs-${timestamp}.tar"
echo -n "Compressing apache2 log files into /tmp directory"
tar -cf /tmp/$archive_file_name /var/log/apache2/*.log > /dev/null 2>&1
if [ $? -eq 0 ];
then
        echo " : Done (Exported tar file named ${archive_file_name})"
else
        echo " : Failed (Exiting the script)"
        exit
fi

# Ensuring awscli package is installed
is_awscli_installed=$(dpkg -s awscli 2>/dev/null | grep 'Status:' | awk {'print $4'})
if [ "$is_awscli_installed" = "installed" ];
then
        echo "AWSCLI is already installed."
else
        echo -n "AWSCLI is not installed, installing the same"
        sudo apt-get install awscli -y > /dev/null 2>&1
        if [ $? -eq 0 ];
        then
                echo " : Done"
        else
                echo " : Failed (Exiting the script)"
                exit
        fi
fi

# Copying apache2 log files tar archive to AWS S3 bucket
echo -n "Copying exported logs archive to S3 Bucket '${s3_bucket}'"

aws s3 \
cp /tmp/${archive_file_name} \
s3://${s3_bucket} > /dev/null 2>&1

if [ $? -eq 0 ];
then
        echo " : Done"
else
        echo " : Failed (Exiting the script)"
        exit
fi

# Exiting the script with successful execution code
exit 0
