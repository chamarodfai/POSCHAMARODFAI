-- แก้ไขปัญหา product_names ไม่แสดงชื่อสินค้า
-- Run this in Supabase SQL Editor

-- วิธีที่ 1: อัปเดตทีละขั้นตอน
-- ขั้นตอนที่ 1: อัปเดต product_name ใน sale_items ก่อน
UPDATE sale_items 
SET product_name = p.name
FROM products p
WHERE sale_items.product_id = p.id 
AND (sale_items.product_name IS NULL OR sale_items.product_name = '');

-- ขั้นตอนที่ 2: อัปเดต product_names ใน sales
UPDATE sales 
SET product_names = subquery.product_list
FROM (
    SELECT 
        si.sale_id,
        STRING_AGG(
            COALESCE(si.product_name, p.name) || ' (x' || si.quantity || ')', 
            ', ' 
            ORDER BY si.id
        ) as product_list
    FROM sale_items si
    LEFT JOIN products p ON si.product_id = p.id
    GROUP BY si.sale_id
) as subquery
WHERE sales.id = subquery.sale_id;

-- ขั้นตอนที่ 3: สำหรับกรณีที่ไม่มี sale_items (ถ้ามี)
UPDATE sales 
SET product_names = 'ไม่มีรายการสินค้า'
WHERE product_names IS NULL OR product_names = '';

-- ตรวจสอบผลลัพธ์
SELECT 
    s.id,
    s.sale_number,
    s.total_amount,
    s.product_names,
    s.sale_date
FROM sales s
ORDER BY s.sale_date DESC
LIMIT 10;

-- ตรวจสอบข้อมูล sale_items ด้วย
SELECT 
    si.sale_id,
    si.product_name,
    si.quantity,
    p.name as original_product_name
FROM sale_items si
LEFT JOIN products p ON si.product_id = p.id
WHERE si.sale_id IN (
    SELECT id FROM sales ORDER BY sale_date DESC LIMIT 3
)
ORDER BY si.sale_id, si.id;
