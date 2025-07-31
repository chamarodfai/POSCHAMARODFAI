-- Simple POS Setup for Tea Shop
-- Basic tables without complex constraints

-- Drop existing tables
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS promotions CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- Products table (simplified)
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  cost DECIMAL(10,2) NOT NULL,
  barcode TEXT,
  category TEXT NOT NULL,
  stock_quantity INTEGER DEFAULT 0,
  min_stock_level INTEGER DEFAULT 5,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Promotions table (simplified)
CREATE TABLE promotions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('percentage', 'fixed')),
  value DECIMAL(10, 2) NOT NULL,
  min_amount DECIMAL(10, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Customers table (simplified)
CREATE TABLE customers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sales table (simplified)
CREATE TABLE sales (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  total_amount DECIMAL(12,2) NOT NULL,
  subtotal DECIMAL(12,2),
  discount_amount DECIMAL(12,2) DEFAULT 0,
  discount_percentage DECIMAL(5,2) DEFAULT 0,
  promotion_id UUID,
  promotion_name TEXT,
  payment_method TEXT DEFAULT 'cash',
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sale items table (simplified)
CREATE TABLE sale_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sale_id UUID REFERENCES sales(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data for tea shop
INSERT INTO products (name, description, price, cost, barcode, category, stock_quantity) VALUES
-- เครื่องดื่ม
('ชาไทยเย็น', 'ชาไทยหอมเข้มแบบใต้ๆ เย็นชื่นใจ', 25.00, 12.00, '8850001000001', 'เครื่องดื่ม', 50),
('ชาไทยร้อน', 'ชาไทยร้อนหอมกรุ่น รสชาติเข้มข้น', 20.00, 10.00, '8850001000002', 'เครื่องดื่ม', 50),
('ชาเย็นนมสด', 'ชาเย็นผสมนมสดหอมมัน', 30.00, 15.00, '8850001000003', 'เครื่องดื่ม', 40),
('กาแฟเย็น', 'กาแฟเย็นหอมกรุ่น', 25.00, 12.00, '8850001000005', 'เครื่องดื่ม', 40),
('กาแฟร้อน', 'กาแฟร้อนเข้มข้น', 20.00, 10.00, '8850001000006', 'เครื่องดื่ม', 40),

-- ขนม
('ขนมปังปิ้ง', 'ขนมปังปิ้งเนยนม หวานหอม', 15.00, 8.00, '8850002000001', 'ขนม', 100),
('โรตี', 'โรตีหวานเนยนม', 20.00, 10.00, '8850002000003', 'ขนม', 60),
('โรตีกล้วย', 'โรตีกล้วยหอมหวาน', 25.00, 13.00, '8850002000004', 'ขนม', 50),
('คุกกี้', 'คุกกี้เนยสดหอมกรุ่น', 10.00, 5.00, '8850002000007', 'ขนม', 100),

-- Topping
('ไข่มุกดำ', 'ไข่มุกดำเหนียวนุ่ม', 10.00, 5.00, '8850003000001', 'Topping', 200),
('ไข่มุกใส', 'ไข่มุกใสเหนียวนุ่ม', 10.00, 5.00, '8850003000002', 'Topping', 200),
('วุ้นกาแฟ', 'วุ้นกาแฟหอมกรุ่น', 8.00, 4.00, '8850003000003', 'Topping', 150),
('บุบเบิ้ล', 'บุบเบิ้ลเหนียวนุ่ม', 12.00, 6.00, '8850003000005', 'Topping', 100),
('วิปครีม', 'วิปครีมหวานนุ่ม', 12.00, 6.00, '8850003000010', 'Topping', 100);

-- Insert promotions
INSERT INTO promotions (name, type, value, min_amount, description, is_active) VALUES
('ลด 10% ซื้อครบ 50', 'percentage', 10, 50, 'ลด 10% เมื่อซื้อครบ 50 บาท', true),
('ลด 15 บาท', 'fixed', 15, 80, 'ลด 15 บาท เมื่อซื้อครบ 80 บาท', true),
('ลด 15% ซื้อครบ 100', 'percentage', 15, 100, 'ลด 15% เมื่อซื้อครบ 100 บาท', true),
('ลด 20% ซื้อครบ 200', 'percentage', 20, 200, 'ลด 20% เมื่อซื้อครบ 200 บาท', true);

-- Insert sample customer
INSERT INTO customers (name, email, phone, address) VALUES
('ลูกค้าทั่วไป', 'general@customer.com', '0801234567', 'ลูกค้าเดินผ่าน');

-- Success message
SELECT 'Simple POS Tea Shop setup completed! 🍵' AS message;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_promotions FROM promotions;
