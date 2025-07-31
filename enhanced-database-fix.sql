-- Enhanced database fix with product names in sales table
-- Run this in Supabase SQL Editor

-- 1. Add missing columns if they don't exist
ALTER TABLE sale_items 
ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) DEFAULT 0;

ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS promotion_id UUID;

-- 2. Add product names column to sales table
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS product_names TEXT;

-- 3. Fix null values that cause checkout errors
UPDATE sales 
SET discount_amount = 0 
WHERE discount_amount IS NULL;

UPDATE sales 
SET status = 'completed' 
WHERE status IS NULL;

UPDATE products 
SET stock_quantity = 0 
WHERE stock_quantity IS NULL;

-- 4. Update product_name in sale_items from products table
UPDATE sale_items 
SET product_name = p.name
FROM products p
WHERE sale_items.product_id = p.id 
AND (sale_items.product_name IS NULL OR sale_items.product_name = '');

-- 5. Update product_names in sales table with concatenated product names
UPDATE sales 
SET product_names = (
    SELECT STRING_AGG(
        CASE 
            WHEN si.product_name IS NOT NULL AND si.product_name != '' 
            THEN si.product_name || ' (x' || si.quantity || ')'
            ELSE p.name || ' (x' || si.quantity || ')'
        END, 
        ', ' 
        ORDER BY si.id
    )
    FROM sale_items si
    LEFT JOIN products p ON si.product_id = p.id
    WHERE si.sale_id = sales.id
)
WHERE sales.product_names IS NULL OR sales.product_names = '';

-- 6. Clean up orphaned data safely
DELETE FROM sale_items 
WHERE sale_id IS NOT NULL 
AND sale_id NOT IN (SELECT id FROM sales);

DELETE FROM sale_items 
WHERE product_id IS NOT NULL 
AND product_id NOT IN (SELECT id FROM products);

-- 7. Add basic indexes for performance
CREATE INDEX IF NOT EXISTS idx_sales_status ON sales(status);
CREATE INDEX IF NOT EXISTS idx_sales_product_names ON sales(product_names);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON sale_items(product_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_name ON sale_items(product_name);

-- 8. Ensure foreign key constraints exist (without dropping)
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

-- 9. Create function to automatically update product_names when sale_items change
CREATE OR REPLACE FUNCTION update_sales_product_names()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the sales record with concatenated product names
    UPDATE sales 
    SET product_names = (
        SELECT STRING_AGG(
            CASE 
                WHEN si.product_name IS NOT NULL AND si.product_name != '' 
                THEN si.product_name || ' (x' || si.quantity || ')'
                ELSE p.name || ' (x' || si.quantity || ')'
            END, 
            ', ' 
            ORDER BY si.id
        )
        FROM sale_items si
        LEFT JOIN products p ON si.product_id = p.id
        WHERE si.sale_id = COALESCE(NEW.sale_id, OLD.sale_id)
    )
    WHERE sales.id = COALESCE(NEW.sale_id, OLD.sale_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 10. Create triggers to automatically update product_names
DROP TRIGGER IF EXISTS trigger_update_sales_product_names_insert ON sale_items;
DROP TRIGGER IF EXISTS trigger_update_sales_product_names_update ON sale_items;
DROP TRIGGER IF EXISTS trigger_update_sales_product_names_delete ON sale_items;

CREATE TRIGGER trigger_update_sales_product_names_insert
    AFTER INSERT ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION update_sales_product_names();

CREATE TRIGGER trigger_update_sales_product_names_update
    AFTER UPDATE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION update_sales_product_names();

CREATE TRIGGER trigger_update_sales_product_names_delete
    AFTER DELETE ON sale_items
    FOR EACH ROW
    EXECUTE FUNCTION update_sales_product_names();

COMMIT;
