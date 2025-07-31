-- ==========================================
-- POS CHAMA COMPLETE ANALYTICS SYSTEM
-- ระบบจัดเก็บข้อมูลครบถ้วนสำหรับการวิเคราะห์
-- ==========================================

-- Drop existing tables
DROP TABLE IF EXISTS inventory_movements CASCADE;
DROP TABLE IF EXISTS sale_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS promotions CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS payment_methods CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS product_suppliers CASCADE;

-- Drop existing views and functions
DROP VIEW IF EXISTS daily_sales_report CASCADE;
DROP VIEW IF EXISTS weekly_sales_report CASCADE;
DROP VIEW IF EXISTS monthly_sales_report CASCADE;
DROP VIEW IF EXISTS yearly_sales_report CASCADE;
DROP VIEW IF EXISTS product_performance CASCADE;
DROP VIEW IF EXISTS category_performance CASCADE;
DROP VIEW IF EXISTS low_stock_alert CASCADE;
DROP VIEW IF EXISTS top_selling_products CASCADE;
DROP FUNCTION IF EXISTS get_sales_summary(DATE, DATE);
DROP FUNCTION IF EXISTS get_product_analytics(UUID);

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- MASTER DATA TABLES
-- ==========================================

-- Categories table (หมวดหมู่สินค้า)
CREATE TABLE categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  color VARCHAR(7) DEFAULT '#3B82F6',
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Suppliers table (ผู้จำหน่าย)
CREATE TABLE suppliers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  contact_person VARCHAR(255),
  phone VARCHAR(20),
  email VARCHAR(255),
  address TEXT,
  tax_id VARCHAR(20),
  payment_terms INTEGER DEFAULT 30, -- วันเครดิต
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table (สินค้า - ข้อมูลครบถ้วน)
CREATE TABLE products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sku VARCHAR(100) UNIQUE, -- รหัสสินค้าภายใน
  barcode VARCHAR(100) UNIQUE, -- บาร์โค้ด
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category_id UUID REFERENCES categories(id),
  category VARCHAR(255) NOT NULL, -- เก็บไว้เพื่อความเข้ากันได้
  
  -- ราคาและต้นทุน
  cost_price DECIMAL(12,2) NOT NULL DEFAULT 0, -- ราคาทุน
  selling_price DECIMAL(12,2) NOT NULL, -- ราคาขาย
  wholesale_price DECIMAL(12,2), -- ราคาส่ง
  retail_price DECIMAL(12,2), -- ราคาปลีก
  
  -- สต็อกและคลังสินค้า
  stock_quantity INTEGER DEFAULT 0,
  min_stock_level INTEGER DEFAULT 5, -- สต็อกขั้นต่ำ
  max_stock_level INTEGER DEFAULT 1000, -- สต็อกสูงสุด
  reorder_point INTEGER DEFAULT 10, -- จุดสั่งซื้อใหม่
  
  -- ข้อมูลเพิ่มเติม
  unit VARCHAR(50) DEFAULT 'ชิ้น', -- หน่วยนับ
  weight DECIMAL(8,3), -- น้ำหนัก (กรัม)
  dimensions VARCHAR(100), -- ขนาด กว้าง x ยาว x สูง
  image_url TEXT,
  tags TEXT[], -- แท็กสำหรับค้นหา
  
  -- การจัดการ
  is_active BOOLEAN DEFAULT true,
  is_trackable BOOLEAN DEFAULT true, -- ติดตามสต็อกหรือไม่
  is_sellable BOOLEAN DEFAULT true, -- ขายได้หรือไม่
  tax_rate DECIMAL(5,2) DEFAULT 0, -- อัตราภาษี
  
  -- วันที่
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- สำหรับสินค้าที่มีวันหมดอายุ
  expiry_date DATE,
  manufacturing_date DATE
);

