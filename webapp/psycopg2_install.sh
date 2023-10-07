#!/bin/bash

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with root privileges. Please use sudo or run as root."
  exit 1
fi

# Install psycopg2-binary using pip
pip install psycopg2-binary

# Check if the installation was successful
if [ $? -eq 0 ]; then
  echo "psycopg2-binary has been successfully installed."
else
  echo "An error occurred during installation."
  exit 1
fi

# Update the package lists
apt-get update

# Install libpq-dev and python3-dev
apt-get install -y libpq-dev python3-dev

# Check if the installations were successful
if [ $? -eq 0 ]; then
  echo "libpq-dev and python3-dev have been successfully installed."
else
  echo "An error occurred during installation."
  exit 1
fi

# Install psycopg2 using pip
pip install psycopg2

# Check if the installation was successful
if [ $? -eq 0 ]; then
  echo "psycopg2 has been successfully installed."
else
  echo "An error occurred during installation."
  exit 1
fi

