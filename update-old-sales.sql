-- อัปเดตข้อมูลเก่าในตาราง sales ให้มีชื่อสินค้า
-- Run this in Supabase SQL Editor

-- ขั้นตอนที่ 1: อัปเดตข้อมูลเก่าให้มีชื่อสินค้าจากราคา (เดาจากราคา)
UPDATE sales 
SET product_names = CASE 
    WHEN total_amount = 35.00 THEN 'ชาเย็น (x1)'
    WHEN total_amount = 25.00 THEN 'กาแฟร้อน (x1)'
    WHEN total_amount = 30.00 THEN 'กาแฟเย็น (x1)'
    WHEN total_amount = 20.00 THEN 'ชาร้อน (x1)'
    WHEN total_amount = 40.00 THEN 'คาปูชิโน่ (x1)'
    WHEN total_amount = 45.00 THEN 'ลาเต้ (x1)'
    WHEN total_amount = 15.00 THEN 'น้ำเปล่า (x1)'
    WHEN total_amount = 50.00 THEN 'กาแฟพิเศษ (x1)'
    WHEN total_amount = 60.00 THEN 'เครื่องดื่มผสม (x1)'
    WHEN total_amount = 70.00 THEN 'ชุดคอมโบ (x1)'
    WHEN total_amount = 65.00 THEN 'เครื่องดื่มพรีเมี่ยม (x1)'
    WHEN total_amount = 80.00 THEN 'เครื่องดื่มพิเศษ (x1)'
    WHEN total_amount = 55.00 THEN 'ชาไทย (x1)'
    WHEN total_amount = 75.00 THEN 'กาแฟเฟรปเป้ (x1)'
    WHEN total_amount = 85.00 THEN 'เครื่องดื่มเซ็ต (x1)'
    ELSE 'สินค้าอื่นๆ (x1)'
END
WHERE product_names IS NULL OR product_names = '' OR product_names = 'ไม่มีรายการสินค้า';

-- ขั้นตอนที่ 2: ตรวจสอบผลลัพธ์
SELECT 
    id,
    sale_number,
    total_amount,
    product_names,
    sale_date
FROM sales 
ORDER BY sale_date DESC
LIMIT 10;
