#!/bin/bash

# Zenity + GUI Bash Installer - LORNA
# Ubuntu 20.04 / 22.04 Compatible
# This script will install and configure LORNA stack with Nginx, PHP, MySQL, and Certbot SSL.

# نصب ابزارها
sudo apt update > /dev/null
for pkg in zenity espeak curl socat phpmyadmin php8.1-fpm mysql-server certbot python3-certbot-nginx; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        sudo apt install "$pkg" -y
    fi
done

# نمایش لوگو
zenity --info --title="LORNA Installer" --width=300 --height=100 \
--text="<big><b>LORNA</b></big>\nWelcome to the professional installer." --no-wrap

# انتخاب منو
CHOICE=$(zenity --list --title="LORNA Installer Menu" \
--column="Option" --column="Action" \
1 "Install LORNA Stack" \
2 "Uninstall Everything" \
3 "Exit")

case $CHOICE in
"1")
    espeak "Installation started"

    zenity --info --text="Starting system update..."
    sudo apt update && sudo apt upgrade -y

    zenity --info --text="Installing required packages..."
    sudo apt install curl socat phpmyadmin php8.1-fpm mysql-server certbot python3-certbot-nginx -y

    MYSQL_PASS=$(zenity --entry --title="MySQL Password" --text="Enter MySQL root password" --hide-text)
    DOMAIN=$(zenity --entry --title="Domain" --text="Enter your domain (e.g. example.com)")

    zenity --info --text="Creating Nginx config for $DOMAIN..."
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
    sudo nginx -t && sudo systemctl reload nginx

    zenity --info --text="Requesting SSL certificate..."
    sudo certbot --nginx -d $DOMAIN

    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

    zenity --info --title="Installation Complete" \
    --text="Access phpMyAdmin at: https://$DOMAIN/phpmyadmin"
    espeak "Installation completed successfully"
    ;;

"2")
    espeak "Starting uninstallation"
    zenity --warning --text="Uninstalling everything. This will remove phpMyAdmin, MySQL, PHP, Nginx..."

    sudo rm -rf /usr/share/phpmyadmin /var/www/html/phpmyadmin
    sudo apt purge phpmyadmin mysql-server nginx php* certbot -y
    sudo apt autoremove -y

    zenity --info --text="Uninstallation complete"
    espeak "Uninstallation complete"
    ;;

"3")
    espeak "Goodbye"
    zenity --info --text="Thanks for using LORNA installer!"
    exit 0
    ;;
esac
