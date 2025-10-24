#!/bin/bash

#######################################################
# OpenVAS Status Check Script
# Author: AbdulRhman AbdulGhaffar
# Description: فحص حالة OpenVAS والخدمات
#######################################################

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   OpenVAS Status Check - فحص حالة النظام      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}✓${NC} $2: ${GREEN}شغال${NC}"
        return 0
    else
        echo -e "${RED}✗${NC} $2: ${RED}متوقف${NC}"
        return 1
    fi
}

print_header

# فحص الخدمات
echo -e "${YELLOW}▸ حالة الخدمات:${NC}"
check_service gsad "واجهة الويب (gsad)"
check_service gvmd "مدير الثغرات (gvmd)"
check_service ospd-openvas "الماسح الضوئي (ospd-openvas)"
check_service notus-scanner "Notus Scanner"
check_service postgresql "PostgreSQL"
check_service redis-server "Redis"

echo ""

# فحص البورتات
echo -e "${YELLOW}▸ البورتات المفتوحة:${NC}"
if ss -tulnp | grep -q ":9392"; then
    PORT_INFO=$(ss -tulnp | grep ":9392" | awk '{print $5}')
    echo -e "${GREEN}✓${NC} البورت 9392 مفتوح على: ${GREEN}$PORT_INFO${NC}"
else
    echo -e "${RED}✗${NC} البورت 9392 غير مفتوح"
fi

echo ""

# فحص Feed Status
echo -e "${YELLOW}▸ حالة التحديثات (Feeds):${NC}"
FEED_STATUS=$(sudo runuser -u _gvm -- gvmd --get-feeds 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "$FEED_STATUS" | head -5
else
    echo -e "${RED}✗${NC} لا يمكن الحصول على حالة التحديثات"
fi

echo ""

# فحص المساحة
echo -e "${YELLOW}▸ استخدام المساحة:${NC}"
df -h /var/lib/gvm 2>/dev/null | tail -1 | awk '{print "استخدام القرص: " $5 " (" $3 " من " $2 ")"}'

echo ""

# فحص الذاكرة
echo -e "${YELLOW}▸ استخدام الذاكرة:${NC}"
free -h | grep Mem | awk '{print "الرام المستخدم: " $3 " من " $2 " (" $3/$2*100 "%)"}'

echo ""

# رابط الوصول
echo -e "${YELLOW}▸ روابط الوصول:${NC}"
echo -e "   المحلي: ${GREEN}https://127.0.0.1:9392${NC}"
LOCAL_IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)
if [ ! -z "$LOCAL_IP" ]; then
    echo -e "   الشبكة: ${GREEN}https://$LOCAL_IP:9392${NC}"
fi

echo ""