#!/bin/bash
### SHELL SCRIPT TO INSTALL NECESSARY PACKAGES ###

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with root privileges. Please use sudo or run as root."
  exit 1
fi

# Update the package lists
apt update
apt upgrade -y

# Install python3-pip and unzip
apt install -y python3-pip unzip

# Check if the installations were successful
if [ $? -eq 0 ]; then
  echo "python3-pip has been successfully installed."
else
  echo "An error occurred during installation."
  exit 1
fi

# Install Python packages to run webapp
handle_error() {
    echo "Error: $1"
    exit 1
}

# Install individual packages
sudo apt-get install -y python3-flask
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-flask"
fi

sudo apt-get install -y python3-numpy
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-numpy"
fi

sudo apt-get install -y python3-sqlalchemy
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-sqlalchemy"
fi

sudo apt-get install -y python3-sqlalchemy-utils
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-sqlalchemy-utils"
fi

sudo apt-get install -y python3-psycopg2
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-psycopg2"
fi

sudo apt-get install -y python3-flask-bcrypt
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-flask-bcrypt"
fi

sudo apt-get install -y python3-flask-httpauth
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-flask-httpauth"
fi

sudo apt-get install -y python3-dotenv
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-dotenv"
fi

sudo apt-get install -y python3-statsd
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-statsd"
fi

echo "Packages installation completed successfully."

sudo apt-get install -y python3-boto3
if [ $? -ne 0 ]; then
    handle_error "Failed to install python3-boto3"
fi

# Install aws cloudwatch agent
cd /opt/
wget https://amazoncloudwatch-agent.s3.amazonaws.com/debian/amd64/latest/amazon-cloudwatch-agent.deb
if [$? -ne 0]; then
    handle_error "Failed to get amazon-cloudwatch-agent.deb"
fi