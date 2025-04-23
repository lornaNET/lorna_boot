#!/bin/bash

# LORNA Installer - dialog version
# Fully terminal-based GUI installer for Ubuntu 20.04/22.04
# By github.com/yourusername

# Check for dialog
if ! command -v dialog &> /dev/null; then
    echo "Installing 'dialog'..."
    sudo apt install dialog -y
fi

# Main menu
HEIGHT=15
WIDTH=60
CHOICE=$(dialog --clear \
                --backtitle "LORNA Installer" \
                --title "Main Menu" \
                --menu "Choose an option:" \
                $HEIGHT $WIDTH 4 \
                1 "Install LORNA Stack" \
                2 "Uninstall Everything" \
                3 "Exit" \
                3>&1 1>&2 2>&3)

clear

case $CHOICE in
"1")
    dialog --infobox "Updating system..." 5 40
    sudo apt update && sudo apt upgrade -y

    dialog --infobox "Installing packages..." 5 40
    sudo apt install -y curl socat phpmyadmin php8.1-fpm mysql-server certbot python3-certbot-nginx nginx

    MYSQL_PASS=$(dialog --title "MySQL Root Password" --insecure --passwordbox "Enter MySQL root password:" 10 60 3>&1 1>&2 2>&3)
    DOMAIN=$(dialog --title "Your Domain" --inputbox "Enter your domain (e.g. example.com):" 10 60 3>&1 1>&2 2>&3)

    dialog --infobox "Configuring Nginx..." 5 40
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

    dialog --infobox "Requesting SSL Certificate..." 5 40
    sudo certbot --nginx -d $DOMAIN

    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

    dialog --msgbox "Installation complete!\nAccess phpMyAdmin at: https://$DOMAIN/phpmyadmin" 10 60
    ;;

"2")
    dialog --yesno "This will remove LORNA stack (phpMyAdmin, MySQL, PHP, Nginx, etc). Continue?" 10 60
    response=$?
    if [ $response -eq 0 ]; then
        sudo rm -rf /usr/share/phpmyadmin /var/www/html/phpmyadmin
        sudo apt purge -y phpmyadmin mysql-server nginx php* certbot
        sudo apt autoremove -y
        dialog --msgbox "Uninstallation complete." 8 40
    fi
    ;;

"3")
    dialog --msgbox "Thanks for using LORNA Installer!" 8 40
    exit 0
    ;;
esac
