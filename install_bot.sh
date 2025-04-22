#!/bin/bash

# بروزرسانی سیستم
echo "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

# نصب curl و socat
echo "Installing curl and socat..."
sudo apt install curl socat -y

# نصب Certbot و پیکربندی SSL
echo "Installing Certbot for SSL..."
sudo apt install certbot python3-certbot-nginx -y
echo "Setting up SSL using Certbot..."
sudo certbot --nginx

# نصب MySQL و پیکربندی آن
echo "Installing MySQL..."
sudo apt install mysql-server -y
echo "Running MySQL secure installation..."
sudo mysql_secure_installation

# درخواست پسورد MySQL برای root
MYSQL_ROOT_PASS="your_root_password" # تنظیم پسورد ریشه MySQL
echo "Configuring phpMyAdmin to use MySQL root password..."
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_ROOT_PASS"

# نصب phpMyAdmin و required PHP extensions
echo "Installing phpMyAdmin and required PHP extensions..."
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

# نصب PHP 8.1-FPM
echo "Installing PHP 8.1-FPM..."
sudo apt install php8.1-fpm -y
echo "Starting PHP 8.1-FPM..."
sudo systemctl start php8.1-fpm
sudo systemctl enable php8.1-fpm

# پیکربندی Nginx
echo "Configuring Nginx..."
# اگر فایل پیکربندی جدیدی نیاز است، آن را ایجاد کنید
# اینجا می‌توانید تغییرات Nginx را اعمال کنید یا فایل پیکربندی را تغییر دهید
sudo nano /etc/nginx/sites-available/default

# تست پیکربندی Nginx و بارگذاری مجدد آن
echo "Testing Nginx configuration and reloading..."
sudo nginx -t
sudo systemctl reload nginx

# ایجاد لینک سمبلیک برای phpMyAdmin در /var/www/html
echo "Creating symlink for phpMyAdmin..."
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# تنظیمات دسترسی‌ها برای phpMyAdmin
echo "Setting permissions for phpMyAdmin..."
sudo chmod -R 755 /usr/share/phpmyadmin
sudo chown -R www-data:www-data /usr/share/phpmyadmin

# راه‌اندازی Nginx و بررسی وضعیت آن
echo "Restarting Nginx and checking status..."
sudo systemctl restart nginx
sudo systemctl status nginx

# بررسی دسترسی به فایل‌ها و لاگ‌ها
echo "Checking access to phpMyAdmin and Nginx logs..."
sudo tail -f /var/log/nginx/error.log
sudo ls /var/www/html/phpmyadmin/index.php
