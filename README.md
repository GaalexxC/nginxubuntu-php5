# nginxubuntu-php5

<pre>
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
</pre>

A bash script that automates Nginx, PHP5x,  PHP-FPM and User/Domain setup in a couple minutes. For NEW/Fresh server installs but can be used to setup-add new user/domain and directory structure anytime

Created for Ubuntu 12x | 14x Servers but should work on all Debian flavors - Please Read Comments in Code for Proper or custom Configuration

Uses a standard $HOME/$USER/public_html directory setup but can be edited for any type directory structure

## Optional

- Runs a apt-get update/upgrade if applicable

- Optional install latest mainline Nginx (recommended)

- Optional update to latest Linux Kernel (recommended)

- Optional PHP5 install w/dependencies

- Optional php.ini secured (recommended)

- Optional Generates 2048 Diffie-Hellman for TLS (recommended)(OpenSSL required)

- Editable options see below

## Functions

- Setup/Create Nginx directory structure, sites available/enabled/domain.vhost conf

- Updates cgi.fix_pathinfo=0 in fpm and cli php.ini

- Setup/Create php-fpm directory structure, domain.conf

- Setup/Create user/pass with domain/IP and public_html directory structure

- Sets all proper permissions on relevant directories.


### Creates the following $HOME directory structure

- $HOME
    - $USER
        - _sessions
        - backups
        - logs
        - public_html
        - ssl
        
        
## Editable
```shell
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
```

## Simple Usage

1. cd /opt  (Any directory you choose is fine)

2. wget

3. cd src

4. chmod u+x auto_create_web.sh

5. auto_create_web.sh yourdomain.com

6. Just follow the prompts

7. Edit domain.vhost accordingly. The vhost is updated with the latest security features for SSL if using a cert you must uncomment and make sure paths are correct. The script sets up the standard path $HOME/$USER/ssl to cert/key/trusted_chain.pem but of course you must supply the files. root/logs/php-fpm. etc are setup for you and can be edited accordingly.

## License

Apache License 2.0

## Development

Nothing further is planned as I and most have moved on to PHP 7 but any serious functionality issues or security issues will be addressed if discovered by me or reported by users.

## PHP7 User?

Use the PHP7 Ubuntu 16x version [nginxubuntu-php7](https://github.com/GaryCornell/nginxubuntu-php7)
