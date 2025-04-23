#!/bin/bash

# نصب figlet برای بنر
sudo apt install figlet -y > /dev/null 2>&1

# نمایش بنر برند LORNA
clear
figlet "LORNA"
echo "این اسکریپت توسط تیم LORNA ساخته شده"
echo "======================================"
echo

# نمایش منو
echo "1) نصب"
echo "2) حذف نصب"
echo "3) خروج"
echo

read -p "یک گزینه را انتخاب کنید [1-3]: " USER_CHOICE

case $USER_CHOICE in
    1)
        echo "شروع نصب..."
        # بروزرسانی سیستم
        echo "Updating and upgrading system..."
        sudo apt update && sudo apt upgrade -y

        # نصب curl و socat
        echo "Installing curl and socat..."
        sudo apt install curl socat -y

        # نصب Certbot و پیکربندی SSL
        echo "Installing Certbot for SSL..."
        sudo apt install certbot python3-certbot-nginx -y

        # نصب MySQL و پیکربندی آن
        echo "Installing MySQL..."
        sudo apt install mysql-server -y
        echo "Running MySQL secure installation..."
        sudo mysql_secure_installation

        # گرفتن یوزرنیم و پسورد MySQL از کاربر
        read -p "Enter MySQL root username (default: root): " MYSQL_ROOT_USER
        MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
        read -s -p "Enter MySQL root password: " MYSQL_ROOT_PASS
        echo

        # تست اتصال به MySQL
        echo "Testing MySQL login..."
        mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" -e "SELECT VERSION();" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "MySQL login failed. Please check your username or password."
            exit 1
        else
            echo "MySQL login successful."
        fi

        # تنظیم پسورد برای phpMyAdmin
        echo "Setting phpMyAdmin MySQL root password..."
        sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
        sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS"
        sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_ROOT_PASS"

        # نصب phpMyAdmin و PHP
        echo "Installing phpMyAdmin and required PHP extensions..."
        sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
        echo "Installing PHP 8.1-FPM..."
        sudo apt install php8.1-fpm -y
        sudo systemctl start php8.1-fpm
        sudo systemctl enable php8.1-fpm

        # دریافت دامنه از کاربر
        read -p "Enter your domain (e.g. example.com): " DOMAIN_NAME

        # ساخت فایل کانفیگ Nginx برای دامنه
        echo "Creating Nginx config for $DOMAIN_NAME..."
        sudo bash -c "cat > /etc/nginx/sites-available/$DOMAIN_NAME" <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;

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

        # فعال‌سازی دامنه در Nginx
        sudo ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        sudo nginx -t && sudo systemctl reload nginx

        # نصب SSL برای دامنه
        echo "Setting up SSL using Certbot..."
        sudo certbot --nginx -d $DOMAIN_NAME

        # ایجاد symlink و دسترسی برای phpMyAdmin
        echo "Creating symlink for phpMyAdmin..."
        sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
        sudo chmod -R 755 /usr/share/phpmyadmin
        sudo chown -R www-data:www-data /usr/share/phpmyadmin

        echo "Setup complete. Visit https://$DOMAIN_NAME/phpmyadmin to access phpMyAdmin."
        ;;
    2)
        echo "شروع حذف نصب..."

        # حذف phpMyAdmin
        sudo rm -rf /usr/share/phpmyadmin
        sudo rm -f /var/www/html/phpmyadmin
        sudo apt remove --purge phpmyadmin -y

        # حذف MySQL
        sudo systemctl stop mysql
        sudo apt remove --purge mysql-server mysql-client mysql-common -y
        sudo rm -rf /etc/mysql /var/lib/mysql
        sudo apt autoremove -y

        # حذف nginx
        sudo systemctl stop nginx
        sudo apt remove --purge nginx nginx-common -y
        sudo rm -rf /etc/nginx /var/www/html
        sudo apt autoremove -y

        # حذف PHP
        sudo apt remove --purge php* -y
        sudo apt autoremove -y

        # حذف certbot
        sudo apt remove --purge certbot -y

        echo "حذف نصب کامل شد."
        ;;
    3)
        echo "خروج از اسکریپت."
        exit 0
        ;;
    *)
        echo "گزینه نامعتبر بود!"
        exit 1
        ;;
esac
