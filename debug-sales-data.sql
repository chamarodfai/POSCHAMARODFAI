-- ตรวจสอบข้อมูลในตาราง sale_items และ products
-- Run this in Supabase SQL Editor

-- 1. ตรวจสอบข้อมูลใน sale_items
SELECT 
    si.id,
    si.sale_id,
    si.product_id,
    si.quantity,
    si.product_name,
    p.name as product_name_from_products
FROM sale_items si
LEFT JOIN products p ON si.product_id = p.id
ORDER BY si.sale_id DESC
LIMIT 10;

-- 2. ตรวจสอบข้อมูลใน sales
SELECT 
    s.id,
    s.sale_number,
    s.total_amount,
    s.product_names
FROM sales s
ORDER BY s.sale_date DESC
LIMIT 5;

-- 3. ตรวจสอบการเชื่อมต่อระหว่าง sales และ sale_items
SELECT 
    s.id as sales_id,
    s.sale_number,
    COUNT(si.id) as item_count
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
GROUP BY s.id, s.sale_number
ORDER BY s.id DESC
LIMIT 10;
