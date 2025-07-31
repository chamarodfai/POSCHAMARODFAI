-- Ultra Simple Test SQL
-- Just create basic tables for testing

-- Create products table only
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  category TEXT NOT NULL,
  stock_quantity INTEGER DEFAULT 0
);

-- Insert one test product
INSERT INTO products (name, price, category, stock_quantity) VALUES
('ชาไทยเย็น', 25.00, 'เครื่องดื่ม', 10);

-- Test query
SELECT * FROM products;