-- Product Suppliers junction table (ผู้จำหน่ายของสินค้า)
CREATE TABLE product_suppliers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  supplier_id UUID REFERENCES suppliers(id) ON DELETE CASCADE,
  supplier_sku VARCHAR(100), -- รหัสสินค้าของผู้จำหน่าย
  cost_price DECIMAL(12,2), -- ราคาทุนจากผู้จำหน่ายนี้
  min_order_quantity INTEGER DEFAULT 1,
  lead_time_days INTEGER DEFAULT 7, -- ระยะเวลานำเข้า
  is_primary BOOLEAN DEFAULT false, -- ผู้จำหน่ายหลัก
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Customers table (ลูกค้า)
CREATE TABLE customers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  customer_code VARCHAR(50) UNIQUE, -- รหัสลูกค้า
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(20),
  address TEXT,
  date_of_birth DATE,
  gender VARCHAR(10), -- male, female, other
  
  -- ข้อมูลการซื้อ
  total_purchases INTEGER DEFAULT 0, -- จำนวนครั้งที่ซื้อ
  total_spent DECIMAL(15,2) DEFAULT 0, -- ยอดซื้อรวม
  average_order_value DECIMAL(12,2) DEFAULT 0, -- ยอดเฉลี่ยต่อครั้ง
  last_purchase_date TIMESTAMP WITH TIME ZONE,
  
  -- ระบบสมาชิก
  membership_level VARCHAR(50) DEFAULT 'Bronze', -- Bronze, Silver, Gold, Platinum
  points INTEGER DEFAULT 0,
  discount_percentage DECIMAL(5,2) DEFAULT 0,
  
  -- การจัดการ
  is_active BOOLEAN DEFAULT true,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment Methods table (วิธีการชำระเงิน)
CREATE TABLE payment_methods (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20) UNIQUE NOT NULL, -- cash, card, transfer, qr, etc.
  description TEXT,
  fee_percentage DECIMAL(5,2) DEFAULT 0, -- ค่าธรรมเนียม %
  fee_fixed DECIMAL(10,2) DEFAULT 0, -- ค่าธรรมเนียมคงที่
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Promotions table (โปรโมชั่น)
CREATE TABLE promotions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  code VARCHAR(50) UNIQUE, -- รหัสโปรโมชั่น
  name VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- ประเภทส่วนลด
  type VARCHAR(50) NOT NULL CHECK (type IN ('percentage', 'fixed', 'buy_x_get_y', 'bundle')),
  value DECIMAL(12,2) NOT NULL, -- ค่าส่วนลด
  min_amount DECIMAL(12,2) DEFAULT 0, -- ยอดขั้นต่ำ
  max_discount DECIMAL(12,2), -- ส่วนลดสูงสุด
  
  -- เงื่อนไข
  applicable_categories TEXT[], -- หมวดหมู่ที่ใช้ได้
  applicable_products UUID[], -- สินค้าที่ใช้ได้
  customer_groups VARCHAR(100)[], -- กลุ่มลูกค้าที่ใช้ได้
  
  -- ระยะเวลา
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  
  -- การใช้งาน
  usage_count INTEGER DEFAULT 0,
  max_usage INTEGER, -- จำนวนครั้งสูงสุดที่ใช้ได้
  max_usage_per_customer INTEGER DEFAULT 1,
  
  -- การจัดการ
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- TRANSACTION TABLES
-- ==========================================

-- Sales table (การขาย - ข้อมูลครบถ้วน)
CREATE TABLE sales (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sale_number VARCHAR(50) UNIQUE NOT NULL, -- เลขที่ใบเสร็จ
  
  -- ลูกค้าและพนักงาน
  customer_id UUID REFERENCES customers(id),
  cashier_name VARCHAR(255), -- ชื่อพนักงานขาย
  
  -- ยอดเงิน
  subtotal DECIMAL(15,2) NOT NULL, -- ยอดรวมก่อนส่วนลด
  discount_amount DECIMAL(12,2) DEFAULT 0, -- ส่วนลดเป็นเงิน
  discount_percentage DECIMAL(5,2) DEFAULT 0, -- ส่วนลดเป็น %
  tax_amount DECIMAL(12,2) DEFAULT 0, -- ภาษี
  total_amount DECIMAL(15,2) NOT NULL, -- ยอดรวมสุทธิ
  
  -- การชำระเงิน
  payment_method_id UUID REFERENCES payment_methods(id),
  payment_method VARCHAR(50) NOT NULL, -- เก็บไว้เพื่อความเข้ากันได้
  amount_paid DECIMAL(15,2), -- เงินที่รับมา
  change_amount DECIMAL(12,2) DEFAULT 0, -- เงินทอน
  payment_fee DECIMAL(10,2) DEFAULT 0, -- ค่าธรรมเนียมการชำระ
  
  -- โปรโมชั่น
  promotion_id UUID REFERENCES promotions(id),
  promotion_code VARCHAR(50),
  promotion_name VARCHAR(255),
  
  -- สถานะและรายละเอียด
  status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled', 'refunded')),
  sale_type VARCHAR(20) DEFAULT 'retail' CHECK (sale_type IN ('retail', 'wholesale', 'online')),
  channel VARCHAR(50) DEFAULT 'pos', -- pos, online, phone, etc.
  
  -- เวลาและสถานที่
  sale_date DATE DEFAULT CURRENT_DATE,
  sale_time TIME DEFAULT CURRENT_TIME,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- ข้อมูลเพิ่มเติม
  notes TEXT,
  receipt_printed BOOLEAN DEFAULT false,
  receipt_email_sent BOOLEAN DEFAULT false
);

