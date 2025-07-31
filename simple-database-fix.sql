-- Simple database fix without function dependencies
-- Run this in Supabase SQL Editor

-- 1. Add missing columns if they don't exist
ALTER TABLE sale_items 
ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0;

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS promotion_id UUID;

-- 2. Fix null values that cause checkout errors
UPDATE sales 
SET discount_amount = 0 
WHERE discount_amount IS NULL;

UPDATE sales 
SET status = 'completed' 
WHERE status IS NULL;

UPDATE products 
SET stock_quantity = 0 
WHERE stock_quantity IS NULL;

-- 3. Clean up orphaned data safely
DELETE FROM sale_items 
WHERE sale_id IS NOT NULL 
AND sale_id NOT IN (SELECT id FROM sales);

DELETE FROM sale_items 
WHERE product_id IS NOT NULL 
AND product_id NOT IN (SELECT id FROM products);

-- 4. Add basic indexes for performance
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id);

-- 5. Ensure foreign key constraints exist (without dropping)
DO $$
BEGIN
    -- Add foreign key for sale_items -> sales if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'sale_items_sale_id_fkey'
    ) THEN
        ALTER TABLE sale_items 
        ADD CONSTRAINT sale_items_sale_id_fkey 
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE;
    END IF;

    -- Add foreign key for sale_items -> products if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'sale_items_product_id_fkey'
    ) THEN
        ALTER TABLE sale_items 
        ADD CONSTRAINT sale_items_product_id_fkey 
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
    END IF;
END $$;

COMMIT;
