#!/bin/bash

sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install php-xml
#sudo apt-get -y install php-xdebug
sudo service apache2 restart

#sudo composer self-update
