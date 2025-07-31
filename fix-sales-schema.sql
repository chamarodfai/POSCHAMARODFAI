-- Fix sales table to add sale_number and handle unique constraints properly
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS sale_number VARCHAR(50) UNIQUE;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_sales_sale_number ON sales(sale_number);
CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON sales(sale_date);

-- Update existing sales to have sale_numbers if they don't have them
DO $$
DECLARE
    rec RECORD;
    counter INTEGER := 1;
BEGIN
    FOR rec IN SELECT id, created_at FROM sales WHERE sale_number IS NULL ORDER BY created_at LOOP
        UPDATE sales 
        SET sale_number = 'SL' || EXTRACT(EPOCH FROM rec.created_at)::bigint || LPAD(counter::text, 3, '0')
        WHERE id = rec.id;
        counter := counter + 1;
    END LOOP;
END $$;

-- Make sale_number required after updating existing records
ALTER TABLE sales 
ALTER COLUMN sale_number SET NOT NULL;

-- Fix any potential issues with the products table constraints
-- Make sure barcode and sku can be null but unique when not null
ALTER TABLE products 
DROP CONSTRAINT IF EXISTS products_barcode_key;

ALTER TABLE products 
DROP CONSTRAINT IF EXISTS products_sku_key;

-- Add unique constraints that allow nulls
CREATE UNIQUE INDEX IF NOT EXISTS unique_products_barcode 
ON products (barcode) 
WHERE barcode IS NOT NULL AND barcode != '';

CREATE UNIQUE INDEX IF NOT EXISTS unique_products_sku 
ON products (sku) 
WHERE sku IS NOT NULL AND sku != '';

-- Clean up any duplicate or empty barcodes/SKUs
UPDATE products 
SET barcode = NULL 
WHERE barcode = '';

UPDATE products 
SET sku = NULL 
WHERE sku = '';

-- Fix any duplicate barcodes by making them unique
DO $$
DECLARE
    rec RECORD;
    counter INTEGER;
BEGIN
    FOR rec IN 
        SELECT barcode, array_agg(id ORDER BY created_at) as product_ids
        FROM products 
        WHERE barcode IS NOT NULL AND barcode != ''
        GROUP BY barcode 
        HAVING COUNT(*) > 1
    LOOP
        counter := 2;
        FOR i IN 2..array_length(rec.product_ids, 1) LOOP
            UPDATE products 
            SET barcode = rec.barcode || '_' || counter::text
            WHERE id = rec.product_ids[i];
            counter := counter + 1;
        END LOOP;
    END LOOP;
END $$;

-- Fix any duplicate SKUs by making them unique
DO $$
DECLARE
    rec RECORD;
    counter INTEGER;
BEGIN
    FOR rec IN 
        SELECT sku, array_agg(id ORDER BY created_at) as product_ids
        FROM products 
        WHERE sku IS NOT NULL AND sku != ''
        GROUP BY sku 
        HAVING COUNT(*) > 1
    LOOP
        counter := 2;
        FOR i IN 2..array_length(rec.product_ids, 1) LOOP
            UPDATE products 
            SET sku = rec.sku || '_' || counter::text
            WHERE id = rec.product_ids[i];
            counter := counter + 1;
        END LOOP;
    END LOOP;
END $$;
