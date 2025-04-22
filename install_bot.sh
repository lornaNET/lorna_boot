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

# نصب phpMyAdmin و پیکربندی آن
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

# تنظیم Webhook ربات تلگرام
echo "Setting Telegram bot webhook..."
curl -F "url=https://bot.mazholl.mehdilorna.shop/lornapanel/index.php" https://api.telegram.org/botYOUR_BOT_TOKEN/setWebhook

# نصب تونل (اختیاری)
echo "Setting up Tunnel (if applicable)..."
wget https://raw.githubusercontent.com/lornaNET/lorna_tunell/main/setup-tunnel.sh
chmod +x setup-tunnel.sh
sudo ./setup-tunnel.sh

# راه‌اندازی Nginx و بررسی وضعیت آن
echo "Restarting Nginx and checking status..."
sudo systemctl restart nginx
sudo systemctl status nginx

# بررسی دسترسی به فایل‌ها و لاگ‌ها
echo "Checking access to phpMyAdmin and Nginx logs..."
sudo tail -f /var/log/nginx/error.log
sudo ls /var/www/html/phpmyadmin/index.php

# پاک‌سازی فایل‌های اضافی Nginx (در صورت نیاز)
echo "Cleaning up old Nginx configurations..."
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /etc/nginx/sites-available/default

# حذف Nginx و نصب دوباره (در صورت نیاز)
echo "Purging old Nginx and installing again (if required)..."
sudo apt-get purge nginx nginx-common nginx-full nginx-core nginx-common -y
sudo apt-get autoremove --purge -y
sudo rm -rf /etc/nginx
sudo rm -rf /var/www/html
sudo rm -rf /var/log/nginx

# نصب مجدد Nginx
echo "Reinstalling Nginx..."
sudo apt install nginx -y
