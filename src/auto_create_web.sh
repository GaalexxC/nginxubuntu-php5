#!/bin/bash
# @author: Gary Cornell for devCU Software
# @contact: support@devcu.com
# @Facebook: facebook.com/garyacornell
# Created for Ubuntu 12x | 14x Servers - Please Read Comments in Code for Proper Configuration
# MAIN: http://www.devcu.com 
# REPO: http://www.devcu.net
# Created:   01/15/2013
# Updated:   02/19/2016

# Default sytem values-
# You may edit these to match your system setup
# If altering HOME_PARTITION be sure to modify /etc/adduser.conf to match
HOME_PARTITION='home'
ROOT_DIRECTORY='public_html'
WEB_SERVER_GROUP='www-data'
# PHP5 packages that will be installed or updated. Please add or remove the packages to suit your needs
PHP5_PACKAGES='php5-fpm php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-apcu php5-memcache php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl'
# Path defaults below, shouldnt need editing
NGINX_SITES_AVAILABLE='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
PHP_INI_DIR='/etc/php5/fpm/pool.d'
NGINX_INIT='service nginx reload'
PHP_FPM_INIT='service php5-fpm restart'
PHP_FPM_INI='/etc/php5/fpm/php.ini'
PHP_CLI_INI='/etc/php5/cli/php.ini'
FIX_PATHINFO='cgi.fix_pathinfo=0'
APT_SOURCES='/etc/apt/sources.list'
NGINX_MAINLINE='http://nginx.org/packages/mainline/ubuntu/'
# --------------END 
asd() {
cat <<"EOT"

    .-"^`\                                        /`^"-.
  .'   ___\                                      /___   `.
 /    /.---.                                    .---.\    \
|    //     '-.  ___________________________ .-'     \\    |
|   ;|         \/--------------------------//         |;   |
\   ||       |\_)      devCU Software      (_/|       ||   /
 \  | \  . \ ;  |         Presents         || ; / .  / |  /
  '\_\ \\ \ \ \ |                          ||/ / / // /_/'
        \\ \ \ \|     Nginx Ubuntu 2.02    |/ / / //
         `'-\_\_\       Setup Script       /_/_/-'`
                '--------------------------'
EOT
}

asd

echo -e "\nJust double checking your setup, /$HOME_PARTITION partition with $ROOT_DIRECTORY as your root ?"

read -p "If yes then hit ENTER and lets go..."

# Upgrade Nginx to mainline
echo "Do you want to upgrade Nginx to latest mainline version (y/n)"
read CHECKNGINX
if [ $CHECKNGINX == "y" ]; then
      echo -e  "\nChecking if Nginx mainline repo exists"
  if grep -q $NGINX_MAINLINE $APT_SOURCES; then
      echo "Great! we found '$NGINX_MAINLINE' lets update:"
      echo -e  "\nLooking for nginx update, this may take a few seconds..."
      apt-get -qq update
      apt-get install nginx -y
      nginx -v
      echo -e "\nNginx Updated"
  else
      echo "We couldnt find '$NGINX_MAINLINE' adding it now and updating:"
      echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> $APT_SOURCES
      echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> $APT_SOURCES
      echo -e  "\nLooking for nginx update, this may take a few seconds..."
      apt-get -qq update
      apt-get install nginx -y
      nginx -v
      echo -e "\nNginx Updated"
  fi
else
      echo -e "\nSkipping Nginx mainline update"
fi
# Check for system update
echo "Do you want to check for system update (y/n)"
read CHECKUPDATE
if [ $CHECKUPDATE == "y" ]; then
      echo -e  "\nLooking for system updates, this may take a few seconds..."
      apt-get -qq update
      apt-get upgrade -y
      echo -e "\nSystem Updated"
else
      echo -e "\nSkipping system update"
fi
# Check for Kernel update
echo "Do you want to check for kernel update (y/n)"
read CHECKUPDATE
if [ $CHECKUPDATE == "y" ]; then
      echo -e  "\nUpdating Kernel"
      aptitude safe-upgrade -y
      echo -e "\nKernel Updated"
else
      echo -e "\nSkipping kernel update"
fi
# Install Software
echo -e "\nInstalling Required Applications"
apt-get install $PHP5_PACKAGES
echo -e "\nPHP Installed"
apt-get install nginx fcgiwrap openssl -y
echo -e "\nSystem Updated"

