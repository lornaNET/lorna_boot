# LORNA Server Setup Script

**نسخه حرفه‌ای اسکریپت نصب و حذف سرور لینوکس با پشتیبانی از:**
- Nginx + PHP 8.1 + MySQL + phpMyAdmin
- نصب گواهینامه SSL رایگان با Certbot
- پشتیبانی از دامنه دلخواه کاربر
- ساخته شده توسط تیم **LORNA**

---
##پیش‌نمایش محیط اسکریپت

==============================
        LORNA INSTALLER       
==============================

1) Install Certbot & Configure Nginx + SSL
2) Install Nginx and configure domain
3) Install MySQL
4) Install phpMyAdmin
5) Exit
6) Uninstall everything
## نحوه استفاده

bash <(curl -s https://raw.githubusercontent.com/lornaNET/lorna_boot/main/install_bot.sh)


# LORNA Installer Script

**LORNA** یک اسکریپت هوشمند و خودکار برای نصب، پیکربندی و حذف سرویس‌های پرکاربرد وب مثل Nginx، Certbot، MySQL و phpMyAdmin است — مخصوص لینوکس (Debian/Ubuntu-based).

---

## ویژگی‌ها

- **نصب Nginx و پیکربندی کامل روی دامین دلخواه**
- **دریافت گواهینامه SSL از Let’s Encrypt با Certbot**
- **پشتیبانی از ساب‌دامین‌ها + قابلیت ادیت کانفیگ Nginx با nano**
- **نصب MySQL با تنظیمات امنیتی**
- **نصب phpMyAdmin و اتصال به Nginx در مسیر `/phpmyadmin`**
- **حذف کامل تمام سرویس‌ها با یک دکمه (Uninstall)**
- **محیط منویی ساده، گرافیکی و قابل فهم**

---

## پیش‌نیازها

- سیستم عامل **Ubuntu / Debian**
- دسترسی به **sudo/root**
- دامنه متصل به سرور (برای SSL)

---

## نحوه استفاده

1. ابتدا اسکریپت را کلون یا دانلود کنید:

```bash
git clone https://github.com/your-user/lorna-installer.git
cd lorna-installer
chmod +x lorna.sh
./lorna.sh
