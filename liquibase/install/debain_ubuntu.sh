#!/bin/sh
# This script will install liquibase on linux

# Setup Variables for Java-Version & Liquibase-Version
java_version="17"
liquibase_version="4.20.0"
liquibase_url="https://github.com/liquibase/liquibase/releases/download/v4.20.0/liquibase-4.20.0.tar.gz"

# Initialize Environment
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Install Necessary Packages
sudo apt install vim -y
# Install Java 17 (Java is required for Liquibase)
sudo apt install openjdk-"$java_version"-jdk -y

# Install Liquibase
if [ -d "/opt/liquibase" ]; then
    echo "Liquibase is already installed"
else
    echo "Installing Liquibase"
    sudo mkdir /opt/liquibase
    sudo chown -R "$USER":"$USER" /opt/liquibase
    cd /opt/liquibase || exit
    wget "$liquibase_url"
    tar -xvzf liquibase-"$liquibase_version".tar.gz
    rm liquibase-"$liquibase_version".tar.gz
    sudo ln -s /opt/liquibase/liquibase /usr/local/bin/liquibase
fi

