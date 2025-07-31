-- Simple emergency fix for sales system errors
-- Run this in Supabase SQL Editor (Part 1)

-- 1. Fix sale_items table to ensure it has product_name column
ALTER TABLE sale_items 
ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);

-- 2. Ensure sales table has all required columns
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS sale_number VARCHAR(50);

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0;

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS promotion_id UUID;

-- 3. Update any null values that might cause issues
UPDATE sales 
SET discount_amount = 0 
WHERE discount_amount IS NULL;

UPDATE sales 
SET status = 'completed' 
WHERE status IS NULL;

-- 4. Ensure products table constraints are proper
UPDATE products 
SET stock_quantity = 0 
WHERE stock_quantity IS NULL;

-- 5. Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sales_sale_number ON sales(sale_number);
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id);

-- 6. Update existing sales without sale_number (simple approach)
UPDATE sales 
SET sale_number = 'SL' || id || '_' || EXTRACT(EPOCH FROM created_at)::bigint
WHERE sale_number IS NULL OR sale_number = '';

COMMIT;
