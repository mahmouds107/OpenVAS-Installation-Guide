# 🛡️ دليل تثبيت OpenVAS على Kali Linux

> **دليل شامل وسهل لتثبيت وإعداد نظام فحص الثغرات Greenbone**
> 
> إعداد: **عبدالرحمن عبدالغفار** | مستشار أمن سيبراني ومتخصص الاستجابة للحوادث

---

## 📋 المحتويات

- [متطلبات التشغيل](#متطلبات-التشغيل)
- [التحضير قبل التثبيت](#التحضير-قبل-التثبيت)
- [خطوات التثبيت](#خطوات-التثبيت)
- [التأكد من التثبيت](#التأكد-من-التثبيت)
- [الوصول للواجهة](#الوصول-للواجهة)
- [إعداد الوصول عن بعد](#إعداد-الوصول-عن-بعد)
- [حل المشاكل الشائعة](#حل-المشاكل-الشائعة)
- [الصيانة الدورية](#الصيانة-الدورية)
- [أوامر مهمة](#أوامر-مهمة)

---

## ⚙️ متطلبات التشغيل

قبل ما تبدأ، تأكد إن جهازك يستوفي المتطلبات دي:

**المواصفات المطلوبة:**
- نظام التشغيل: Kali Linux (آخر إصدار)
- الذاكرة RAM: 8 جيجا على الأقل (يفضل 16 جيجا)
- المساحة: 20 جيجا فاضية على الأقل
- المعالج: 4 أنوية أو أكثر
- إنترنت: اتصال مستقر

**تحقق من المواصفات:**
```bash
# شوف الرامات
free -h

# شوف المساحة المتاحة
df -h

# شوف المعالج
lscpu | grep -i core
```

---

## 🧹 التحضير قبل التثبيت

### الخطوة 1: حذف التثبيتات القديمة (لو موجودة)

**مهم جداً:** لو كنت جربت تثبت OpenVAS قبل كده، لازم تنضف كل حاجة الأول:

```bash
# إيقاف أي خدمات شغالة
sudo systemctl stop gsad ospd-openvas gvmd 2>/dev/null || true

# حذف البرامج القديمة
sudo apt remove --purge gvm openvas* -y
sudo apt autoremove -y

# مسح الملفات القديمة (⚠️ تحذير: هيمسح كل البيانات القديمة)
sudo rm -rf /var/lib/gvm
sudo rm -rf /var/lib/openvas
sudo rm -rf /var/log/gvm
sudo rm -rf /etc/gvm

# مسح قواعد البيانات القديمة
sudo -u postgres psql -c "DROP DATABASE IF EXISTS gvmd;" 2>/dev/null || true
sudo -u postgres psql -c "DROP USER IF EXISTS gvm;" 2>/dev/null || true
```

### الخطوة 2: تحديث النظام

```bash
# تحديث قائمة البرامج
sudo apt update

# تحديث كل البرامج (مهم جداً!)
sudo apt full-upgrade -y

# تثبيت البرامج الأساسية
sudo apt install -y postgresql postgresql-contrib redis-server
```

### الخطوة 3: التأكد من الخدمات الأساسية

```bash
# التأكد إن PostgreSQL شغال
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo systemctl status postgresql

# التأكد إن Redis شغال
sudo systemctl start redis-server
sudo systemctl enable redis-server
sudo systemctl status redis-server
```

**لازم الاتنين يكونوا شغالين (active) ولونهم أخضر!**

---

## 📦 خطوات التثبيت

### الخطوة 1: تثبيت GVM

```bash
# تثبيت البرنامج الأساسي
sudo apt install gvm -y
```

**انتظر لحد ما التثبيت يخلص (ممكن ياخد 5-10 دقايق)**

### الخطوة 2: إعداد النظام

```bash
# تشغيل سكريبت الإعداد
sudo gvm-setup
```

**⏳ هذه الخطوة ممكن تاخد من 15 لـ 45 دقيقة!**

**📝 ملاحظة مهمة جداً:**
- هيطلعلك username و password في الآخر
- اكتبهم في مكان آمن!
- مثال: `User created with password 'abc123-def456-789'`

### الخطوة 3: تشغيل الخدمات

```bash
# تشغيل كل خدمات OpenVAS
sudo gvm-start
```

انتظر دقيقة أو اتنين عشان كل حاجة تبدأ صح.

---

## ✅ التأكد من التثبيت

### فحص شامل للنظام

```bash
# فحص التثبيت
sudo gvm-check-setup
```

**المفروض تشوف رسالة:**
```
It seems like your GVM-23.x.x installation is OK.
```

لو شفت الرسالة دي، يبقى كل حاجة تمام! ✓

### فحوصات إضافية

```bash
# تأكد إن الخدمات شغالة
sudo systemctl status gsad
sudo systemctl status gvmd
sudo systemctl status ospd-openvas

# تأكد إن البورتات مفتوحة
sudo ss -tulnp | grep 9392
```

---

## 🌐 الوصول للواجهة

### الوصول المحلي (من نفس الجهاز)

1. افتح المتصفح
2. اكتب في العنوان:
```
https://127.0.0.1:9392
```
3. استخدم اليوزر والباسورد اللي طلعلك في خطوة الإعداد

**⚠️ هيطلعلك تحذير أمان في المتصفح - اضغط "متقدم" ثم "متابعة"**

---

## 🌍 إعداد الوصول عن بعد

**الإعداد الافتراضي:** OpenVAS يشتغل بس على الجهاز نفسه (127.0.0.1)

**عشان توصل من أي جهاز تاني على الشبكة:**

### الطريقة الموصى بها

```bash
# إنشاء مجلد الإعدادات
sudo mkdir -p /etc/systemd/system/gsad.service.d/

# إنشاء ملف الإعداد
sudo nano /etc/systemd/system/gsad.service.d/override.conf
```

**اكتب الكود ده في الملف:**
```ini
[Service]
ExecStart=
ExecStart=/usr/sbin/gsad --foreground --listen=0.0.0.0 --port=9392 --http-only
```

**احفظ الملف:**
- اضغط `Ctrl + O` (حفظ)
- اضغط `Enter`
- اضغط `Ctrl + X` (خروج)

**طبق التغييرات:**
```bash
# إعادة تحميل الإعدادات
sudo systemctl daemon-reload

# إعادة تشغيل الخدمة
sudo systemctl restart gsad
```

### التأكد من التغييرات

```bash
# تأكد إن الخدمة بتسمع على كل الشبكات
sudo ss -tulnp | grep 9392
```

**المفروض تشوف:**
```
tcp   LISTEN   0.0.0.0:9392
```

### الوصول من جهاز تاني

**في المتصفح على الجهاز التاني اكتب:**
```
https://رقم_IP_الخاص_بالسيرفر:9392
```

**مثال:**
```
https://192.168.1.100:9392
```

**لمعرفة رقم IP الخاص بالسيرفر:**
```bash
ip addr show | grep inet
```

---

## 🔍 حل المشاكل الشائعة

### المشكلة 1: الموقع مش بيفتح

**الأعراض:**
- الموقع مش راضي يفتح
- رسالة "لا يمكن الوصول"

**الحل:**
```bash
# أعد تشغيل الخدمة
sudo systemctl restart gsad

# تأكد إنها شغالة
sudo systemctl status gsad

# شوف الأخطاء
sudo journalctl -u gsad -n 30
```

**لو لسه مش شغال:**
```bash
# أوقف كل حاجة وشغل تاني
sudo gvm-stop
sleep 5
sudo gvm-start
```

---

### المشكلة 2: نسيت اليوزر أو الباسورد

**الحل:**

**لمعرفة اليوزرات الموجودة:**
```bash
sudo runuser -u _gvm -- gvmd --get-users
```

**تغيير الباسورد:**
```bash
# غير "admin" باليوزر بتاعك
sudo runuser -u _gvm -- gvmd --user=admin --new-password='كلمة_سر_جديدة123!'
```

**إنشاء يوزر جديد:**
```bash
sudo runuser -u _gvm -- gvmd --create-user=admin2 --password='كلمة_سر_قوية123!'
```

---

### المشكلة 3: الفحص مش شغال أو بطيء

**الأعراض:**
- الفحص واقف على "بدء الفحص"
- الفحص بطيء جداً

**الحل:**
```bash
# أعد تشغيل الماسح الضوئي
sudo systemctl restart ospd-openvas
sudo systemctl restart notus-scanner

# تحديث بيانات الثغرات
sudo runuser -u _gvm -- openvas --update-vt-info

# أعد تشغيل كل شيء
sudo gvm-stop && sudo gvm-start
```

---

### المشكلة 4: قاعدة البيانات فيها مشكلة

**الأعراض:**
- رسائل خطأ عن قاعدة البيانات
- الخدمة gvmd مش بتشتغل

**الحل:**
```bash
# أعد تشغيل PostgreSQL
sudo systemctl restart postgresql

# تأكد إنها شغالة
sudo systemctl status postgresql

# لو المشكلة مستمرة، تحقق من الاتصال
sudo -u _gvm psql -d gvmd -c "SELECT version();"
```

---

### المشكلة 5: الجهاز بطيء جداً أثناء الفحص

**الحل:**

**قلل عدد الفحوصات المتزامنة:**

1. افتح الواجهة
2. روح على: **Configuration** → **Scanners**
3. اختار **Default Scanner** واضغط **Edit**
4. قلل "Maximum concurrently scanned hosts" لـ **10** أو **15**
5. احفظ التغييرات

---

### المشكلة 6: التحديثات مش بتنزل

**الأعراض:**
- Feed Status بيقول "قديم" أو "Not Current"
- البيانات قديمة

**الحل:**
```bash
# تحديث يدوي للبيانات (ممكن ياخد وقت طويل)
sudo runuser -u _gvm -- greenbone-feed-sync --type GVMD_DATA
sudo runuser -u _gvm -- greenbone-feed-sync --type SCAP
sudo runuser -u _gvm -- greenbone-feed-sync --type CERT

# أعد تشغيل الخدمات
sudo gvm-stop && sudo gvm-start
```

**التحقق من التحديث:**
- روح على الواجهة
- **Administration** → **Feed Status**
- انتظر لحد ما كل حاجة تبقى "Current"

---

## 🔄 الصيانة الدورية

### تحديثات أسبوعية

```bash
# تحديث بيانات الثغرات (كل أسبوع)
sudo runuser -u _gvm -- greenbone-feed-sync --type ALL
sudo gvm-stop && sudo gvm-start
```

### تحديثات شهرية

```bash
# تحديث البرنامج نفسه (كل شهر)
sudo apt update
sudo apt upgrade gvm -y
```

### نسخ احتياطي (مهم!)

```bash
# نسخ احتياطي من قاعدة البيانات
sudo -u postgres pg_dump gvmd > ~/backup_gvm_$(date +%Y%m%d).sql

# نسخ احتياطي من الإعدادات
sudo tar -czf ~/backup_gvm_config_$(date +%Y%m%d).tar.gz /etc/gvm
```

---

## 📊 أوامر مهمة

### التحكم في الخدمات

| **الوظيفة** | **الأمر** |
|-------------|-----------|
| تشغيل OpenVAS | `sudo gvm-start` |
| إيقاف OpenVAS | `sudo gvm-stop` |
| إعادة التشغيل | `sudo gvm-stop && sudo gvm-start` |
| حالة الخدمات | `sudo systemctl status gsad gvmd ospd-openvas` |

### إدارة المستخدمين

| **الوظيفة** | **الأمر** |
|-------------|-----------|
| عرض المستخدمين | `sudo runuser -u _gvm -- gvmd --get-users` |
| إنشاء مستخدم | `sudo runuser -u _gvm -- gvmd --create-user=اسم --password=كلمة_سر` |
| تغيير الباسورد | `sudo runuser -u _gvm -- gvmd --user=اسم --new-password=كلمة_سر_جديدة` |

### التحديثات والصيانة

| **الوظيفة** | **الأمر** |
|-------------|-----------|
| تحديث النظام | `sudo apt update && sudo apt upgrade -y` |
| تحديث البيانات | `sudo runuser -u _gvm -- greenbone-feed-sync --type ALL` |
| فحص التثبيت | `sudo gvm-check-setup` |
| عرض السجلات | `sudo journalctl -u gsad -u gvmd -f` |

### الفحص والتأكد

| **الوظيفة** | **الأمر** |
|-------------|-----------|
| معرفة IP السيرفر | `ip addr show` |
| فحص البورتات | `sudo ss -tulnp | grep 9392` |
| فحص الاتصال | `curl -k https://127.0.0.1:9392 -I` |

---

## 🔒 نصائح أمنية

### 1. استخدام Firewall

```bash
# السماح للوصول من شبكة محددة فقط
sudo ufw allow from 192.168.1.0/24 to any port 9392 proto tcp

# تفعيل الجدار الناري
sudo ufw enable
```

### 2. تغيير الباسورد بشكل دوري

```bash
# غير الباسورد كل 3 شهور
sudo runuser -u _gvm -- gvmd --user=admin --new-password='باسورد_جديد_قوي!'
```

### 3. مراقبة السجلات

```bash
# راجع السجلات بشكل دوري
sudo tail -f /var/log/gvm/gvmd.log
```

---

## 📚 مصادر مفيدة

- **الموقع الرسمي:** [Greenbone Community](https://community.greenbone.net/)
- **التوثيق:** [Greenbone Documentation](https://greenbone.github.io/docs/)
- **منتدى الدعم:** [Greenbone Forum](https://forum.greenbone.net/)
- **أدوات Kali:** [Kali Tools - GVM](https://www.kali.org/tools/gvm/)

---

## ❓ أسئلة شائعة

**س: كم المساحة اللي بياخدها OpenVAS؟**
ج: تقريباً 10-15 جيجا بعد التثبيت والتحديثات.

**س: ممكن أشغله على VirtualBox؟**
ج: أيوه، بس أعطي الجهاز الوهمي 8 جيجا رام على الأقل.

**س: التحديثات بتاخد وقت قد إيه؟**
ج: أول مرة ممكن تاخد ساعات، بعد كده بتبقى أسرع.

**س: ممكن أفحص أي جهاز على الشبكة؟**
ج: أيوه، بس لازم يكون عندك صلاحية قانونية!

**س: الفحص بياخد وقت قد إيه؟**
ج: على حسب عدد الأجهزة، ممكن من دقايق لساعات.

---

## 🎯 نصائح مهمة

✅ **اعمل تحديث للنظام بشكل دوري**
✅ **خلي backup للبيانات المهمة**
✅ **استخدم باسوردات قوية**
✅ **راجع نتائج الفحص بعناية**
✅ **اقرأ التقارير كويس قبل تطبيق أي حل**

⚠️ **مهم جداً:** 
- استخدم OpenVAS بشكل قانوني فقط
- لا تفحص أي جهاز بدون إذن
- احتفظ بسرية البيانات

---

## 📝 سجل التغييرات

- **الإصدار 1.0** (24 أكتوبر 2025): النسخة الأولى
  - دليل تثبيت كامل
  - حلول للمشاكل الشائعة
  - نصائح أمنية وصيانة

---

## 👤 عن المؤلف

**عبدالرحمن عبدالغفار**
- 🛡️ مستشار أمن سيبراني ومتخصص الاستجابة للحوادث
- 🔍 مختبر اختراق ومتخصص إدارة الثغرات
- 📍 الفيوم، مصر

**للتواصل:**
- GitHub: [@YourUsername](https://github.com/your-username)
- LinkedIn: [عبدالرحمن عبدالغفار](https://linkedin.com/in/your-profile)

---

## 💝 شكر وتقدير

إذا أفادك هذا الدليل، أرجو منك:
- ⭐ عمل Star للمشروع على GitHub
- 🔄 مشاركة الدليل مع الآخرين
- 💬 ترك تعليقات ومقترحات للتحسين

---

**🚀 بالتوفيق في رحلتك مع أمن المعلومات!**

---

---

## 🤖 السكريبتات المساعدة

لتسهيل العمل، يوجد مجموعة سكريبتات جاهزة في مجلد `scripts/`:

### 1. التثبيت التلقائي
```bash
sudo bash scripts/install_openvas.sh
```
يقوم بتثبيت وإعداد OpenVAS بشكل كامل وتلقائي.

### 2. فحص الحالة
```bash
sudo bash scripts/check_status.sh
```
يعرض حالة الخدمات والنظام بالكامل.

### 3. تحديث البيانات
```bash
sudo bash scripts/update_feeds.sh
```
يحدث قواعد بيانات الثغرات (Feeds).

### 4. نسخ احتياطي
```bash
sudo bash scripts/backup_openvas.sh
```
ينشئ نسخة احتياطية كاملة من البيانات.

### 5. حذف كامل
```bash
sudo bash scripts/uninstall_openvas.sh
```
يحذف OpenVAS بشكل كامل من النظام.

**📝 ملاحظة:** كل السكريبتات تحتاج صلاحيات root (sudo)

---
```

احفظ الملف، ثم:
1. ارجع GitHub Desktop
2. Summary: `تحديث README: إضافة قسم السكريبتات`
3. **Commit to main**
4. **Push origin**

---

## 🔄 سيناريو التحديث المستقبلي

**مثلاً عايز تعدل على سكريبت التثبيت:**

### الخطوات:

1. **Repository** → **Show in Explorer**
2. روح `scripts/install_openvas.sh`
3. افتح الملف وعدل اللي عايزه
4. احفظ (Ctrl + S)
5. ارجع GitHub Desktop
6. هتلاقي الملف المعدل في **Changes**
7. Summary: `تحسين سكريبت التثبيت`
8. Description: `- إضافة فحص المساحة قبل التثبيت`
9. **Commit to main**
10. **Push origin**

---

## ✅ الهيكل النهائي للمشروع
```
OpenVAS-Installation-Guide/
├── README.md
├── LICENSE
├── .gitignore
└── scripts/
    ├── install_openvas.sh
    ├── uninstall_openvas.sh
    ├── check_status.sh
    ├── backup_openvas.sh
    └── update_feeds.sh