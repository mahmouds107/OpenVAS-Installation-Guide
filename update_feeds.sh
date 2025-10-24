#!/bin/bash

#######################################################
# OpenVAS Feed Update Script
# Author: AbdulRhman AbdulGhaffar
# Description: تحديث قواعد بيانات الثغرات
#######################################################

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${2}${1}${NC}"
}

if [ "$EUID" -ne 0 ]; then 
    print_message "يرجى تشغيل السكريبت بصلاحيات root" "$RED"
    exit 1
fi

print_message "╔════════════════════════════════════════════════╗" "$BLUE"
print_message "║    OpenVAS Feed Update - تحديث البيانات       ║" "$BLUE"
print_message "╚════════════════════════════════════════════════╝" "$BLUE"
echo ""

print_message "⚠ هذه العملية قد تستغرق وقتاً طويلاً..." "$YELLOW"
echo ""

# تحديث GVMD Data
print_message "[1/3] تحديث GVMD Data..." "$YELLOW"
sudo runuser -u _gvm -- greenbone-feed-sync --type GVMD_DATA
print_message "✓ تم تحديث GVMD Data" "$GREEN"

# تحديث SCAP Data
print_message "[2/3] تحديث SCAP Data..." "$YELLOW"
sudo runuser -u _gvm -- greenbone-feed-sync --type SCAP
print_message "✓ تم تحديث SCAP Data" "$GREEN"

# تحديث CERT Data
print_message "[3/3] تحديث CERT Data..." "$YELLOW"
sudo runuser -u _gvm -- greenbone-feed-sync --type CERT
print_message "✓ تم تحديث CERT Data" "$GREEN"

echo ""
print_message "إعادة تشغيل الخدمات..." "$YELLOW"
gvm-stop
sleep 5
gvm-start

echo ""
print_message "╔════════════════════════════════════════════════╗" "$GREEN"
print_message "║         تم التحديث بنجاح! ✓                   ║" "$GREEN"
print_message "╚════════════════════════════════════════════════╝" "$GREEN"
```

---

## 📤 خطوات رفع الملفات على GitHub Desktop

### الخطوة 1: إنشاء الملفات

1. **Repository** → **Show in Explorer**
2. داخل المجلد، اعمل مجلد جديد اسمه `scripts`
3. داخل مجلد `scripts`، اعمل الملفات الـ 5 دول:
   - `install_openvas.sh`
   - `uninstall_openvas.sh`
   - `check_status.sh`
   - `backup_openvas.sh`
   - `update_feeds.sh`

4. انسخ كل كود في الملف المناسب ليه
5. احفظ كل الملفات

---

### الخطوة 2: Commit التغييرات

**ارجع لـ GitHub Desktop:**

1. هتلاقي الملفات الجديدة ظهرت في **Changes**
2. في خانة **Summary** اكتب:
```
إضافة سكريبتات مساعدة
```

3. في خانة **Description** اكتب:
```
- سكريبت تثبيت تلقائي (install_openvas.sh)
- سكريبت حذف كامل (uninstall_openvas.sh)
- سكريبت فحص الحالة (check_status.sh)
- سكريبت نسخ احتياطي (backup_openvas.sh)
- سكريبت تحديث البيانات (update_feeds.sh)