# active error log reader.sql

**خلاصه کوتاه:**

این اسکریپت امکان مشاهده، برش و تحلیل فایل لاگ فعال خوشه‌ی پایگاه داده PostgreSQL را به صورت پویا فراهم می‌کند (این خوشه باید Primary باشد و نمی‌تواند در حالت Recovery باشد). این اسکریپت روشی برای خواندن لاگ خطاهای DBMS شبیه به `xp_readerrorlog` در SQL Server معرفی می‌کند.

### **توضیحات و هدف اسکریپت**

این اسکریپت برای مانیتورینگ و پرس‌وجوی پویای فایل‌های لاگ PostgreSQL با استفاده از **Foreign Data Wrapper (FDW)** طراحی شده است. این اسکریپت یک جدول خارجی (`pg_log_file_dynamic`) ایجاد می‌کند که به فایل لاگ PostgreSQL مپ می‌شود و به شما امکان می‌دهد داده‌های لاگ را مستقیماً از پایگاه داده پرس‌وجو کنید. این اسکریپت همچنین شامل یک تابع (`update_log_file_path`) است که مسیر فایل لاگ را به صورت پویا به‌روزرسانی می‌کند زمانی که فایل لاگ rotate می‌شود (مثلاً وقتی `pg_rotate_logfile()` فراخوانی می‌شود یا فایل لاگ به حد مجاز اندازه‌ی خود می‌رسد).

---

### **اجزای کلیدی و هدف آن‌ها**

1. **تنظیم Foreign Data Wrapper (FDW)**:

* این اسکریپت یک اکستنشن `file_fdw` و یک سرور خارجی (`my_log_server`) ایجاد می‌کند تا PostgreSQL بتواند فایل‌های خارجی (در این مورد، فایل لاگ PostgreSQL) را بخواند.

2. **جدول خارجی (`pg_log_file_dynamic`)**:

* یک جدول خارجی ایجاد می‌شود که فایل لاگ PostgreSQL (در قالب CSV) را به یک قالب جدولی ساختاریافته مپ می‌کند. هر ستون در جدول مربوط به یک فیلد در فایل لاگ است، مانند `log_time`, `user`, `database`, `error_severity` و غیره.
* این امکان را فراهم می‌کند که فایل لاگ را مستقیماً با استفاده از SQL پرس‌وجو کنید.

3. **به‌روزرسانی پویای مسیر فایل لاگ**:

* تابع `update_log_file_path` به‌صورت پویا گزینه `filename` جدول خارجی را به‌روزرسانی می‌کند تا به فایل لاگ فعلی اشاره کند. این زمانی مفید است که فایل لاگ rotate می‌شود (مثلاً پس از فراخوانی `pg_rotate_logfile()` یا وقتی فایل لاگ به حد مجاز اندازه‌ی خود می‌رسد).
* این تابع مسیر فایل لاگ فعلی را با استفاده از `pg_current_logfile()` بازیابی می‌کند و جدول خارجی را بر این اساس به‌روزرسانی می‌کند.

4. **پرس‌وجوی داده‌های لاگ**:

* این اسکریپت شامل یک پرس‌وجوی نمونه برای بازیابی ورودی‌های لاگ از جدول خارجی است. این پرس‌وجو فیلدهای خاصی مانند شناسه تراکنش (`xid`) و شناسه فرآیند (`pid`) را استخراج و فرمت‌بندی می‌کند و نتایج را بر اساس `log_time` به ترتیب نزولی مرتب می‌کند.

---

### **موارد استفاده**

* **مانیتورینگ بلادرنگ لاگ**: فایل لاگ PostgreSQL را به‌صورت بلادرنگ پرس‌وجو کنید تا خطاها، هشدارها یا سایر رویدادهای لاگ را مانیتور کنید.
* **عیب‌یابی**: به سرعت خطاها یا مشکلات را با پرس‌وجوی مستقیم فایل لاگ از پایگاه داده شناسایی و تحلیل کنید.
* **اتوماسیون**: تحلیل لاگ را در گردش‌های کاری اتوماتیک یا سیستم‌های مانیتورینگ ادغام کنید.

---

### **نحوه عملکرد**

1. این اسکریپت یک جدول خارجی (`pg_log_file_dynamic`) ایجاد می‌کند که به فایل لاگ PostgreSQL مپ می‌شود.
2. تابع `update_log_file_path` اطمینان می‌دهد که جدول خارجی همیشه به فایل لاگ فعلی اشاره می‌کند، حتی پس از rotate شدن فایل لاگ.
3. شما می‌توانید جدول خارجی را پرس‌وجو کنید تا داده‌های لاگ را مستقیماً از پایگاه داده بازیابی و تحلیل کنید.

---

### **پرس‌وجوی نمونه**

پرس‌وجوی ارائه شده فیلدهای خاصی از فایل لاگ را استخراج و فرمت‌بندی می‌کند، مانند:

* `log_time`: زمان‌مهر ورودی لاگ.
* `error_severity`: سطح شدت ورودی لاگ (مثلاً ERROR, WARNING).
* `executed_text`: کوئری SQL اجرا شده (در صورت وجود).
* سایر فیلدها مانند `user`, `database`, `pid`, و `application_name` زمینه‌ی اضافی برای ورودی لاگ فراهم می‌کنند.

---

### **مزایا**

* **مدیریت پویای فایل لاگ**: مسیر فایل لاگ را به‌صورت خودکار هنگام rotate شدن به‌روزرسانی می‌کند.
* **تحلیل لاگ مبتنی بر SQL**: امکان پرس‌وجوهای قدرتمند SQL برای فیلتر کردن، مرتب‌سازی و تحلیل داده‌های لاگ را فراهم می‌کند.
* **ادغام**: می‌تواند در ابزارهای مانیتورینگ یا اسکریپت‌ها برای تحلیل خودکار لاگ ادغام شود.

