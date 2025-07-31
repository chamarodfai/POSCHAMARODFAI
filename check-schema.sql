-- ตรวจสอบโครงสร้างตาราง promotions
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'promotions' 
ORDER BY ordinal_position;

-- ตรวจสอบข้อมูลในตาราง promotions
SELECT * FROM promotions LIMIT 5;

-- ตรวจสอบโครงสร้างตาราง products
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'products' 
ORDER BY ordinal_position;

-- ตรวจสอบข้อมูลในตาราง products
SELECT * FROM products LIMIT 5;
