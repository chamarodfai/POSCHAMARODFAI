-- POS CHAMA Database Schema - Tea Shop Version
-- Drop existing tables if they exist
DROP TABLE IF EXISTS inventory_movements CASCADE;
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- Drop existing policies and views
DROP POLICY IF EXISTS "Allow all operations on menu_items" ON menu_items;
DROP POLICY IF EXISTS "Allow all operations on orders" ON orders;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP VIEW IF EXISTS menu_profit;

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Categories table
CREATE TABLE categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  color VARCHAR(7) DEFAULT '#3B82F6',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table
CREATE TABLE products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
  barcode VARCHAR(100) UNIQUE,
  category VARCHAR(255) NOT NULL,
  stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
  min_stock_level INTEGER DEFAULT 5 CHECK (min_stock_level >= 0),
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customers table
CREATE TABLE customers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20),
  address TEXT,
  points INTEGER DEFAULT 0 CHECK (points >= 0),
  total_spent DECIMAL(12,2) DEFAULT 0 CHECK (total_spent >= 0),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sales table
CREATE TABLE sales (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  customer_id UUID REFERENCES customers(id),
  total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
  discount_amount DECIMAL(12,2) DEFAULT 0 CHECK (discount_amount >= 0),
  tax_amount DECIMAL(12,2) DEFAULT 0 CHECK (tax_amount >= 0),
  payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('cash', 'card', 'transfer', 'qr')),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sale items table
CREATE TABLE sale_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory movements table
CREATE TABLE inventory_movements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  product_id UUID NOT NULL REFERENCES products(id),
  movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('in', 'out', 'adjustment')),
  quantity INTEGER NOT NULL,
  reason VARCHAR(255) NOT NULL,
  reference_id UUID,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_stock ON products(stock_quantity);
CREATE INDEX idx_sales_created_at ON sales(created_at);
CREATE INDEX idx_sales_customer_id ON sales(customer_id);
CREATE INDEX idx_sales_status ON sales(status);
CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product_id ON sale_items(product_id);
CREATE INDEX idx_inventory_movements_product_id ON inventory_movements(product_id);
CREATE INDEX idx_inventory_movements_created_at ON inventory_movements(created_at);

-- Create functions for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (development mode)
CREATE POLICY "Allow all operations for everyone" ON categories FOR ALL USING (true);
CREATE POLICY "Allow all operations for everyone" ON products FOR ALL USING (true);
CREATE POLICY "Allow all operations for everyone" ON customers FOR ALL USING (true);
CREATE POLICY "Allow all operations for everyone" ON sales FOR ALL USING (true);
CREATE POLICY "Allow all operations for everyone" ON sale_items FOR ALL USING (true);
CREATE POLICY "Allow all operations for everyone" ON inventory_movements FOR ALL USING (true);

-- Insert categories สำหรับร้านชาไทย
INSERT INTO categories (name, description, color) VALUES
('เครื่องดื่ม', 'ชาไทย กาแฟ เครื่องดื่มเย็น และเครื่องดื่มร้อน', '#F97316'),
('ขนม', 'ขนมไทย ขนมปัง เค้ก และของหวาน', '#EAB308'),
('Topping', 'ไข่มุก บุบเบิ้ล วุ้น และของเสริมในเครื่องดื่ม', '#10B981');

-- Insert sample products สำหรับร้านชาใต้
INSERT INTO products (name, description, price, cost, barcode, category, stock_quantity, min_stock_level) VALUES
-- เครื่องดื่ม
('ชาไทยเย็น', 'ชาไทยหอมเข้มแบบใต้ๆ เย็นชื่นใจ', 25.00, 12.00, '8850001000001', 'เครื่องดื่ม', 50, 10),
('ชาไทยร้อน', 'ชาไทยร้อนหอมกรุ่น รสชาติเข้มข้น', 20.00, 10.00, '8850001000002', 'เครื่องดื่ม', 50, 10),
('ชาเย็นนมสด', 'ชาเย็นผสมนมสดหอมมัน', 30.00, 15.00, '8850001000003', 'เครื่องดื่ม', 40, 8),
('ชาดำเย็น', 'ชาดำเย็นรสชาติเข้มข้น', 22.00, 11.00, '8850001000004', 'เครื่องดื่ม', 45, 10),
('กาแฟเย็น', 'กาแฟเย็นหอมกรุ่น', 25.00, 12.00, '8850001000005', 'เครื่องดื่ม', 40, 8),
('กาแฟร้อน', 'กาแฟร้อนเข้มข้น', 20.00, 10.00, '8850001000006', 'เครื่องดื่ม', 40, 8),
('โอเลี้ยง', 'เครื่องดื่มโอเลี้ยงเย็นๆ', 20.00, 8.00, '8850001000007', 'เครื่องดื่ม', 30, 6),
('นมเย็น', 'นมสดเย็นหอมมัน', 18.00, 8.00, '8850001000008', 'เครื่องดื่ม', 35, 7),
('ชาเขียวเย็น', 'ชาเขียวเย็นสดชื่น', 25.00, 12.00, '8850001000009', 'เครื่องดื่ม', 30, 6),
('ชาอูหลงเย็น', 'ชาอูหลงเย็นหอมกรุ่น', 30.00, 15.00, '8850001000010', 'เครื่องดื่ม', 25, 5),

