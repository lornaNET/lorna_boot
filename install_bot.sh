#!/bin/bash

# Install figlet for banner
sudo apt install figlet -y > /dev/null 2>&1

# Display LORNA Banner
clear
figlet "LORNA"
echo "This script is developed by LORNA team"
echo "======================================"
echo

# Function to install a package
install_package() {
    PACKAGE_NAME=$1
    echo "Installing $PACKAGE_NAME..."
    sudo apt install $PACKAGE_NAME -y
    echo "$PACKAGE_NAME installation complete!"
}

# Function to configure Nginx
configure_nginx() {
    DOMAIN=$1
    echo "Creating Nginx config for $DOMAIN..."
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

    # Enable the Nginx configuration
    sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo nginx -t && sudo systemctl reload nginx
    echo "Nginx configuration for $DOMAIN complete!"
}

# Function to install and configure SSL with Certbot
setup_ssl() {
    DOMAIN=$1
    echo "Setting up SSL for $DOMAIN using Certbot..."
    sudo certbot --nginx -d $DOMAIN
    echo "SSL setup complete!"
}

# Function to install phpMyAdmin
install_phpmyadmin() {
    echo "Installing phpMyAdmin..."
    sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
    sudo systemctl restart apache2
    echo "phpMyAdmin installation complete!"
}

# Function to install MySQL
install_mysql() {
    echo "Installing MySQL..."
    sudo apt install mysql-server -y
    sudo mysql_secure_installation
    echo "MySQL installation complete!"
}

# Function to ask for MySQL credentials
ask_mysql_credentials() {
    read -p "Enter MySQL root username (default: root): " MYSQL_ROOT_USER
    MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
    read -s -p "Enter MySQL root password: " MYSQL_ROOT_PASS
    echo
}

# Main menu
draw_menu() {
    clear
    echo -e "${BLUE}${BOLD}==============================${RESET}"
    echo -e "${YELLOW}${BOLD}        LORNA INSTALLER       ${RESET}"
    echo -e "${BLUE}${BOLD}==============================${RESET}"
    echo ""
    echo "1) Install Certbot"
    echo "2) Install Nginx"
    echo "3) Install MySQL"
    echo "4) Install phpMyAdmin"
    echo "5) Exit"
    echo ""
}

# Draw the menu and ask user for choice
while true; do
    draw_menu
    read -p "Choose an option [1-5]: " USER_CHOICE

    case "$USER_CHOICE" in
        1)
            echo "Starting Certbot installation..."
            install_package certbot
            ;;
        2)
            echo "Starting Nginx installation..."
            install_package nginx
            # Ask for domain and configure Nginx
            read -p "Enter your domain (e.g. example.com): " DOMAIN_NAME
            configure_nginx $DOMAIN_NAME
            ;;
        3)
            echo "Starting MySQL installation..."
            install_package mysql-server
            ask_mysql_credentials
            ;;
        4)
            echo "Starting phpMyAdmin installation..."
            install_phpmyadmin
            ;;
        5)
            echo "Exiting script..."
            exit 0
            ;;
        *)
            echo "Invalid option! Please choose a valid option."
            ;;
    esac
done
