-- แก้ไขปัญหาชื่อสินค้าไม่ขึ้น - ตรวจสอบข้อมูลก่อน
-- Run this in Supabase SQL Editor

-- 1. ตรวจสอบข้อมูลใน sale_items สำหรับ sales ล่าสุด
SELECT 
    'sale_items data' as table_name,
    si.id,
    si.sale_id,
    si.product_id,
    si.quantity,
    si.product_name,
    si.unit_price,
    si.total_price
FROM sale_items si
WHERE si.sale_id IN (
    SELECT id FROM sales ORDER BY sale_date DESC LIMIT 5
)
ORDER BY si.sale_id, si.id;

-- 2. ตรวจสอบข้อมูลใน products
SELECT 
    'products data' as table_name,
    p.id,
    p.name,
    p.category,
    p.is_active
FROM products p
WHERE p.is_active = true
ORDER BY p.id
LIMIT 10;

-- 3. ตรวจสอบการเชื่อมต่อ
SELECT 
    'join test' as test_name,
    s.id as sales_id,
    s.sale_number,
    si.id as sale_item_id,
    si.product_id,
    p.name as product_name,
    si.quantity
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
LEFT JOIN products p ON si.product_id = p.id
WHERE s.id IN (
    SELECT id FROM sales ORDER BY sale_date DESC LIMIT 3
)
ORDER BY s.id, si.id;

-- 4. ถ้ามีข้อมูล ให้อัปเดต product_names
UPDATE sales 
SET product_names = (
    SELECT STRING_AGG(
        CASE 
            WHEN p.name IS NOT NULL THEN p.name || ' (x' || si.quantity || ')'
            ELSE 'สินค้าไม่ทราบชื่อ (x' || si.quantity || ')'
        END, 
        ', ' 
        ORDER BY si.id
    )
    FROM sale_items si
    LEFT JOIN products p ON si.product_id = p.id
    WHERE si.sale_id = sales.id
)
WHERE EXISTS (
    SELECT 1 FROM sale_items si2 WHERE si2.sale_id = sales.id
);

-- 5. ตรวจสอบผลลัพธ์
SELECT 
    'final result' as result_type,
    s.id,
    s.sale_number,
    s.total_amount,
    s.product_names,
    s.sale_date
FROM sales s
ORDER BY s.sale_date DESC
LIMIT 10;