# Security Update
echo -e "\nGenerating Diffie-Hellman for TLS"
if [ -f /etc/ssl/certs/dhparam.pem ]
then
    echo -e "\nGreat! the file exists"
else
    openssl dhparam 2048 -out /etc/ssl/certs/dhparam.pem
fi
echo -e "\nFinsihed DH TLS Generation"

# -------
# PHP INI CONFIG:
# -------
echo -e "\nSecure PHP INI for FPM - cgi.fix_pathinfo=0"
echo -e "\nChecking /etc/php5/fpm/php.ini"
if grep -q $FIX_PATHINFO $PHP_FPM_INI;
 then
     echo "Nothing to do we found '$FIX_PATHINFO':"
 else
     echo -e "\nNot found, updating file"
     sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $PHP_FPM_INI
     echo -e "\nphp.ini Updated"
fi

echo -e "\nSecure PHP INI for CLI - cgi.fix_pathinfo=0"
echo -e "\nChecking /etc/php5/cli/php.ini"
if grep -q $FIX_PATHINFO $PHP_CLI_INI;
 then
     echo "Nothing to do we found '$FIX_PATHINFO':"
 else
     echo -e "\nNot found, updating file"
     sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' $PHP_CLI_INI
     echo -e "\nphp.ini Updated"
fi

read -p "Great! System is ready for your domain and user, hit ENTER to continue..."

# Confirgure Domain
echo -e "\nCreate Web/User"

SED=`which sed`
CURRENT_DIR=`dirname $0`

if [ -z $1 ]; then
	echo "No Domain Name Given"
	exit 1
fi
DOMAIN=$1

# Check the domain is valid!
PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	echo "Creating Hosting For:" $DOMAIN
else
	echo "Invalid Domain Name"
	exit 1 
fi

# Configure IP Address
echo -n "Available Server IP Addresses "
hostname -I
echo -n "Enter Domain IP Address > "
read IP
echo "You Entered: $IP"

# Check if the servers IP is valid! Work in progress
#PATTERN="^(([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$";
#
#if [[ "$IP" =~ $PATTERN ]]; then
#	IP=`echo $IP | tr '[0-9]'`
#	echo "Creating Server IP For:" $IP
#else
#	echo "Invalid IP Address"
#	exit 1 
#fi

# Create a new user
echo "Please Specify The Username then Password For This Site"
read USERNAME
HOME_DIR=$USERNAME
adduser $USERNAME

# Create directories - files
echo "Would You Like To Change The Web Root Directory, default is /$HOME_PARTITION/$HOME_DIR/$ROOT_DIRECTORY/ no (y/n)?"
read CHANGEROOT
if [ $CHANGEROOT == "y" ]; then
	echo "Enter the new web root dir (after the public_html/)"
	read DIR
	PUBLIC_HTML_DIR=/$ROOT_DIRECTORY/$DIR
else
	PUBLIC_HTML_DIR=/$ROOT_DIRECTORY
fi

# -------
# NGINX CONFIG:
# -------
echo -e "\nCreate nginx $NGINX_SITES_AVAILABLE if doesnt exist"
if [ -d "$NGINX_SITES_AVAILABLE" ]
then
    echo -e "Directory $NGINX_SITES_AVAILABLE exists."
else
    mkdir -p $NGINX_SITES_AVAILABLE
    echo -e "\nFinsihed directory creation"
fi

echo -e "\nCreate nginx $NGINX_SITES_ENABLED if doesnt exist"
if [ -d "$NGINX_SITES_ENABLED" ]
then
    echo -e "Directory $NGINX_SITES_ENABLED exists."
else
    mkdir -p $NGINX_SITES_ENABLED
    echo -e "\nFinsihed directory creation"
fi

# Create a new domain vhost
CONFIG=$NGINX_SITES_AVAILABLE/$DOMAIN.vhost
cp $CURRENT_DIR/nginx.vhost.template $CONFIG
echo -e "\nInstall vhost conf"

# -------
# NGINX VHOST:
# -------
echo -e "\nCreate nginx vhosts.conf if doesnt exist"
if [ -f /etc/nginx/conf.d/vhosts.conf ]
then
    echo -e "\nGreat! the file exists"
