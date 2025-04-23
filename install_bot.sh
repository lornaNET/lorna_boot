#!/bin/bash

# LORNA Installer Script for Ubuntu 20.04 / 22.04
# Author: Team LORNA
# GitHub: https://github.com/YOUR_GITHUB (change this!)

# === CHECK DEPENDENCIES ===
sudo apt update > /dev/null 2>&1

for pkg in figlet toilet whiptail espeak; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        echo "Installing $pkg..."
        sudo apt install "$pkg" -y
    fi
done

# === COLORS ===
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)
BOLD=$(tput bold)

# === ASCII LOGO ===
clear
toilet -f big -F metal "LORNA"
echo "${CYAN}${BOLD}Welcome to the LORNA Server Stack Installer!${RESET}"
echo

# === MENU ===
CHOICE=$(whiptail --title "LORNA Installer" --menu "Choose an action:" 15 60 4 \
"1" "Install LORNA stack" \
"2" "Uninstall everything" \
"3" "Exit" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus -ne 0 ]; then
    echo "${YELLOW}Cancelled by user.${RESET}"
    exit 0
fi

case $CHOICE in
"1")
    espeak "Installation started. Please wait."

    echo "${CYAN}Updating system packages...${RESET}"
    sudo apt update && sudo apt upgrade -y

    echo "${CYAN}Installing core packages...${RESET}"
    sudo apt install curl socat -y

    echo "${CYAN}Installing Certbot for SSL...${RESET}"
    sudo apt install certbot python3-certbot-nginx -y

    echo "${CYAN}Installing MySQL server...${RESET}"
    sudo apt install mysql-server -y
    sudo mysql_secure_installation

    read -p "${BOLD}Enter MySQL root username (default: root): ${RESET}" MYSQL_USER
    MYSQL_USER=${MYSQL_USER:-root}
    read -s -p "${BOLD}Enter MySQL root password: ${RESET}" MYSQL_PASS
    echo

    echo "${CYAN}Verifying MySQL credentials...${RESET}"
    mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SELECT VERSION();" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        espeak "MySQL login failed."
        echo "${RED}MySQL login failed! Please check your credentials.${RESET}"
        exit 1
    fi
    echo "${GREEN}MySQL login successful.${RESET}"

    echo "${CYAN}Configuring phpMyAdmin...${RESET}"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_PASS"
    sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_PASS"

    sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
    sudo apt install php8.1-fpm -y
    sudo systemctl start php8.1-fpm
    sudo systemctl enable php8.1-fpm

    read -p "${BOLD}Enter your domain name (e.g. example.com): ${RESET}" DOMAIN

    echo "${CYAN}Creating Nginx config...${RESET}"
    sudo bash -c "cat > /etc/nginx/sites-available/$DOMAIN" <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default

    if sudo nginx -t; then
        sudo systemctl reload nginx
    else
        echo "${RED}Nginx configuration failed.${RESET}"
        exit 1
    fi

    echo "${CYAN}Requesting SSL from Let's Encrypt...${RESET}"
    sudo certbot --nginx -d "$DOMAIN"

    echo "${CYAN}Setting up phpMyAdmin access...${RESET}"
    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
    sudo chmod -R 755 /usr/share/phpmyadmin
    sudo chown -R www-data:www-data /usr/share/phpmyadmin

    echo
    echo "${GREEN}${BOLD}Installation complete!${RESET}"
    echo "${CYAN}Access phpMyAdmin at: https://$DOMAIN/phpmyadmin${RESET}"
    espeak "Installation completed successfully"
    ;;
"2")
    espeak "Uninstallation started."

    echo "${RED}Uninstalling LORNA stack...${RESET}"
    sudo rm -rf /usr/share/phpmyadmin /var/www/html/phpmyadmin
    sudo apt remove --purge phpmyadmin -y

    sudo systemctl stop mysql
    sudo apt remove --purge mysql-server mysql-client mysql-common -y
    sudo rm -rf /etc/mysql /var/lib/mysql
    sudo apt autoremove -y

    sudo systemctl stop nginx
    sudo apt remove --purge nginx nginx-common -y
    sudo rm -rf /etc/nginx /var/www/html
    sudo apt autoremove -y

    sudo apt remove --purge php* -y
    sudo apt autoremove -y

    sudo apt remove --purge certbot -y

    echo "${GREEN}Uninstallation complete.${RESET}"
    espeak "Uninstallation complete."
    ;;
"3")
    echo "${YELLOW}Goodbye!${RESET}"
    espeak "Exiting now."
    exit 0
    ;;
*)
    echo "${RED}Invalid choice.${RESET}"
    ;;
esac