این اسکریپت به‌ویژه برای مدیران پایگاه داده و توسعه‌دهندگانی مفید است که نیاز به مانیتورینگ و تحلیل لاگ‌های PostgreSQL به‌صورت بلادرنگ یا به‌عنوان بخشی از گردش کار عیب‌یابی خود دارند.

# get objects added by an installed extension.sql

نام‌ها، انواع و آرگومان‌ها/نام‌های ستون‌های اشیایی که ایجاد یک اکستنشن به پایگاه داده اضافه کرده است را دریافت کنید.

# pg_class report.sql

### **توضیحات و هدف اسکریپت**

این اسکریپت یک **پرس‌وجوی فراداده جامع** است که برای بازیابی اطلاعات دقیق درباره اشیاء پایگاه داده (جداول، ایندکس‌ها و غیره) در یک پایگاه داده PostgreSQL طراحی شده است. این اسکریپت با پیوستن چندین جدول کاتالوگ سیستم، نمای جامعی از روابط اشیاء، مالکیت، جزئیات ذخیره‌سازی و سایر فراداده‌ها ارائه می‌دهد.

---

### **اجزای کلیدی و هدف آن‌ها**

1. **بازیابی فراداده**:

* این اسکریپت جدول کاتالوگ سیستم `pg_class` را پرس‌وجو می‌کند که شامل اطلاعاتی درباره اشیاء پایگاه داده مانند جداول، ایندکس‌ها، دنباله‌ها و غیره است.
* این اسکریپت سایر جدول‌های کاتالوگ سیستم (`pg_namespace`, `pg_type`, `pg_authid`, `pg_am`, `pg_tablespace`, `pg_rewrite`, `pg_index`) را به هم پیوند می‌دهد تا فراداده را با جزئیات بیشتری غنی کند.

2. **روابط اشیاء**:

* روابط بین اشیاء را شناسایی می‌کند، مانند:
  * جداول والد برای ایندکس‌ها (`cindex2parent.relname`).
  * ایندکس‌های مرتبط با جداول (`STRING_AGG(cparent2index.relname, ', ')`).
  * جداول TOAST (`ctoast.relname`) مرتبط با اشیاء بزرگ.
  * قوانین بازنویسی (`rw.rulename`) اعمال شده روی شیء.

3. **جزئیات مالکیت و ذخیره‌سازی**:

* مالک شیء (`a.rolname`) را بازیابی می‌کند.
* روش دسترسی (`am.amname`) و tablespace (`ts.spcname`) استفاده شده توسط شیء را ارائه می‌دهد.

4. **گروه‌بندی و تجمیع**:

* از `GROUP BY` و `STRING_AGG` برای تجمیع اطلاعات مرتبط استفاده می‌کند، مانند فهرست کردن تمام ایندکس‌های مرتبط با یک جدول در یک سطر.

5. **مرتب‌سازی**:

* نتایج را بر اساس شناسه شیء (`c.oid`) برای خروجی‌های سازگار و منطقی مرتب می‌کند.

---

### **موارد استفاده**

* **مستندسازی پایگاه داده**: ایجاد یک گزارش دقیق از اشیاء پایگاه داده، روابط آن‌ها و فراداده.
* **عیب‌یابی**: شناسایی وابستگی‌های اشیاء، مالکیت و جزئیات ذخیره‌سازی برای اشکال‌زدایی یا بهینه‌سازی.
* **تحلیل ساختار پایگاه داده**: درک ساختار پایگاه داده، شامل ایندکس‌ها، جداول TOAST و قوانین بازنویسی.
* **حسابرسی و انطباق**: بررسی مالکیت اشیاء و روش‌های دسترسی برای اهداف امنیتی یا انطباق.

---

### **ستون‌های خروجی**

* `oid`: شناسه شیء پایگاه داده.
* `relname`: نام شیء (مثلاً جدول، ایندکس).
* `Schema Name`: اسکیمایی که شیء در آن قرار دارد.
* `Type Name`: نوع داده شیء.
* `Composite Type Name`: نام نوع ترکیبی (در صورت وجود).
* `Owner Name`: مالک شیء.
* `Access Method Name`: روش دسترسی استفاده شده توسط شیء (مثلاً heap, btree).
* `relfilenode`: فایل‌نود مرتبط با شیء.
* `Tablespace Name`: tablespace که شیء در آن ذخیره شده است.
* `Index Parent Table`: جدول والد برای یک ایندکس (در صورت وجود).
* `Table Indexes`: فهرست جداگانه‌ای از ایندکس‌های مرتبط با یک جدول.
* `Toast Relname`: جدول TOAST مرتبط با شیء (در صورت وجود).
* `Rewrite Rulename`: قانون بازنویسی مرتبط با شیء (در صورت وجود).

---

### **مزایا**

* **فراداده جامع**: نمای دقیقی از اشیاء پایگاه داده و روابط آن‌ها ارائه می‌دهد.
* **انعطاف‌پذیری**: می‌تواند برای فیلتر کردن اشیاء خاص (مثلاً با استفاده از `WHERE`) سفارشی‌سازی شود.
* **کارایی**: اطلاعات را از چندین جدول کاتالوگ سیستم در یک پرس‌وجو تجمیع می‌کند.

این اسکریپت به‌ویژه برای مدیران پایگاه داده و توسعه‌دهندگانی مفید است که نیاز به تحلیل یا مستندسازی ساختار و روابط اشیاء در یک پایگاه داده PostgreSQL دارند.