-- Sale Items table (รายการสินค้าในการขาย)
CREATE TABLE sale_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  
  -- ข้อมูลสินค้า ณ เวลาขาย
  product_name VARCHAR(255) NOT NULL, -- เก็บชื่อไว้เผื่อสินค้าถูกลบ
  product_sku VARCHAR(100),
  product_barcode VARCHAR(100),
  category VARCHAR(255),
  
  -- ราคาและจำนวน
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(12,2) NOT NULL, -- ราคาต่อหน่วย
  cost_price DECIMAL(12,2), -- ต้นทุนต่อหน่วย
  discount_amount DECIMAL(10,2) DEFAULT 0, -- ส่วนลดรายการ
  tax_amount DECIMAL(10,2) DEFAULT 0, -- ภาษีรายการ
  total_price DECIMAL(12,2) NOT NULL, -- ราคารวมรายการ
  
  -- การวิเคราะห์
  profit_amount DECIMAL(12,2), -- กำไรรายการ
  profit_percentage DECIMAL(5,2), -- % กำไร
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory Movements table (การเคลื่อนไหวสต็อก)
CREATE TABLE inventory_movements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  product_id UUID NOT NULL REFERENCES products(id),
  
  -- ประเภทการเคลื่อนไหว
  movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('in', 'out', 'adjustment', 'transfer', 'return', 'damage', 'expired')),
  quantity INTEGER NOT NULL, -- + สำหรับเข้า, - สำหรับออก
  quantity_before INTEGER NOT NULL, -- จำนวนก่อนเคลื่อนไหว
  quantity_after INTEGER NOT NULL, -- จำนวนหลังเคลื่อนไหว
  
  -- ข้อมูลการเคลื่อนไหว
  reference_type VARCHAR(50), -- sale, purchase, adjustment, etc.
  reference_id UUID, -- sale_id, purchase_id, etc.
  reference_number VARCHAR(100), -- เลขที่อ้างอิง
  
  -- รายละเอียด
  reason VARCHAR(255) NOT NULL,
  notes TEXT,
  cost_price DECIMAL(12,2), -- ราคาทุน ณ เวลานั้น
  
  -- ผู้ดำเนินการ
  performed_by VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================

-- Products indexes
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_stock ON products(stock_quantity);
CREATE INDEX idx_products_name_search ON products USING gin(to_tsvector('english', name));

-- Sales indexes
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_created_at ON sales(created_at);
CREATE INDEX idx_sales_customer_id ON sales(customer_id);
CREATE INDEX idx_sales_status ON sales(status);
CREATE INDEX idx_sales_payment_method ON sales(payment_method);
CREATE INDEX idx_sales_total ON sales(total_amount);
CREATE INDEX idx_sales_number ON sales(sale_number);

-- Sale items indexes
CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product_id ON sale_items(product_id);
CREATE INDEX idx_sale_items_created_at ON sale_items(created_at);

-- Inventory movements indexes
CREATE INDEX idx_inventory_product_id ON inventory_movements(product_id);
CREATE INDEX idx_inventory_created_at ON inventory_movements(created_at);
CREATE INDEX idx_inventory_type ON inventory_movements(movement_type);
CREATE INDEX idx_inventory_reference ON inventory_movements(reference_type, reference_id);

-- Customers indexes
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_active ON customers(is_active);
CREATE INDEX idx_customers_membership ON customers(membership_level);

-- ==========================================
-- INSERT MASTER DATA
-- ==========================================

