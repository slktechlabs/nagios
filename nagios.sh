#!/bin/bash
NAGIOS_VERSION="4.0.8"
NAGIOS_PLUGINGS="2.0.3"
NAGIOS_HOME="/usr/local/nagios"

sudo apt-get update
sudo apt-get install apache2 aptitude
#sudo apt-get install apache2 php5 libapache2-mod-php5 php5-mcrypt -- to remove 
sudo aptitude install  php5 libapache2-mod-php5 php5-mcryp
sudo apt-get install build-essential libgd2-xpm-dev openssl libssl-dev apache2-utils

sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
#http://stackoverflow.com/questions/26142420/nagios-could-not-open-command-file-usr-local-nagios-var-rw-nagios-cmd-for-up --error fix 
sudo usermod -a -G nagios www-data
sudo usermod -a -G nagcmd www-data

download="/tmp/download"
if [ -d $download ]; then
        echo "dir exists.........."
else
        echo "creating dir........"
        mkdir -p $download
fi
cd $download
if [ -e $download/nagios-$NAGIOS_VERSION.tar.gz ]; then 
        echo "file exists........."
else 
        echo "downloading file..."
        wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-$NAGIOS_VERSION.tar.gz
fi
tar xvzf nagios-$NAGIOS_VERSION.tar.gz
cd nagios-$NAGIOS_VERSION
sudo ./configure --with-nagios-group=nagios --with-command-group=nagcmd
sudo make all
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf
#make install-webconf -- option of above command
#-----------------------plugins-----------------------------------#
cd $download
if [ -e $download/nagios-plugins-$NAGIOS_PLUGINGS.tar.gz ]; then
	echo "file exists........."
else 
	echo "downloading file..."
	wget http://nagios-plugins.org/download/nagios-plugins-$NAGIOS_PLUGINGS.tar.gz
fi

tar xzf $download/nagios-plugins-$NAGIOS_PLUGINGS.tar.gz -C $download
cd $download/nagios-plugins-$NAGIOS_PLUGINGS
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
sudo make
sudo make install
sudo chown nagios.nagios /usr/local/nagios
sudo chown -R nagios:nagios /usr/local/nagios/libexec
#chown -R nagios:nagios /usr/local/nagios/rw/*
# rm -rf $download

#---------------------------------Configure Nagios Contacts-------------------------------#

sudo echo 'cfg_dir=/usr/local/nagios/etc/servers' >>/usr/local/nagios/etc/nagios.cfg
sudo mkdir /usr/local/nagios/etc/servers

if grep --quiet  nagios@localhost  /usr/local/nagios/etc/objects/contacts.cfg; then
        echo exists
else
        sudo echo 'define contact{
        contact_name                    nagiosadmin             ; Short name of user
        use                             generic-contact         ; Inherit default values from generic-contact template (defined above)
        alias                           Nagios Admin            ; Full name of user

        email                           nagios@localhost        ; <<***** CHANGE THIS TO YOUR EMAIL ADDRESS ******
        }' >>/usr/local/nagios/etc/objects/contacts.cfg

fi
#-----------------------------------Configure Apache-----------------------------------#

sudo a2enmod rewrite
sudo a2enmod cgi

#----------------Use htpasswd to create an admin user, called "nagiosadmin", that can access the Nagios web interface---------------------------#

sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin


#------------------------Now create a symbolic link of nagios.conf to the sites-enabled directory-------------------------#

sudo ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/

#------------------------------To enable Nagios to start on server boot, run this command---------------------#

sudo ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios

printf "Script Finished Successful :-D\n"
printf "\n"
printf "now use any browser and type http://nagios_server_public_ip/nagios \n"
printf "-------------------------- \n"
printf "USERNAME : nagiosadmin \n"
printf "PASSWORD : THAT U HAVE ENTER AT TIME OF RUNNING SCRIPT \n"
printf "-------------------------- \n"
printf "now use any browser and type http://nagios_server_public_ip/nagios \n"
printf "\n"
printf "if u get error processing php5 (--configure): \n"
printf "USE BELOW COMMAND & RE-EXECUTIVE THE SCRIPT AND REBOOT SYSTEM \n"
printf "sudo apt-get remove --purge php5-common php5-cli \n"
printf "\n"
printf "T: @ackbote\n"
printf "E:hel.venket@gmail.com\n"
printf "M:+918866442277\n"
printf "\n"
printf "Always share what you learn, in easy and confortable way --\n"
printf "\n"
printf "\n"
####-----------------help-------------------------##
#dpkg: error processing php5 (--configure):
#dependency problems - leaving unconfigured
#Errors were encountered while processing:
# php5-gd
# phpmyadmin
# libapache2-mod-php5
# php5
## use this command and re-executive the script "#sudo apt-get remove --purge php5-common php5-cli"
