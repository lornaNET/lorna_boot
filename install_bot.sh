#!/bin/bash

# Fancy LORNA Installer with Dialog and Colors
# Terminal-based but styled

# Install dialog if missing
if ! command -v dialog &> /dev/null; then
    echo "Installing 'dialog'..."
    sudo apt install dialog -y
fi

# Colors enabled
export DIALOGRC=~/.dialogrc_lorna

# Custom theme config
cat > "$DIALOGRC" <<EOF
use_shadow = yes
use_colors = yes
screen_color = (WHITE,BLUE,ON)
shadow_color = (BLACK,BLACK,OFF)
title_color = (YELLOW,BLUE,ON)
border_color = (WHITE,BLUE,ON)
button_active_color = (BLACK,YELLOW,ON)
button_inactive_color = (WHITE,BLUE,ON)
form_active_text_color = (WHITE,BLUE,ON)
form_text_color = (WHITE,BLUE,ON)
EOF

# Menu
HEIGHT=15
WIDTH=60
CHOICE=$(dialog --colors --clear \
        --backtitle "\Zb\Z4LORNA Stack Installer - Terminal Edition\Zn" \
        --title "\Z1LORNA INSTALLER\Zn" \
        --menu "\n\Z2Select an option:\Zn" \
        $HEIGHT $WIDTH 5 \
        1 "Install \Zb\Z3LORNA Stack\Zn" \
        2 "Uninstall \Zb\Z1Everything\Zn" \
        3 "Exit" \
        3>&1 1>&2 2>&3)

clear

case $CHOICE in
"1")
    dialog --colors --infobox "\n\Z3Updating system..." 6 50
    sudo apt update && sudo apt upgrade -y

    dialog --infobox "Installing packages..." 5 40
    sudo apt install -y curl socat phpmyadmin php8.1-fpm mysql-server certbot python3-certbot-nginx nginx

    MYSQL_PASS=$(dialog --insecure --passwordbox "Enter MySQL root password:" 10 60 3>&1 1>&2 2>&3)
    DOMAIN=$(dialog --inputbox "Enter your domain (e.g. example.com):" 10 60 3>&1 1>&2 2>&3)

    dialog --infobox "Configuring Nginx for $DOMAIN..." 5 40
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

    dialog --infobox "Requesting SSL certificate..." 5 40
    sudo certbot --nginx -d $DOMAIN

    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

    dialog --colors --msgbox "\n\Z1Installation complete!\Zn\n\n\Z2Access:\Zn https://$DOMAIN/phpmyadmin" 10 60
    ;;

"2")
    dialog --yesno "This will remove everything (phpMyAdmin, MySQL, PHP, Nginx, etc). Continue?" 10 60
    if [ $? -eq 0 ]; then
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