-- Insert categories
INSERT INTO categories (name, description, color, sort_order) VALUES
('เครื่องดื่ม', 'ชาไทย กาแฟ เครื่องดื่มเย็น และเครื่องดื่มร้อน', '#F97316', 1),
('ขนม', 'ขนมไทย ขนมปัง เค้ก และของหวาน', '#EAB308', 2),
('Topping', 'ไข่มุก บุบเบิ้ล วุ้น และของเสริมในเครื่องดื่ม', '#10B981', 3);

-- Insert payment methods
INSERT INTO payment_methods (name, code, description, sort_order) VALUES
('เงินสด', 'cash', 'ชำระด้วยเงินสด', 1),
('บัตรเครดิต/เดบิต', 'card', 'ชำระด้วยบัตรเครดิตหรือเดบิต', 2),
('โอนเงิน', 'transfer', 'โอนเงินผ่านธนาคาร', 3),
('QR Code', 'qr', 'ชำระผ่าน QR Code', 4),
('PromptPay', 'promptpay', 'ชำระผ่าน PromptPay', 5);

-- Insert sample products สำหรับร้านชาใต้
INSERT INTO products (sku, barcode, name, description, category, cost_price, selling_price, stock_quantity, min_stock_level, unit) VALUES
-- เครื่องดื่ม
('DRK001', '8850001000001', 'ชาไทยเย็น', 'ชาไทยหอมเข้มแบบใต้ๆ เย็นชื่นใจ', 'เครื่องดื่ม', 12.00, 25.00, 50, 10, 'แก้ว'),
('DRK002', '8850001000002', 'ชาไทยร้อน', 'ชาไทยร้อนหอมกรุ่น รสชาติเข้มข้น', 'เครื่องดื่ม', 10.00, 20.00, 50, 10, 'แก้ว'),
('DRK003', '8850001000003', 'ชาเย็นนมสด', 'ชาเย็นผสมนมสดหอมมัน', 'เครื่องดื่ม', 15.00, 30.00, 40, 8, 'แก้ว'),
('DRK004', '8850001000004', 'ชาดำเย็น', 'ชาดำเย็นรสชาติเข้มข้น', 'เครื่องดื่ม', 11.00, 22.00, 45, 10, 'แก้ว'),
('DRK005', '8850001000005', 'กาแฟเย็น', 'กาแฟเย็นหอมกรุ่น', 'เครื่องดื่ม', 12.00, 25.00, 40, 8, 'แก้ว'),
('DRK006', '8850001000006', 'กาแฟร้อน', 'กาแฟร้อนเข้มข้น', 'เครื่องดื่ม', 10.00, 20.00, 40, 8, 'แก้ว'),
('DRK007', '8850001000007', 'โอเลี้ยง', 'เครื่องดื่มโอเลี้ยงเย็นๆ', 'เครื่องดื่ม', 8.00, 20.00, 30, 6, 'แก้ว'),
('DRK008', '8850001000008', 'นมเย็น', 'นมสดเย็นหอมมัน', 'เครื่องดื่ม', 8.00, 18.00, 35, 7, 'แก้ว'),
('DRK009', '8850001000009', 'ชาเขียวเย็น', 'ชาเขียวเย็นสดชื่น', 'เครื่องดื่ม', 12.00, 25.00, 30, 6, 'แก้ว'),
('DRK010', '8850001000010', 'ชาอูหลงเย็น', 'ชาอูหลงเย็นหอมกรุ่น', 'เครื่องดื่ม', 15.00, 30.00, 25, 5, 'แก้ว'),

