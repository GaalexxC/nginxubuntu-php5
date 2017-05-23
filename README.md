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

<h1>Optional</h1>
- Runs a apt-get update/upgrade if applicable
- Optional install latest mainline Nginx (recommended)
- Optional update to latest Linux Kernel (recommended)
- Optional PHP5 install w/dependencies
- Optional php.ini secured (recommended)
- Optional Generates 2048 Diffie-Hellman for TLS (recommended)(OpenSSL required)

<h1>Functions</h1>
- Setup/Create Nginx directory structure, sites available/enabled/domain.vhost conf
- Updates cgi.fix_pathinfo=0 in fpm and cli php.ini
- Setup/Create php-fpm directory structure, domain.conf
- Setup/Create user/pass with domain/IP and public_html directory structure

- Sets all proper permissions on relevant directories.

- Creates the following $HOME directory structure





