#!/bin/bash

#######################################################
# OpenVAS Complete Uninstallation Script
# Author: AbdulRhman AbdulGhaffar
# Description: حذف OpenVAS بشكل كامل من النظام
#######################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${2}${1}${NC}"
}

# التحقق من صلاحيات الروت
if [ "$EUID" -ne 0 ]; then 
    print_message "يرجى تشغيل السكريبت بصلاحيات root (استخدم sudo)" "$RED"
    exit 1
fi

clear
print_message "╔════════════════════════════════════════════════╗" "$RED"
print_message "║      سكريبت حذف OpenVAS الكامل                ║" "$RED"
print_message "║      Complete OpenVAS Removal Script          ║" "$RED"
print_message "╚════════════════════════════════════════════════╝" "$RED"
echo ""

print_message "⚠ تحذير: هذا السكريبت سيحذف OpenVAS وكل البيانات المرتبطة به!" "$YELLOW"
read -p "هل أنت متأكد؟ (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    print_message "تم الإلغاء." "$GREEN"
    exit 0
fi

echo ""
print_message "[1/6] إيقاف الخدمات..." "$YELLOW"
gvm-stop 2>/dev/null || true
systemctl stop gsad 2>/dev/null || true
systemctl stop gvmd 2>/dev/null || true
systemctl stop ospd-openvas 2>/dev/null || true
systemctl stop notus-scanner 2>/dev/null || true
print_message "✓ تم إيقاف الخدمات" "$GREEN"

print_message "[2/6] حذف الحزم..." "$YELLOW"
apt remove --purge -y gvm openvas* 2>/dev/null || true
apt autoremove -y
print_message "✓ تم حذف الحزم" "$GREEN"

print_message "[3/6] حذف البيانات..." "$YELLOW"
rm -rf /var/lib/gvm
rm -rf /var/lib/openvas
rm -rf /var/log/gvm
rm -rf /etc/gvm
rm -rf /usr/share/gvm
rm -rf /run/gvmd
print_message "✓ تم حذف البيانات" "$GREEN"

print_message "[4/6] حذف قواعد البيانات..." "$YELLOW"
sudo -u postgres psql -c "DROP DATABASE IF EXISTS gvmd;" 2>/dev/null || true
sudo -u postgres psql -c "DROP USER IF EXISTS gvm;" 2>/dev/null || true
print_message "✓ تم حذف قواعد البيانات" "$GREEN"

print_message "[5/6] تعطيل الخدمات..." "$YELLOW"
systemctl disable gsad 2>/dev/null || true
systemctl disable gvmd 2>/dev/null || true
systemctl disable ospd-openvas 2>/dev/null || true
systemctl disable notus-scanner 2>/dev/null || true
print_message "✓ تم تعطيل الخدمات" "$GREEN"

print_message "[6/6] تنظيف نهائي..." "$YELLOW"
apt clean
print_message "✓ تم التنظيف النهائي" "$GREEN"

echo ""
print_message "╔════════════════════════════════════════════════╗" "$GREEN"
print_message "║         تم حذف OpenVAS بنجاح! ✓               ║" "$GREEN"
print_message "╚════════════════════════════════════════════════╝" "$GREEN"
echo ""