-- ขนม
('SNK001', '8850002000001', 'ขนมปังปิ้ง', 'ขนมปังปิ้งเนยนม หวานหอม', 'ขนม', 8.00, 15.00, 100, 20, 'ชิ้น'),
('SNK002', '8850002000002', 'ขนมปังปิ้งช็อกโกแลต', 'ขนมปังปิ้งหน้าช็อกโกแลต', 'ขนม', 10.00, 18.00, 80, 15, 'ชิ้น'),
('SNK003', '8850002000003', 'โรตี', 'โรตีหวานเนยนม', 'ขนม', 10.00, 20.00, 60, 12, 'ชิ้น'),
('SNK004', '8850002000004', 'โรตีกล้วย', 'โรตีกล้วยหอมหวาน', 'ขนม', 13.00, 25.00, 50, 10, 'ชิ้น'),
('SNK005', '8850002000005', 'ขนมครก', 'ขนมครกแบบโบราณ', 'ขนม', 6.00, 12.00, 80, 15, 'ชิ้น'),
('SNK006', '8850002000006', 'ทองหยิบ', 'ทองหยิบขนมไทยโบราณ', 'ขนม', 8.00, 15.00, 60, 12, 'ชิ้น'),
('SNK007', '8850002000007', 'คุกกี้', 'คุกกี้เนยสดหอมกรุ่น', 'ขนม', 5.00, 10.00, 100, 20, 'ชิ้น'),
('SNK008', '8850002000008', 'มาการอง', 'มาการองหวานหอม', 'ขนม', 4.00, 8.00, 120, 25, 'ชิ้น'),
('SNK009', '8850002000009', 'เค้กช็อกโกแลต', 'เค้กช็อกโกแลตชิ้นเล็ก', 'ขนม', 12.00, 25.00, 40, 8, 'ชิ้น'),
('SNK010', '8850002000010', 'บราวนี่', 'บราวนี่ช็อกโกแลตเข้มข้น', 'ขนม', 11.00, 22.00, 50, 10, 'ชิ้น'),

-- Topping
('TOP001', '8850003000001', 'ไข่มุกดำ', 'ไข่มุกดำเหนียวนุ่ม', 'Topping', 5.00, 10.00, 200, 40, 'ช้อน'),
('TOP002', '8850003000002', 'ไข่มุกใส', 'ไข่มุกใสเหนียวนุ่ม', 'Topping', 5.00, 10.00, 200, 40, 'ช้อน'),
('TOP003', '8850003000003', 'วุ้นกาแฟ', 'วุ้นกาแฟหอมกรุ่น', 'Topping', 4.00, 8.00, 150, 30, 'ช้อน'),
('TOP004', '8850003000004', 'วุ้นชาเขียว', 'วุ้นชาเขียวหอมมัน', 'Topping', 4.00, 8.00, 150, 30, 'ช้อน'),
('TOP005', '8850003000005', 'บุบเบิ้ล', 'บุบเบิ้ลเหนียวนุ่ม', 'Topping', 6.00, 12.00, 100, 20, 'ช้อน'),
('TOP006', '8850003000006', 'พุดดิ้ง', 'พุดดิ้งหวานนุ่ม', 'Topping', 5.00, 10.00, 120, 25, 'ช้อน'),
('TOP007', '8850003000007', 'เจลลี่', 'เจลลี่หวานเหนียว', 'Topping', 4.00, 8.00, 150, 30, 'ช้อน'),
('TOP008', '8850003000008', 'นาต้าเดอโคโค', 'นาต้าเดอโคโคเหนียวนุ่ม', 'Topping', 5.00, 10.00, 100, 20, 'ช้อน'),
('TOP009', '8850003000009', 'แครีมชีส', 'แครีมชีสหอมมัน', 'Topping', 8.00, 15.00, 80, 15, 'ช้อน'),
('TOP010', '8850003000010', 'วิปครีม', 'วิปครีมหวานนุ่ม', 'Topping', 6.00, 12.00, 100, 20, 'ช้อน');

-- Insert sample customers
INSERT INTO customers (customer_code, name, email, phone, address, membership_level) VALUES
('CUST0001', 'ลูกค้าทั่วไป', 'general@customer.com', '0801234567', 'ลูกค้าเดินผ่าน', 'Bronze'),
('CUST0002', 'คุณสมชาย รักชา', 'somchai.tea@email.com', '0812345678', '123 ถ.ตลาดใต้ ยะลา', 'Silver'),
('CUST0003', 'คุณสมหญิง หวานใจ', 'somying.sweet@email.com', '0823456789', '456 ถ.ชาไทย สงขลา', 'Gold'),
('CUST0004', 'คุณมานี ชอบขนม', 'manee.snack@email.com', '0834567890', '789 ถ.ขนมไทย ปัตตานี', 'Bronze');

