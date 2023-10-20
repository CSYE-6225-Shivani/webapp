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

# Install PostgreSQL (if not already installed)
if ! command -v psql &> /dev/null; then
  apt install -y postgresql
fi

# Check if PostgreSQL is running
if ! systemctl is-active --quiet postgresql; then
  echo "PostgreSQL is not running. Starting PostgreSQL..."
  systemctl start postgresql
fi

# Check if PostgreSQL started successfully
if ! systemctl is-active --quiet postgresql; then
  echo "Failed to start PostgreSQL. Please check the PostgreSQL service status."
  exit 1
fi

# Create PostgreSQL user
sudo -u postgres psql -c "CREATE USER admin WITH PASSWORD '1234';"

# Check if the user was created successfully
if [ $? -eq 0 ]; then
  echo "PostgreSQL user 'admin' has been created."
else
  echo "An error occurred while creating the PostgreSQL user."
  exit 1
fi

# Grant superuser privileges to the PostgreSQL user
sudo -u postgres psql -c "ALTER USER admin SUPERUSER;"

# Check if superuser privileges were granted successfully
if [ $? -eq 0 ]; then
  echo "Superuser privileges have been granted to 'admin'."
else
  echo "An error occurred while granting superuser privileges."
  exit 1
fi

# Start postgresql service
sudo service postgresql start

# Check if postgresql service has started
if [ $? -eq 0 ]; then
  echo "Postgresql service has been started."
else
  echo "An error occurred while starting postgresql."
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

echo "Packages installation completed successfully."