else
    echo -e "\nThe file doesnt exist, creating..."
    touch /etc/nginx/conf.d/vhosts.conf
    echo "include /etc/nginx/sites-enabled/*.vhost;" >>/etc/nginx/conf.d/vhosts.conf
fi
echo -e "\nFinsihed vhosts.conf creation"

$SED -i "s/@@HOSTNAME@@/$DOMAIN/g" $CONFIG
$SED -i "s/@@IPADD@@/$IP/g" $CONFIG
$SED -i "s#@@PATH@@#\/$HOME_PARTITION\/"$USERNAME$PUBLIC_HTML_DIR"#g" $CONFIG
$SED -i "s/@@LOG_PATH@@/\/$HOME_PARTITION\/$USERNAME\/logs/g" $CONFIG
$SED -i "s/@@SSL_PATH@@/\/$HOME_PARTITION\/$USERNAME\/ssl/g" $CONFIG
$SED -i "s#@@SOCKET@@#/var/run/"$USERNAME"_fpm.sock#g" $CONFIG

echo "FPM max children, must be higher then max servers, try 8:"
read MAX_CHILDREN
echo -e "\n# start FPM servers, start servers must not be less than min spare servers and not greater than max spare servers, try 4:"
read FPM_SERVERS
echo -e "\nMin # spare FPM servers, try 2:"
read MIN_SERVERS
echo -e "\nMax # spare FPM servers, try 6:"
read MAX_SERVERS

# Create a new php fpm pool config
echo -e "\nInstall PHP FPM conf file"
FPMCONF="$PHP_INI_DIR/$DOMAIN.conf"
cp $CURRENT_DIR/conf.template $FPMCONF
$SED -i "s/@@USER@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@GROUP@@/$USERNAME/g" $FPMCONF
$SED -i "s/@@HOME_DIR@@/\/$HOME_PARTITION\/$USERNAME/g" $FPMCONF
$SED -i "s/@@MAX_CHILDREN@@/$MAX_CHILDREN/g" $FPMCONF
$SED -i "s/@@START_SERVERS@@/$FPM_SERVERS/g" $FPMCONF
$SED -i "s/@@MIN_SERVERS@@/$MIN_SERVERS/g" $FPMCONF
$SED -i "s/@@MAX_SERVERS@@/$MAX_SERVERS/g" $FPMCONF

echo -e "\nSet Permissions"
usermod -aG $USERNAME $WEB_SERVER_GROUP
chmod g+rx /$HOME_PARTITION/$HOME_DIR
chmod 600 $CONFIG
ln -s $NGINX_SITES_AVAILABLE/$DOMAIN.vhost $NGINX_SITES_ENABLED/

# set file perms and create required dirs!
echo -e "\nInstall web directories"
mkdir -p /$HOME_PARTITION/$HOME_DIR$PUBLIC_HTML_DIR
mkdir -p /$HOME_PARTITION/$HOME_DIR/logs
mkdir -p /$HOME_PARTITION/$HOME_DIR/ssl
mkdir -p /$HOME_PARTITION/$HOME_DIR/_sessions
mkdir -p /$HOME_PARTITION/$HOME_DIR/backup

echo -e "\nSet Permissions"
chmod 750 /$HOME_PARTITION/$HOME_DIR -R
chmod 700 /$HOME_PARTITION/$HOME_DIR/_sessions
chmod 770 /$HOME_PARTITION/$HOME_DIR/ssl
chmod 770 /$HOME_PARTITION/$HOME_DIR/logs
chmod 770 /$HOME_PARTITION/$HOME_DIR/backup
chmod 750 /$HOME_PARTITION/$HOME_DIR$PUBLIC_HTML_DIR
chown $USERNAME:$USERNAME /$HOME_PARTITION/$HOME_DIR/ -R
chown root:root /$HOME_PARTITION/$HOME_DIR/ssl -R
chown root:root /$HOME_PARTITION/$HOME_DIR/backup -R

echo -e "\nRestart Services"
$NGINX_INIT
echo
$PHP_FPM_INIT

echo -e "\nUpdate Grub in case we upgraded kernel, you must reboot server if new Kernel is to be effective"
update-grub

echo -e "\nCleanup Files"
apt-get autoremove
apt-get autoclean

echo -e "\nLooks like we are done, weee no errros"

echo -e "\nWeb Created for $DOMAIN for user $USERNAME with PHP support"
