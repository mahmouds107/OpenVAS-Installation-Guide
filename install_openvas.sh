#!/bin/bash

#######################################################
# OpenVAS Automated Installation Script
# Author: AbdulRhman AbdulGhaffar
# Description: سكريبت تثبيت OpenVAS بشكل تلقائي على Kali Linux
#######################################################

# ألوان للرسائل
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # بدون لون

# دالة لطباعة رسائل ملونة
print_message() {
    echo -e "${2}${1}${NC}"
}

# دالة للتحقق من نجاح الأمر
check_status() {
    if [ $? -eq 0 ]; then
        print_message "✓ $1 نجح" "$GREEN"
    else
        print_message "✗ $1 فشل" "$RED"
        exit 1
    fi
}

# التحقق من صلاحيات الروت
if [ "$EUID" -ne 0 ]; then 
    print_message "يرجى تشغيل السكريبت بصلاحيات root (استخدم sudo)" "$RED"
    exit 1
fi

clear
print_message "╔════════════════════════════════════════════════╗" "$BLUE"
print_message "║   سكريبت تثبيت OpenVAS التلقائي              ║" "$BLUE"
print_message "║   Automated OpenVAS Installation Script       ║" "$BLUE"
print_message "╚════════════════════════════════════════════════╝" "$BLUE"
echo ""

# 1. تحديث النظام
print_message "[1/7] تحديث النظام..." "$YELLOW"
apt update -qq
check_status "تحديث قائمة الحزم"

apt full-upgrade -y -qq
check_status "تحديث النظام"

# 2. تثبيت الحزم الأساسية
print_message "[2/7] تثبيت الحزم الأساسية..." "$YELLOW"
apt install -y postgresql postgresql-contrib redis-server -qq
check_status "تثبيت PostgreSQL و Redis"

# 3. تشغيل الخدمات الأساسية
print_message "[3/7] تشغيل الخدمات الأساسية..." "$YELLOW"
systemctl start postgresql
systemctl enable postgresql
systemctl start redis-server
systemctl enable redis-server
check_status "تشغيل PostgreSQL و Redis"

# 4. تثبيت GVM
print_message "[4/7] تثبيت GVM (قد يستغرق وقتاً)..." "$YELLOW"
apt install -y gvm -qq
check_status "تثبيت GVM"

# 5. إعداد GVM
print_message "[5/7] إعداد GVM (قد يستغرق 15-45 دقيقة)..." "$YELLOW"
gvm-setup > /tmp/gvm-setup.log 2>&1
check_status "إعداد GVM"

# استخراج كلمة المرور
PASSWORD=$(grep -oP 'password.*\K[a-f0-9-]{36}' /tmp/gvm-setup.log | head -1)

# 6. تشغيل الخدمات
print_message "[6/7] تشغيل خدمات OpenVAS..." "$YELLOW"
gvm-start
sleep 10
check_status "تشغيل الخدمات"

# 7. التحقق من التثبيت
print_message "[7/7] التحقق من التثبيت..." "$YELLOW"
gvm-check-setup > /tmp/gvm-check.log 2>&1

if grep -q "OK" /tmp/gvm-check.log; then
    check_status "التحقق من التثبيت"
else
    print_message "⚠ هناك تحذيرات في التثبيت، راجع /tmp/gvm-check.log" "$YELLOW"
fi

# طباعة النتائج
echo ""
print_message "╔════════════════════════════════════════════════╗" "$GREEN"
print_message "║          تم التثبيت بنجاح! ✓                 ║" "$GREEN"
print_message "╚════════════════════════════════════════════════╝" "$GREEN"
echo ""
print_message "معلومات الدخول:" "$BLUE"
print_message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$BLUE"
print_message "الرابط: https://127.0.0.1:9392" "$GREEN"
print_message "اسم المستخدم: admin" "$GREEN"
print_message "كلمة المرور: $PASSWORD" "$GREEN"
print_message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$BLUE"
echo ""
print_message "⚠ احفظ كلمة المرور في مكان آمن!" "$YELLOW"
print_message "⚠ يمكنك الآن فتح المتصفح والذهاب إلى الرابط أعلاه" "$YELLOW"
echo ""

# حفظ البيانات في ملف
echo "Username: admin" > ~/openvas_credentials.txt
echo "Password: $PASSWORD" >> ~/openvas_credentials.txt
echo "URL: https://127.0.0.1:9392" >> ~/openvas_credentials.txt
print_message "✓ تم حفظ بيانات الدخول في: ~/openvas_credentials.txt" "$GREEN"