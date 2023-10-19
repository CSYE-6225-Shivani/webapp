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

# Install python3-pip, python3.10-venv, and unzip
apt install -y python3-pip python3.10-venv unzip

# Check if the installations were successful
if [ $? -eq 0 ]; then
  echo "python3-pip and python3.11-venv have been successfully installed."
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


# Download the ngrok binary
NGROK_URL="https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip"
wget $NGROK_URL -O ngrok.zip

# Unzip the ngrok archive
unzip ngrok.zip

# Move the ngrok binary to a directory in your PATH
mv ngrok /usr/local/bin/

# Set the executable permission
chmod +x /usr/local/bin/ngrok

# Clean up by removing the downloaded zip file
rm ngrok.zip

# Print ngrok version information
ngrok --version

echo "ngrok has been successfully installed."

