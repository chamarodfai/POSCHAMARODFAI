-- POS CHAMA Database Schema - Updated Version
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

-- Insert sample categories
INSERT INTO categories (name, description, color) VALUES
('อาหารและเครื่องดื่ม', 'สินค้าอาหารและเครื่องดื่มทุกประเภท', '#10B981'),
('เครื่องใช้ไฟฟ้า', 'อุปกรณ์และเครื่องใช้ไฟฟ้า', '#3B82F6'),
('เสื้อผ้าและแฟชั่น', 'เสื้อผ้าและเครื่องประดับ', '#F59E0B'),
('เครื่องเขียน', 'อุปกรณ์เครื่องเขียนและสำนักงาน', '#8B5CF6'),
('ของใช้ในบ้าน', 'เครื่องใช้ในบ้านและของตกแต่ง', '#EF4444');

-- Insert sample products with realistic Thai pricing
INSERT INTO products (name, description, price, cost, barcode, category, stock_quantity, min_stock_level) VALUES
('น้ำดื่ม 600ml', 'น้ำดื่มบริสุทธิ์ขนาด 600ml', 10.00, 7.00, '8851234567890', 'อาหารและเครื่องดื่ม', 100, 20),
('ข้าวกล่องไก่ทอด', 'ข้าวกล่องไก่ทอดพร้อมผัก', 45.00, 30.00, '8851234567891', 'อาหารและเครื่องดื่ม', 50, 10),
('ปากกาลูกลื่น', 'ปากกาลูกลื่นสีน้ำเงิน', 15.00, 10.00, '8851234567892', 'เครื่องเขียน', 200, 50),
('เสื้อยืดผ้าฝ้าย', 'เสื้อยืดผ้าฝ้าย 100% สีขาว', 299.00, 200.00, '8851234567893', 'เสื้อผ้าและแฟชั่น', 30, 5),
('แก้วน้ำแก้ว', 'แก้วน้ำแก้วใสขนาด 350ml', 89.00, 60.00, '8851234567894', 'ของใช้ในบ้าน', 75, 15),
('โทรศัพท์มือถือ', 'โทรศัพท์สมาร์ทโฟน Android', 8990.00, 7500.00, '8851234567895', 'เครื่องใช้ไฟฟ้า', 5, 2),
('สมุดจดบันทึก', 'สมุดจดบันทึก A5 80 แผ่น', 35.00, 25.00, '8851234567896', 'เครื่องเขียน', 150, 30),
('ชาไทยเย็น', 'ชาไทยเย็นแบบดั้งเดิม', 25.00, 15.00, '8851234567897', 'อาหารและเครื่องดื่ม', 80, 20),
('กางเกงยีนส์', 'กางเกงยีนส์ขายาว สีน้ำเงิน', 799.00, 550.00, '8851234567898', 'เสื้อผ้าและแฟชั่น', 20, 5),
('พัดลมตั้งโต๊ะ', 'พัดลมตั้งโต๊ะ 12 นิ้ว', 1290.00, 950.00, '8851234567899', 'เครื่องใช้ไฟฟ้า', 10, 3);

-- Insert sample customer
INSERT INTO customers (name, email, phone, address) VALUES
('ลูกค้าทั่วไป', 'general@customer.com', '0801234567', 'ที่อยู่ของลูกค้า'),
('คุณสมชาย ใจดี', 'somchai@email.com', '0812345678', '123 ถ.สุขุมวิท กรุงเทพฯ'),
('คุณสมหญิง สวยงาม', 'somying@email.com', '0823456789', '456 ถ.ราชดำริ กรุงเทพฯ');

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

-- Success message
SELECT 'POS CHAMA Database initialized successfully! 🎉' AS message;
