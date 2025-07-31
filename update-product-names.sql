-- Update product_names in sales table from products table
-- Run this in Supabase SQL Editor

-- อัปเดตคอลัมน์ product_names ในตาราง sales 
-- โดยดึงชื่อสินค้ามาจากตาราง products ผ่าน sale_items
UPDATE sales 
SET product_names = (
    SELECT STRING_AGG(
        p.name || ' (x' || si.quantity || ')', 
        ', ' 
        ORDER BY si.id
    )
    FROM sale_items si
    INNER JOIN products p ON si.product_id = p.id
    WHERE si.sale_id = sales.id
)
WHERE product_names IS NULL OR product_names = '';

-- ตรวจสอบผลลัพธ์
SELECT 
    id, 
    sale_number, 
    total_amount, 
    product_names,
    sale_date
FROM sales 
ORDER BY sale_date DESC
LIMIT 10;
