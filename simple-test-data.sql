-- Simple test data for POS system
-- ลบข้อมูลเก่าก่อน (ถ้ามี)
DELETE FROM sale_items;
DELETE FROM sales;
DELETE FROM products WHERE name IN ('ชาเย็น', 'กาแฟเย็น', 'น้ำส้ม', 'เครื่องดื่มพรีเมี่ยม', 'คุกกี้', 'เค้ก', 'ขนมปัง', 'ลูกอม', 'นมข้น', 'น้ำตาล', 'วิปครีม', 'ไข่มุก');

-- เพิ่มสินค้าเครื่องดื่ม
INSERT INTO products (name, barcode, selling_price, stock_quantity, category, is_active) VALUES
('ชาเย็น', '001', 35.00, 50, 'เครื่องดื่ม', true),
('กาแฟเย็น', '002', 40.00, 50, 'เครื่องดื่ม', true),
('น้ำส้ม', '003', 25.00, 30, 'เครื่องดื่ม', true),
('เครื่องดื่มพรีเมี่ยม', '004', 65.00, 20, 'เครื่องดื่ม', true);

-- เพิ่มสินค้าขนม
INSERT INTO products (name, barcode, selling_price, stock_quantity, category, is_active) VALUES
('คุกกี้', '005', 15.00, 100, 'ขนม', true),
('เค้ก', '006', 45.00, 20, 'ขนม', true),
('ขนมปัง', '007', 20.00, 50, 'ขนม', true),
('ลูกอม', '008', 10.00, 200, 'ขนม', true);

-- เพิ่ม Toppings
INSERT INTO products (name, barcode, selling_price, stock_quantity, category, is_active) VALUES
('นมข้น', '101', 5.00, 100, 'topping', true),
('น้ำตาล', '102', 2.00, 100, 'topping', true),
('วิปครีม', '103', 10.00, 50, 'topping', true),
('ไข่มุก', '104', 15.00, 30, 'topping', true);

-- ตรวจสอบผลลัพธ์
SELECT 'Products inserted:' as message, count(*) as count FROM products WHERE is_active = true;
