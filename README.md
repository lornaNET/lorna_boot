# LORNA Installer Script

اسکریپت **LORNA** یک ابزار خودکار و هوشمند است برای نصب، پیکربندی و مدیریت سرویس‌های پرکاربرد سرور لینوکسی مثل Nginx، MySQL، phpMyAdmin و SSL (Let’s Encrypt) — همه در یک محیط ساده و منویی.

---

## محیط کاربری⚪️

پس از اجرای اسکریپت، منویی گرافیکی و ساده به شما نمایش داده می‌شود:

==============================
LORNA INSTALLER
	1.	Install Certbot & Configure Nginx + SSL
	2.	Install Nginx and configure domain
	3.	Install MySQL
	4.	Install phpMyAdmin
	5.	Exit
	6.	Uninstall everything

 ---

## کاربردها و امکانات🔴

- **نصب کامل Nginx** با امکان وارد کردن دامین و ویرایش کانفیگ (`nano`)
- **صدور خودکار SSL با Certbot** برای دامین وارد شده (پشتیبانی از ساب‌دامین)
- **اتصال خودکار phpMyAdmin به سرور و نمایش در مسیر `/phpmyadmin`**
- **نصب MySQL** با اجرای تنظیمات امنیتی (`mysql_secure_installation`)
- **قابلیت حذف کامل همه سرویس‌ها و فایل‌های مرتبط با یک دکمه (Uninstall)**
- مناسب برای **سرورهای لینوکسی مبتنی بر Debian/Ubuntu**
- محیطی ساده برای توسعه‌دهندگان، مدیران سرور، و تازه‌کارها

---

## پیش‌نیازها

- **Ubuntu / Debian**
- دسترسی به **root یا sudo**
- دامین متصل به آی‌پی سرور (برای SSL)
- پورت‌های 80 و 443 باز باشند

---

## نحوه اجرا

1. ابتدا اسکریپت را کلون یا دانلود کنید:

```bash
git clone https://github.com/your-username/lorna-installer.git
cd lorna-installer
chmod +x lorna.sh
./lorna.sh

2.	از منو، گزینه دلخواه را انتخاب کنید (نصب، پیکربندی یا حذف سرویس‌ها)

⸻

نصب SSL🟡

در صورت انتخاب گزینه اول:
	•	اسکریپت به صورت خودکار curl, socat, certbot, و python3-certbot-nginx را نصب می‌کند
	•	سپس از شما دامین می‌پرسد
	•	و بعد گواهی SSL را از Let’s Encrypt برای Nginx دریافت و نصب می‌کند

⸻

مسیر phpMyAdmin🔵

پس از نصب phpMyAdmin از طریق اسکریپت، می‌توانید با استفاده از آدرس زیر به آن دسترسی داشته باشید:
http://your-domain/phpmyadmin

(در صورتی که SSL نصب شده باشد، آدرس به صورت https://your-domain/phpmyadmin خواهد بود)

⸻

حذف کامل (Uninstall)🟣

گزینه شماره 6 در منو، همه‌ی موارد زیر را پاک می‌کند:
	•	Certbot
	•	Nginx و پیکربندی‌ها
	•	phpMyAdmin و وابستگی‌ها
	•	MySQL
	•	فولدرهای sites-available, sites-enabled, و /var/www/html
	•	پاک‌سازی کامل با autoremove

⸻

توسعه‌دهنده🟢

این اسکریپت توسط تیم LORNA توسعه داده شده است با هدف آسان‌سازی و تسریع نصب سرویس‌های سرور.

Developed with love by LORNA Team

⸻

پیشنهادات یا مشارکت

اگر ایده‌ای برای بهبود دارید یا مشکلی پیدا کردید، لطفاً:
	•	یک Issue در گیت‌هاب ایجاد کنید
	•	یا Pull Request بفرستید

ما از مشارکت شما استقبال می‌کنیم!

🔻
bash <(curl -s https://raw.githubusercontent.com/lornaNET/lorna_boot/main/install_bot.sh)
