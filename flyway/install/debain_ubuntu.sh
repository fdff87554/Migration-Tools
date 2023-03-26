#!/bin/sh
# This script will install flyway on linux (Debian/Ubuntu)
# The flyway download is from https://flywaydb.org/download/community

# Setup Variables for Flyway-Version
flyway_version="9.16.1"
flyway_url="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/$flyway_version/flyway-commandline-$flyway_version-linux-x64.tar.gz"
echo "Flyway Version: $flyway_version"
echo "Flyway URL: $flyway_url"

# Initialize Environment
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Install Necessary Packages
sudo apt install git vim -y

# Install Flyway
if [ -d "/opt/flyway" ]; then
    echo "Flyway is already installed"
else
    echo "Installing Flyway"
    sudo mkdir /opt/flyway
    sudo chown -R "$USER":"$USER" /opt/flyway
    cd /opt/flyway || exit
    wget "$flyway_url"
    tar -xvzf flyway-commandline-"$flyway_version"-linux-x64.tar.gz
    rm flyway-commandline-"$flyway_version"-linux-x64.tar.gz
    sudo ln -s /opt/flyway/flyway-"$flyway_version"/flyway /usr/local/bin/flyway
fi

# Copy Flyway Examples to Home Directory
if [ -d "$HOME/flyway" ]; then
    echo "Flyway Examples are already installed"
else
    echo "Copying Flyway Examples"
    mkdir "$HOME/flyway"
    cd "$HOME/flyway" || exit
    sudo cp -r /opt/flyway/flyway-"$flyway_version" .
fi
