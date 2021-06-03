#!/bin/bash

# @package    HR IT-Solutions - Deployment - DD_J_ShellInstaller
#
# @author     HR IT-Solutions Florian Häusler <info@hr-it-solutions.com>
# @copyright  Copyright (C) 2017 - 2017 Didldu e.K. | HR IT-Solutions
# @license    http://www.gnu.org/licenses/gpl-2.0.html GNU/GPLv2 only

# Load config library functions
source "$PWD"/config.shlib;
#!bin/bash

## Configuration
user=admin
domain="$(cat /etc/hostname)"

export VESTA=/usr/local/vesta/

############

## Script

# FOLDER_NAME="USER INPUT"
SITEDIR="/home/$user/web/$domain/public_html"

rm -rf $SITEDIR/*

JOOMLA_PACKAGE=Joomla_3-9-27-Stable-Full_Package.zip

# Change to webdir
cd $SITEDIR/

# Get Joomla Version
wget https://downloads.joomla.org/us/cms/joomla3/3-9-27/$JOOMLA_PACKAGE

# Unzip Jooomla Version
unzip $JOOMLA_PACKAGE

printf "\mkdir Joomla successfull\n"

DBUSERSUFB="joomla"
i=0;
while [ $i -lt 99 ]
do
i=$((i+1));
DBUSERSUF="${DBUSERSUFB}${i}";
DBUSER=$user\_$DBUSERSUF;
if [ ! -d "/var/lib/mysql/$DBUSER" ]; then
break;
fi
done
PASSWDDB=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)


/usr/local/vesta/bin/v-add-database $user $DBUSERSUF $DBUSERSUF $PASSWDDB mysql

# Function jinstall
jinstall () {

	# Place jinstaller.sql to sql mysql installation folder
	cp "$PWD"/jinstaller.sql $SITEDIR/installation/sql/mysql/
	
	DBHOST=localhost
	DBPREFIX="joomla"
    #
	# Go to installation mysql folder
	cd installation/sql/mysql/

	# Add jinstaller.sql to joomla.sql
	cat jinstaller.sql >> joomla.sql

	# Set Prefix
	sed -i -e "s/#__/$DB_PREFIX/g" joomla.sql

	# MySQL Import
	mysql -uroot $DBUSERSUF < joomla.sql

	# Go to installation folder
	cd $SITEDIR/installation/

	# Set Configuration.php
	sed -i -e "s/host = \x27localhost\x27/host = \x27$DBHOST\x27/g" configuration.php-dist
	sed -i -e "s/user = \x27\x27/user = \x27$DBUSERSUF\x27/g" configuration.php-dist
	sed -i -e "s/password = \x27\x27/password = \x27$PASSWDDB\x27/g" configuration.php-dist
	sed -i -e "s/db = \x27\x27/db = \x27$DBUSERSUF\x27/g" configuration.php-dist
	sed -i -e "s/dbprefix = \x27jos_\x27/dbprefix = \x27$DBPREFIX\x27/g" configuration.php-dist

	sed -i -e "s/tmp_path = \x27\/tmp\x27/tmp_path = \x27html\/$SITEDIR\/tmp\x27/g" configuration.php-dist
	sed -i -e "s/log_path = \x27\/var\/logs\x27/log_path = \x27html\/$SITEDIR\/administrator\/logs\x27/g" configuration.php-dist

	# Place configuration.php
	cp configuration.php-dist $SITEDIR/configuration.php-dist
	cd $SITEDIR
    mv configuration.php-dist configuration.php
	# Function uninstallInstallltaion

	rm -rf $SITEDIR/installation
	exit 0
#
#
##hile true; do
	#rintf "\nDo you want to uninstall installation folder:\n"
	#ead -p "Answer: ([Y] Yes [N] No)." yn
	#case $yn in
#		[Yy]* ) uninstallInstallltaion; break;;#
	#	[Nn]* ) exit;
#		* ) echo "Please answer yes or no.";;
#	esac
#done
#

#hile true; do
#rintf "\nDo you want to install $J_VERSION Database and create configuration.php:\n"
#ead -p "Answer: ([Y] Yes [N] No)." yn
#case $yn in
#	[Yy]* ) jinstall; break;;
#	[Nn]* ) exit;;
#	* ) echo "Please answer yes or no.";;
#esac
#done