-- Insert promotions
INSERT INTO promotions (code, name, type, value, min_amount, description, is_active) VALUES
('SAVE10PCT50', 'ลด 10% ซื้อครบ 50', 'percentage', 10, 50, 'ลด 10% เมื่อซื้อครบ 50 บาท', true),
('SAVE15FIX80', 'ลด 15 บาท', 'fixed', 15, 80, 'ลด 15 บาท เมื่อซื้อครบ 80 บาท', true),
('SAVE15PCT100', 'ลด 15% ซื้อครบ 100', 'percentage', 15, 100, 'ลด 15% เมื่อซื้อครบ 100 บาท', true),
('SAVE25FIX150', 'ลด 25 บาท', 'fixed', 25, 150, 'ลด 25 บาท เมื่อซื้อครบ 150 บาท', true),
('SAVE20PCT200', 'ลด 20% ซื้อครบ 200', 'percentage', 20, 200, 'ลด 20% เมื่อซื้อครบ 200 บาท', true),
('TEATHAI25', 'โปรชาไทยพิเศษ', 'percentage', 25, 300, 'ลด 25% สำหรับคนรักชาไทย', true),
('MEMBER5', 'ส่วนลดลูกค้าประจำ', 'percentage', 5, 0, 'ส่วนลด 5% สำหรับลูกค้าประจำ', true),
('SAVE50FIX400', 'ลด 50 บาท ซื้อครบ 400', 'fixed', 50, 400, 'ลด 50 บาท เมื่อซื้อครบ 400 บาท', true);

-- ==========================================
-- FUNCTIONS AND TRIGGERS
-- ==========================================

-- Function to update product profit calculations
CREATE OR REPLACE FUNCTION calculate_product_profit()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate profit for sale items
  NEW.profit_amount = (NEW.unit_price - COALESCE(NEW.cost_price, 0)) * NEW.quantity - NEW.discount_amount;
  
  IF NEW.unit_price > 0 THEN
    NEW.profit_percentage = ROUND((NEW.profit_amount / (NEW.unit_price * NEW.quantity) * 100)::numeric, 2);
  ELSE
    NEW.profit_percentage = 0;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for sale items profit calculation
CREATE TRIGGER trigger_calculate_profit
  BEFORE INSERT OR UPDATE ON sale_items
  FOR EACH ROW
  EXECUTE FUNCTION calculate_product_profit();

