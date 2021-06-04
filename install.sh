#!bin/bash
#Firs Conf
#rm -rf tmp/*
user=admin
domain="$(cat /etc/hostname)"
#Load library func
source /home/$user/web/$domain/joomla/config.shlib;

#Site directory configuration
SITEDIR="$(config_get $SITEDIR)"

echo "########################################################"
echo "########################################################"

export VESTA=/usr/local/vesta/
SITEDIR="/home/$user/web/$domain/public_html"

rm -rf $SITEDIR/*

JOOMLA_PACKAGE=Joomla_3-9-27-Stable-Full_Package.zip

# Change to dir
cd $SITEDIR/

# Get & unzip Joomla_latest
wget https://downloads.joomla.org/us/cms/joomla3/3-9-27/$JOOMLA_PACKAGE
unzip $JOOMLA_PACKAGE

printf "\mkdir Joomla successfull\n"

DBUSERSUFB="joo";
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

# Function install
        # Place install.sql to sql mysql installation folder
        cp /home/$user/web/$domain/joomla/jinstaller.sql $SITEDIR/installation/sql/mysql/
#
        DBPREFIX="joo"
#    #
#        # Go to installation mysql folder
        cd installation/sql/mysql/
#        # Add install.sql to joomla.sql
        cat jinstaller.sql >> joomla.sql
#
#        # Set Prefix
sed -i -e "s/#__/$DBPREFIX/g" joomla.sql
        # MySQL Import
        mysql -uroot $DBUSER < joomla.sql

        # Go to installation folder
        cd $SITEDIR/installation/

        # Set Configuration.php

#       sed -i -e "s/host = \x27localhost\x27/host = \x27$DB_HOST\x27/g" configuration.php-dist
	sed -i -e "s/user = \x27\x27/user = \x27$DBUSER\x27/g" configuration.php-dist
	sed -i -e "s/password = \x27\x27/password = \x27$PASSWDDB\x27/g" configuration.php-dist
	sed -i -e "s/db = \x27\x27/db = \x27$DBUSER\x27/g" configuration.php-dist
	sed -i -e "s/dbprefix = \x27jos_\x27/dbprefix = \x27$DBPREFIX\x27/g" configuration.php-dist
	sed -i -e "s/tmp_path = \x27\/tmp\x27/tmp_path = \x27$SITEDIR\/tmp\x27/g" configuration.php-dist
	sed -i -e "s/log_path = \x27\/var\/logs\x27/log_path = \x27$SITEDIR\/administrator\/logs\x27/g" configuration.php-dist
#html - in sed
# Place configuration.php
        cp configuration.php-dist $SITEDIR/configuration.php-dist
        cd $SITEDIR
    mv configuration.php-dist configuration.php
        # Function uninstallInstallltaion
    
		rm -rf $SITEDIR/installation

chown -R $user. $SITEDIR
chmod -R 755 $SITEDIR

exit 0 
