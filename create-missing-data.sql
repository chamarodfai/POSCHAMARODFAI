-- สร้างข้อมูล sale_items หากไม่มี (สำหรับกรณีที่ข้อมูลหาย)
-- Run this in Supabase SQL Editor

-- Step 1: ตรวจสอบว่า sales มี sale_items หรือไม่
SELECT 
    s.id as sales_id,
    s.sale_number,
    s.total_amount,
    COUNT(si.id) as item_count
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
GROUP BY s.id, s.sale_number, s.total_amount
HAVING COUNT(si.id) = 0
ORDER BY s.sale_date DESC;

-- Step 2: สำหรับ sales ที่ไม่มี sale_items ให้สร้างข้อมูลจำลอง
-- (กรณีที่ข้อมูลหายไป - ใส่ชื่อสินค้าจากราคา)
INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, total_price, product_name)
SELECT 
    s.id as sale_id,
    (SELECT id FROM products WHERE is_active = true ORDER BY id LIMIT 1) as product_id,
    1 as quantity,
    s.total_amount as unit_price,
    s.total_amount as total_price,
    CASE 
        WHEN s.total_amount = 35.00 THEN 'ชาเย็น'
        WHEN s.total_amount = 25.00 THEN 'กาแฟร้อน'
        WHEN s.total_amount = 30.00 THEN 'กาแฟเย็น'
        WHEN s.total_amount = 20.00 THEN 'ชาร้อน'
        WHEN s.total_amount = 40.00 THEN 'คาปูชิโน่'
        WHEN s.total_amount = 45.00 THEN 'ลาเต้'
        WHEN s.total_amount = 15.00 THEN 'น้ำเปล่า'
        WHEN s.total_amount = 50.00 THEN 'กาแฟพิเศษ'
        WHEN s.total_amount = 60.00 THEN 'เครื่องดื่มผสม'
        WHEN s.total_amount = 70.00 THEN 'ชุดคอมโบ'
        WHEN s.total_amount = 65.00 THEN 'เครื่องดื่มพรีเมี่ยม'
        ELSE 'สินค้าอื่นๆ'
    END as product_name
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
WHERE si.id IS NULL;

-- Step 3: อัปเดต product_names ในตาราง sales
UPDATE sales 
SET product_names = (
    SELECT STRING_AGG(
        COALESCE(si.product_name, p.name, 'สินค้าไม่ทราบชื่อ') || ' (x' || si.quantity || ')', 
        ', ' 
        ORDER BY si.id
    )
    FROM sale_items si
    LEFT JOIN products p ON si.product_id = p.id
    WHERE si.sale_id = sales.id
);

-- Step 4: ตรวจสอบผลลัพธ์
SELECT 
    s.id,
    s.sale_number,
    s.total_amount,
    s.product_names,
    s.sale_date
FROM sales s
ORDER BY s.sale_date DESC
LIMIT 10;
