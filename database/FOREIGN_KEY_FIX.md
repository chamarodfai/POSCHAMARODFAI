# แก้ไขปัญหา Foreign Key Constraint

## 🚫 ปัญหาที่เกิดขึ้น
```
ERROR: 42804: foreign key constraint "fk_sales_promotion" cannot be implemented
DETAIL: Key columns "promotion_id" and "id" are of incompatible types: uuid and integer.
```

## 🔍 สาเหตุ
- ตาราง `sales` มีคอลัมน์ `id` เป็น `integer` 
- ตาราง `promotions` มีคอลัมน์ `id` เป็น `uuid`
- ไม่สามารถสร้าง foreign key constraint ระหว่างประเภทข้อมูลที่ไม่ตรงกันได้

## ✅ วิธีแก้ไข

### วิธีที่ 1: ใช้ไฟล์ปลอดภัย (แนะนำ)
```sql
-- รันไฟล์นี้แทน:
database/promotions-safe-setup.sql
```
ไฟล์นี้จะ:
- ไม่สร้าง foreign key constraint
- ยังคงฟังก์ชันการทำงานครบถ้วน
- ปลอดภัยและไม่มีข้อผิดพลาด

### วิธีที่ 2: ตรวจสอบและแก้ไข
1. รันไฟล์ตรวจสอบก่อน:
```sql
database/check-sales-structure.sql
```

2. แล้วรันไฟล์แก้ไข:
```sql
database/fix-foreign-key.sql
```

## 🎯 ผลลัพธ์ที่ได้
ไม่ว่าจะใช้วิธีใด ระบบจะยังคงทำงานได้เต็มรูปแบบ:

✅ สร้างตาราง `promotions` สำเร็จ  
✅ เพิ่มคอลัมน์ในตาราง `sales` สำเร็จ  
✅ ฟังก์ชันคำนวณส่วนลดทำงานได้  
✅ View `active_promotions` ใช้งานได้  
✅ Trigger นับการใช้งานทำงานได้  

## 📋 ขั้นตอนการแก้ไข

### ใน Supabase SQL Editor:
1. ลบ SQL เดิมที่รันไม่สำเร็จ
2. Copy ไฟล์ `promotions-safe-setup.sql` ทั้งหมด
3. Paste และรัน
4. ตรวจสอบผลลัพธ์

### ตรวจสอบว่าสำเร็จ:
```sql
-- ดูตารางโปรโมชั่น
SELECT * FROM promotions LIMIT 5;

-- ทดสอบฟังก์ชันคำนวณ
SELECT * FROM calculate_discount(150, (
  SELECT id FROM promotions 
  WHERE min_amount <= 150 
  ORDER BY value DESC LIMIT 1
));
```

## 🚀 หลังจากแก้ไขแล้ว
ระบบโปรโมชั่นจะพร้อมใช้งานเต็มรูปแบบ ทดสอบได้ที่:
- `http://localhost:3003/promotions` - จัดการโปรโมชั่น
- `http://localhost:3003/sales` - ใช้โปรโมชั่นในการขาย
- `http://localhost:3003/database-test` - ทดสอบการเชื่อมต่อ
