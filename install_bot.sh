#!/bin/bash

# LORNA Installer - YAD Version
# Compatible with Ubuntu 20.04 / 22.04

# Function to display the main menu
show_main_menu() {
  yad --width=400 --height=300 --center --image="logo.png" --title="LORNA Installer" \
    --text="<b>Welcome to the LORNA Installer</b>\nPlease choose an option:" \
    --button="Install LORNA Stack":1 \
    --button="Uninstall Everything":2 \
    --button="Exit":3
}

# Function to install LORNA stack
install_lorna() {
  espeak "Installation started"
  yad --info --text="Starting system update..."
  sudo apt update && sudo apt upgrade -y

  yad --info --text="Installing required packages..."
  sudo apt install -y curl socat phpmyadmin php8.1-fpm mysql-server certbot python3-certbot-nginx

  # Get MySQL root password and domain
  credentials=$(yad --form --title="LORNA Configuration" \
    --field="MySQL Root Password":H \
    --field="Your Domain (e.g., example.com)")

  MYSQL_PASS=$(echo "$credentials" | cut -d '|' -f1)
  DOMAIN=$(echo "$credentials" | cut -d '|' -f2)

  # Configure Nginx
  yad --info --text="Creating Nginx configuration for $DOMAIN..."
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

  # Obtain SSL certificate
  yad --info --text="Requesting SSL certificate..."
  sudo certbot --nginx -d $DOMAIN

  # Setup phpMyAdmin
  sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

  yad --info --title="Installation Complete" \
    --text="Access phpMyAdmin at: https://$DOMAIN/phpmyadmin"
  espeak "Installation completed successfully"
}

# Function to uninstall LORNA stack
uninstall_lorna() {
  espeak "Starting uninstallation"
  yad --warning --text="Uninstalling everything. This will remove phpMyAdmin, MySQL, PHP, Nginx..."

  sudo rm -rf /usr/share/phpmyadmin /var/www/html/phpmyadmin
  sudo apt purge -y phpmyadmin mysql-server nginx php* certbot
  sudo apt autoremove -y

  yad --info --text="Uninstallation complete"
  espeak "Uninstallation complete"
}

# Main script execution
while true; do
  choice=$(show_main_menu)
  case $? in
    1) install_lorna ;;
    2) uninstall_lorna ;;
    3) espeak "Goodbye"; exit 0 ;;
    *) espeak "Goodbye"; exit 0 ;;
  esac
done