-- ขนม
('ขนมปังปิ้ง', 'ขนมปังปิ้งเนยนม หวานหอม', 15.00, 8.00, '8850002000001', 'ขนม', 100, 20),
('ขนมปังปิ้งช็อกโกแลต', 'ขนมปังปิ้งหน้าช็อกโกแลต', 18.00, 10.00, '8850002000002', 'ขนม', 80, 15),
('โรตี', 'โรตีหวานเนยนม', 20.00, 10.00, '8850002000003', 'ขนม', 60, 12),
('โรตีกล้วย', 'โรตีกล้วยหอมหวาน', 25.00, 13.00, '8850002000004', 'ขนม', 50, 10),
('ขนมครก', 'ขนมครกแบบโบราณ', 12.00, 6.00, '8850002000005', 'ขนม', 80, 15),
('ทองหยิบ', 'ทองหยิบขนมไทยโบราณ', 15.00, 8.00, '8850002000006', 'ขนม', 60, 12),
('คุกกี้', 'คุกกี้เนยสดหอมกรุ่น', 10.00, 5.00, '8850002000007', 'ขนม', 100, 20),
('มาการอง', 'มาการองหวานหอม', 8.00, 4.00, '8850002000008', 'ขนม', 120, 25),
('เค้กช็อกโกแลต', 'เค้กช็อกโกแลตชิ้นเล็ก', 25.00, 12.00, '8850002000009', 'ขนม', 40, 8),
('บราวนี่', 'บราวนี่ช็อกโกแลตเข้มข้น', 22.00, 11.00, '8850002000010', 'ขนม', 50, 10),

-- Topping
('ไข่มุกดำ', 'ไข่มุกดำเหนียวนุ่ม', 10.00, 5.00, '8850003000001', 'Topping', 200, 40),
('ไข่มุกใส', 'ไข่มุกใสเหนียวนุ่ม', 10.00, 5.00, '8850003000002', 'Topping', 200, 40),
('วุ้นกาแฟ', 'วุ้นกาแฟหอมกรุ่น', 8.00, 4.00, '8850003000003', 'Topping', 150, 30),
('วุ้นชาเขียว', 'วุ้นชาเขียวหอมมัน', 8.00, 4.00, '8850003000004', 'Topping', 150, 30),
('บุบเบิ้ล', 'บุบเบิ้ลเหนียวนุ่ม', 12.00, 6.00, '8850003000005', 'Topping', 100, 20),
('พุดดิ้ง', 'พุดดิ้งหวานนุ่ม', 10.00, 5.00, '8850003000006', 'Topping', 120, 25),
('เจลลี่', 'เจลลี่หวานเหนียว', 8.00, 4.00, '8850003000007', 'Topping', 150, 30),
('นาต้าเดอโคโค', 'นาต้าเดอโคโคเหนียวนุ่ม', 10.00, 5.00, '8850003000008', 'Topping', 100, 20),
('แครีมชีส', 'แครีมชีสหอมมัน', 15.00, 8.00, '8850003000009', 'Topping', 80, 15),
('วิปครีม', 'วิปครีมหวานนุ่ม', 12.00, 6.00, '8850003000010', 'Topping', 100, 20);

-- Insert sample customer
INSERT INTO customers (name, email, phone, address) VALUES
('ลูกค้าทั่วไป', 'general@customer.com', '0801234567', 'ลูกค้าเดินผ่าน'),
('คุณสมชาย รักชา', 'somchai.tea@email.com', '0812345678', '123 ถ.ตลาดใต้ ยะลา'),
('คุณสมหญิง หวานใจ', 'somying.sweet@email.com', '0823456789', '456 ถ.ชาไทย สงขลา'),
('คุณมานี ชอบขนม', 'manee.snack@email.com', '0834567890', '789 ถ.ขนมไทย ปัตตานี');

-- Create useful views for reporting
CREATE OR REPLACE VIEW product_profit AS
SELECT 
  id,
  name,
  price,
  cost,
  (price - cost) AS profit,
  CASE 
    WHEN cost > 0 THEN ROUND(((price - cost) / cost * 100)::numeric, 2)
    ELSE 0 
  END AS profit_percentage,
  category,
  stock_quantity,
  min_stock_level,
  is_active,
  created_at,
  updated_at
FROM products;

CREATE OR REPLACE VIEW low_stock_products AS
SELECT 
  id,
  name,
  category,
  stock_quantity,
  min_stock_level,
  (min_stock_level - stock_quantity) AS shortage,
  price,
  cost
FROM products 
WHERE stock_quantity <= min_stock_level 
  AND is_active = true
ORDER BY shortage DESC;

-- View สำหรับสินค้าขายดี (จะมีข้อมูลหลังจากขายแล้ว)
CREATE OR REPLACE VIEW popular_products AS
SELECT 
  p.id,
  p.name,
  p.category,
  p.price,
  COALESCE(SUM(si.quantity), 0) as total_sold,
  COALESCE(SUM(si.total_price), 0) as total_revenue
FROM products p
LEFT JOIN sale_items si ON p.id = si.product_id
LEFT JOIN sales s ON si.sale_id = s.id AND s.status = 'completed'
WHERE p.is_active = true
GROUP BY p.id, p.name, p.category, p.price
ORDER BY total_sold DESC;

-- Success message
SELECT 'POS CHAMA Tea Shop Database initialized successfully! 🍵🧡' AS message;
SELECT 'Categories: เครื่องดื่ม, ขนม, Topping' AS categories;
SELECT count(*) AS total_products FROM products;
SELECT category, count(*) AS product_count FROM products GROUP BY category ORDER BY category;
