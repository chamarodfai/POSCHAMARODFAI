-- Emergency fix for sales system errors
-- Run this in Supabase SQL Editor

-- 1. Fix sale_items table to ensure it has product_name column
ALTER TABLE sale_items 
ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);

-- 2. Check and fix foreign key constraints
-- Drop and recreate foreign key constraints with proper error handling
ALTER TABLE sale_items 
DROP CONSTRAINT IF EXISTS sale_items_sale_id_fkey;

ALTER TABLE sale_items 
DROP CONSTRAINT IF EXISTS sale_items_product_id_fkey;

-- Recreate foreign keys with CASCADE options
ALTER TABLE sale_items 
ADD CONSTRAINT sale_items_sale_id_fkey 
FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE;

ALTER TABLE sale_items 
ADD CONSTRAINT sale_items_product_id_fkey 
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;

-- 3. Ensure sales table has all required columns
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS sale_number VARCHAR(50) UNIQUE;

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0;

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS promotion_id UUID;

-- 4. Clean up any orphaned data
DELETE FROM sale_items 
WHERE sale_id NOT IN (SELECT id FROM sales);

DELETE FROM sale_items 
WHERE product_id NOT IN (SELECT id FROM products);

-- 5. Update any null values that might cause issues
UPDATE sales 
SET discount_amount = 0 
WHERE discount_amount IS NULL;

UPDATE sales 
SET status = 'completed' 
WHERE status IS NULL;

-- 6. Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sales_sale_number ON sales(sale_number);
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id);

-- 7. Ensure products table constraints are proper
UPDATE products 
SET stock_quantity = 0 
WHERE stock_quantity IS NULL;

-- 8. Create a function to generate sale numbers safely
-- Drop existing function first if it exists
DROP FUNCTION IF EXISTS generate_sale_number();

CREATE OR REPLACE FUNCTION generate_sale_number()
RETURNS VARCHAR(50) AS $$
DECLARE
    new_number VARCHAR(50);
    counter INTEGER := 0;
BEGIN
    LOOP
        new_number := 'SL' || EXTRACT(EPOCH FROM NOW())::bigint || LPAD(counter::text, 3, '0');
        
        -- Check if this number already exists
        IF NOT EXISTS (SELECT 1 FROM sales WHERE sale_number = new_number) THEN
            RETURN new_number;
        END IF;
        
        counter := counter + 1;
        
        -- Prevent infinite loop
        IF counter > 999 THEN
            new_number := 'SL' || EXTRACT(EPOCH FROM NOW())::bigint || random()::text;
            EXIT;
        END IF;
    END LOOP;
    
    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- 9. Update existing sales without sale_number
UPDATE sales 
SET sale_number = generate_sale_number()
WHERE sale_number IS NULL;

-- 10. Make sale_number required
ALTER TABLE sales 
ALTER COLUMN sale_number SET NOT NULL;

COMMIT;