-- Function to generate sale number
CREATE OR REPLACE FUNCTION generate_sale_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sale_number IS NULL THEN
    NEW.sale_number = 'INV' || TO_CHAR(NEW.created_at, 'YYYYMMDD') || '-' || 
                      LPAD(EXTRACT(epoch FROM NEW.created_at)::TEXT, 6, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for sale number generation
CREATE TRIGGER trigger_generate_sale_number
  BEFORE INSERT ON sales
  FOR EACH ROW
  EXECUTE FUNCTION generate_sale_number();

-- Function to update inventory on sale
CREATE OR REPLACE FUNCTION update_inventory_on_sale()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert inventory movement for each sale item
  INSERT INTO inventory_movements (
    product_id, movement_type, quantity, quantity_before, quantity_after,
    reference_type, reference_id, reference_number, reason, cost_price
  )
  SELECT 
    NEW.product_id,
    'out',
    -NEW.quantity,
    p.stock_quantity,
    p.stock_quantity - NEW.quantity,
    'sale',
    NEW.sale_id,
    s.sale_number,
    'ขายสินค้า: ' || NEW.product_name,
    NEW.cost_price
  FROM products p, sales s
  WHERE p.id = NEW.product_id AND s.id = NEW.sale_id;
  
  -- Update product stock
  UPDATE products 
  SET stock_quantity = stock_quantity - NEW.quantity,
      updated_at = NOW()
  WHERE id = NEW.product_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for inventory update on sale
CREATE TRIGGER trigger_update_inventory
  AFTER INSERT ON sale_items
  FOR EACH ROW
  EXECUTE FUNCTION update_inventory_on_sale();

-- Function to update customer statistics
CREATE OR REPLACE FUNCTION update_customer_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.customer_id IS NOT NULL THEN
    UPDATE customers SET
      total_purchases = total_purchases + 1,
      total_spent = total_spent + NEW.total_amount,
      last_purchase_date = NEW.created_at,
      updated_at = NOW()
    WHERE id = NEW.customer_id;
    
    -- Update average order value
    UPDATE customers SET
      average_order_value = total_spent / GREATEST(total_purchases, 1)
    WHERE id = NEW.customer_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for customer statistics
CREATE TRIGGER trigger_update_customer_stats
  AFTER INSERT ON sales
  FOR EACH ROW
  EXECUTE FUNCTION update_customer_stats();

-- ==========================================
-- REPORTING VIEWS
-- ==========================================

-- Daily Sales Report
CREATE OR REPLACE VIEW daily_sales_report AS
SELECT 
  sale_date,
  COUNT(*) as total_transactions,
  SUM(total_amount) as total_revenue,
  SUM(subtotal) as total_subtotal,
  SUM(discount_amount) as total_discount,
  SUM(tax_amount) as total_tax,
  AVG(total_amount) as average_transaction,
  SUM(CASE WHEN payment_method = 'cash' THEN total_amount ELSE 0 END) as cash_sales,
  SUM(CASE WHEN payment_method = 'card' THEN total_amount ELSE 0 END) as card_sales,
  SUM(CASE WHEN payment_method = 'qr' THEN total_amount ELSE 0 END) as qr_sales
FROM sales 
WHERE status = 'completed'
GROUP BY sale_date
ORDER BY sale_date DESC;

-- Weekly Sales Report
CREATE OR REPLACE VIEW weekly_sales_report AS
SELECT 
  DATE_TRUNC('week', sale_date) as week_start,
  DATE_TRUNC('week', sale_date) + INTERVAL '6 days' as week_end,
  COUNT(*) as total_transactions,
  SUM(total_amount) as total_revenue,
  AVG(total_amount) as average_transaction,
  SUM(si.profit_amount) as total_profit
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
WHERE s.status = 'completed'
GROUP BY DATE_TRUNC('week', sale_date)
ORDER BY week_start DESC;

-- Monthly Sales Report
CREATE OR REPLACE VIEW monthly_sales_report AS
SELECT 
  DATE_TRUNC('month', sale_date) as month_start,
  EXTRACT(YEAR FROM sale_date) as year,
  EXTRACT(MONTH FROM sale_date) as month,
  COUNT(*) as total_transactions,
  SUM(total_amount) as total_revenue,
  AVG(total_amount) as average_transaction,
  SUM(si.profit_amount) as total_profit,
  COUNT(DISTINCT customer_id) as unique_customers
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
WHERE s.status = 'completed'
GROUP BY DATE_TRUNC('month', sale_date), EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
ORDER BY year DESC, month DESC;

-- Product Performance View
CREATE OR REPLACE VIEW product_performance AS
SELECT 
  p.id,
  p.sku,
  p.name,
  p.category,
  p.selling_price,
  p.cost_price,
  p.stock_quantity,
  COALESCE(SUM(si.quantity), 0) as total_sold,
  COALESCE(SUM(si.total_price), 0) as total_revenue,
  COALESCE(SUM(si.profit_amount), 0) as total_profit,
  COALESCE(AVG(si.profit_percentage), 0) as avg_profit_percentage,
  COUNT(DISTINCT si.sale_id) as times_sold,
  p.selling_price - p.cost_price as unit_profit
FROM products p
LEFT JOIN sale_items si ON p.id = si.product_id
LEFT JOIN sales s ON si.sale_id = s.id AND s.status = 'completed'
WHERE p.is_active = true
GROUP BY p.id, p.sku, p.name, p.category, p.selling_price, p.cost_price, p.stock_quantity
ORDER BY total_sold DESC;

-- Category Performance View
CREATE OR REPLACE VIEW category_performance AS
SELECT 
  p.category,
  COUNT(*) as product_count,
  SUM(p.stock_quantity) as total_stock,
  COALESCE(SUM(perf.total_sold), 0) as total_sold,
  COALESCE(SUM(perf.total_revenue), 0) as total_revenue,
  COALESCE(SUM(perf.total_profit), 0) as total_profit,
  COALESCE(AVG(perf.avg_profit_percentage), 0) as avg_profit_percentage
FROM products p
LEFT JOIN product_performance perf ON p.id = perf.id
WHERE p.is_active = true
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Low Stock Alert View
CREATE OR REPLACE VIEW low_stock_alert AS
SELECT 
  p.id,
  p.sku,
  p.name,
  p.category,
  p.stock_quantity,
  p.min_stock_level,
  (p.min_stock_level - p.stock_quantity) as shortage,
  p.selling_price,
  p.cost_price,
  CASE 
    WHEN p.stock_quantity <= 0 THEN 'หมด'
    WHEN p.stock_quantity <= p.min_stock_level THEN 'ใกล้หมด'
    ELSE 'ปกติ'
  END as stock_status
FROM products p
WHERE p.is_active = true 
  AND p.is_trackable = true
  AND p.stock_quantity <= p.min_stock_level
ORDER BY shortage DESC;

-- Top Selling Products View
CREATE OR REPLACE VIEW top_selling_products AS
SELECT 
  pp.*,
  RANK() OVER (ORDER BY pp.total_sold DESC) as sales_rank,
  RANK() OVER (ORDER BY pp.total_revenue DESC) as revenue_rank,
  RANK() OVER (ORDER BY pp.total_profit DESC) as profit_rank
FROM product_performance pp
WHERE pp.total_sold > 0
ORDER BY pp.total_sold DESC
LIMIT 20;

-- Customer Analysis View
CREATE OR REPLACE VIEW customer_analysis AS
SELECT 
  c.*,
  CASE 
    WHEN c.total_spent >= 10000 THEN 'VIP'
    WHEN c.total_spent >= 5000 THEN 'Gold'
    WHEN c.total_spent >= 1000 THEN 'Silver'
    ELSE 'Bronze'
  END as suggested_membership,
  DATE_PART('day', NOW() - c.last_purchase_date) as days_since_last_purchase,
  CASE 
    WHEN c.last_purchase_date IS NULL THEN 'ไม่เคยซื้อ'
    WHEN DATE_PART('day', NOW() - c.last_purchase_date) <= 7 THEN 'ลูกค้าใหม่'
    WHEN DATE_PART('day', NOW() - c.last_purchase_date) <= 30 THEN 'ลูกค้าประจำ'
    WHEN DATE_PART('day', NOW() - c.last_purchase_date) <= 90 THEN 'ลูกค้าเก่า'
    ELSE 'ลูกค้าสูญหาย'
  END as customer_segment
FROM customers c
WHERE c.is_active = true
ORDER BY c.total_spent DESC;

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================

-- Function to get sales summary between dates
CREATE OR REPLACE FUNCTION get_sales_summary(start_date DATE, end_date DATE)
RETURNS TABLE(
  total_transactions BIGINT,
  total_revenue DECIMAL(15,2),
  total_profit DECIMAL(15,2),
  average_transaction DECIMAL(12,2),
  total_customers BIGINT,
  top_category VARCHAR(255),
  top_product VARCHAR(255)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(s.id) as total_transactions,
    COALESCE(SUM(s.total_amount), 0) as total_revenue,
    COALESCE(SUM(si.profit_amount), 0) as total_profit,
    COALESCE(AVG(s.total_amount), 0) as average_transaction,
    COUNT(DISTINCT s.customer_id) as total_customers,
    (SELECT category FROM sale_items si2 
     INNER JOIN sales s2 ON si2.sale_id = s2.id 
     WHERE s2.sale_date BETWEEN start_date AND end_date AND s2.status = 'completed'
     GROUP BY category ORDER BY SUM(si2.quantity) DESC LIMIT 1) as top_category,
    (SELECT product_name FROM sale_items si3 
     INNER JOIN sales s3 ON si3.sale_id = s3.id 
     WHERE s3.sale_date BETWEEN start_date AND end_date AND s3.status = 'completed'
     GROUP BY product_name ORDER BY SUM(si3.quantity) DESC LIMIT 1) as top_product
  FROM sales s
  LEFT JOIN sale_items si ON s.id = si.sale_id
  WHERE s.sale_date BETWEEN start_date AND end_date 
    AND s.status = 'completed';
END;
$$ LANGUAGE plpgsql;

-- Success message
SELECT 'POS CHAMA Complete Analytics System initialized successfully! 📊🍵' AS message;
SELECT 'Total tables created: ' || COUNT(*) AS tables_count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

SELECT 'Total views created: ' || COUNT(*) AS views_count 
FROM information_schema.views 
WHERE table_schema = 'public';

-- Sample usage of sales summary
SELECT 'Sample sales summary for last 30 days:' as info;
SELECT * FROM get_sales_summary((CURRENT_DATE - INTERVAL '30 days')::DATE, CURRENT_DATE::DATE);
