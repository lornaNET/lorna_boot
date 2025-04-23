#!/bin/bash

# LORNA Installer - whiptail version (terminal GUI)
# Ubuntu 20.04 / 22.04 Compatible
# Clean, stable, no desktop dependencies
# Author: github.com/yourusername

# Dependencies
sudo apt update
for pkg in whiptail curl socat phpmyadmin php8.1-fpm mysql-server certbot python3-certbot-nginx; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        sudo apt install "$pkg" -y
    fi
done

# Main Menu
CHOICE=$(whiptail --title "LORNA Installer" --menu "Choose an option:" 15 60 4 \
"1" "Install LORNA Stack" \
"2" "Uninstall Everything" \
"3" "Exit" 3>&1 1>&2 2>&3)

case $CHOICE in
"1")
    whiptail --title "System Update" --msgbox "Updating system..." 8 40
    sudo apt update && sudo apt upgrade -y

    MYSQL_PASS=$(whiptail --title "MySQL Password" --passwordbox "Enter MySQL root password:" 10 60 3>&1 1>&2 2>&3)
    DOMAIN=$(whiptail --title "Domain" --inputbox "Enter your domain (e.g. example.com):" 10 60 3>&1 1>&2 2>&3)

    whiptail --title "Nginx" --msgbox "Creating Nginx config for $DOMAIN..." 8 60
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

    sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx

    whiptail --title "SSL Certificate" --msgbox "Requesting SSL for $DOMAIN..." 8 60
    sudo certbot --nginx -d $DOMAIN

    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

    whiptail --title "Done" --msgbox "Access phpMyAdmin at:\nhttps://$DOMAIN/phpmyadmin" 10 60
    ;;

"2")
    if whiptail --title "Uninstall" --yesno "Remove phpMyAdmin, MySQL, PHP, Nginx and Certbot?" 10 60; then
        sudo rm -rf /usr/share/phpmyadmin /var/www/html/phpmyadmin
        sudo apt purge -y phpmyadmin mysql-server nginx php* certbot
        sudo apt autoremove -y
        whiptail --msgbox "Uninstallation complete." 8 40
    fi
    ;;

"3")
    whiptail --msgbox "Thanks for using LORNA Installer!" 8 40
    exit 0
    ;;
esac
