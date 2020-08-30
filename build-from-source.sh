#!/bin/bash

echo "building besu from source..."
sudo apt-get install libsodium23 -y
git clone --recursive https://github.com/hyperledger/besu
cd besu
git config --global user.name "Freight Trust Build Service"

git config --global user.email "engineering@freighttrust.com"
./gradlew tasks
./gradlew distZip

export "$ENV"
