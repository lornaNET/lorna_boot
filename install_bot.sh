#!/bin/bash

# LORNA Installer - YAD GUI Version
# Compatible with Ubuntu 20.04 and 22.04
# Author: github.com/yourusername

# Dependencies check and install
sudo apt update > /dev/null
for pkg in yad curl socat phpmyadmin php8.1-fpm mysql-server certbot python3-certbot-nginx; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        sudo apt install "$pkg" -y
    fi
done

# Show main menu using YAD
show_main_menu() {
  yad --width=400 --height=300 --center \
      --title="LORNA Installer" \
      --image="logo.png" --image-on-top \
      --text="<b>Welcome to the LORNA Installer</b>\nSelect an option below:" \
      --button="Install LORNA Stack":1 \
      --button="Uninstall Everything":2 \
      --button="Exit":3
}

# Install function
install_lorna() {
  yad --info --title="System Update" --text="Updating and upgrading system..."
  sudo apt update && sudo apt upgrade -y

  # Form for credentials
  form_data=$(yad --form --title="LORNA Config" \
    --field="MySQL Root Password":H \
    --field="Your Domain (e.g. example.com):")

  MYSQL_PASS=$(echo "$form_data" | cut -d '|' -f1)
  DOMAIN=$(echo "$form_data" | cut -d '|' -f2)

  # Nginx config
  yad --info --text="Creating Nginx configuration..."
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

  # Certbot SSL
  yad --info --title="SSL Certificate" --text="Generating SSL certificate with Certbot..."
  sudo certbot --nginx -d $DOMAIN

  # phpMyAdmin symlink
  sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

  yad --info --title="Installation Complete" \
      --text="Installation completed!\nVisit: https://$DOMAIN/phpmyadmin"
}

# Uninstall function
uninstall_lorna() {
  confirm=$(yad --question --title="Uninstall LORNA" \
    --text="This will remove phpMyAdmin, MySQL, PHP, and Nginx.\nAre you sure?" \
    --button=Yes:0 --button=No:1)

  if [ $? -eq 0 ]; then
    sudo rm -rf /usr/share/phpmyadmin /var/www/html/phpmyadmin
    sudo apt purge -y phpmyadmin mysql-server nginx php* certbot
    sudo apt autoremove -y
    yad --info --text="Uninstallation completed successfully."
  fi
}

# Main loop
while true; do
  choice=$(show_main_menu)
  case $? in
    1) install_lorna ;;
    2) uninstall_lorna ;;
    3) yad --info --text="Goodbye!"; exit 0 ;;
    *) exit 1 ;;
  esac
done
