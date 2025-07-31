-- สร้างข้อมูลทดสอบสำหรับระบบขาย

-- ตรวจสอบและสร้างตาราง promotions ถ้ายังไม่มี
CREATE TABLE IF NOT EXISTS promotions (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  discount_type VARCHAR(50) CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value DECIMAL(10,2) NOT NULL,
  min_purchase DECIMAL(10,2) DEFAULT 0,
  max_discount DECIMAL(10,2),
  start_date TIMESTAMP DEFAULT NOW(),
  end_date TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ลบข้อมูลเก่าก่อนเพิ่มข้อมูลใหม่
DELETE FROM products WHERE barcode IN ('001', '002', '003', '004', '005', '006', '007', '008', '101', '102', '103', '104');
DELETE FROM promotions WHERE name IN ('ส่วนลด 10%', 'ลด 20 บาท');

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

-- สร้างโปรโมชั่นทดสอบ (ใช้ข้อมูลพื้นฐานเท่านั้น)
INSERT INTO promotions (name, description, is_active) VALUES
('ส่วนลด 10%', 'ซื้อครบ 100 บาท ลด 10%', true),
('ลด 20 บาท', 'ซื้อครบ 200 บาท ลด 20 บาท', true);

-- อัปเดตข้อมูลที่มีอยู่แล้ว (ถ้ามี)
UPDATE products SET 
  is_active = true,
  stock_quantity = CASE 
    WHEN stock_quantity IS NULL OR stock_quantity = 0 THEN 50
    ELSE stock_quantity
  END
WHERE is_active IS NULL OR is_active = false;
