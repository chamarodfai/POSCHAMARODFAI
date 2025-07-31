-- Fix sales table to add sale_number and handle unique constraints properly
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS sale_number VARCHAR(50) UNIQUE;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_sales_sale_number ON sales(sale_number);
CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON sales(sale_date);

-- Update existing sales to have sale_numbers if they don't have them
UPDATE sales 
SET sale_number = 'SL' || EXTRACT(EPOCH FROM created_at)::bigint || LPAD((ROW_NUMBER() OVER (ORDER BY created_at))::text, 3, '0')
WHERE sale_number IS NULL;

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
WITH duplicates AS (
    SELECT barcode, 
           ROW_NUMBER() OVER (PARTITION BY barcode ORDER BY created_at) as rn
    FROM products 
    WHERE barcode IS NOT NULL 
    AND barcode != ''
)
UPDATE products 
SET barcode = products.barcode || '_' || duplicates.rn
FROM duplicates 
WHERE products.barcode = duplicates.barcode 
AND duplicates.rn > 1;

-- Fix any duplicate SKUs by making them unique
WITH sku_duplicates AS (
    SELECT sku, 
           ROW_NUMBER() OVER (PARTITION BY sku ORDER BY created_at) as rn
    FROM products 
    WHERE sku IS NOT NULL 
    AND sku != ''
)
UPDATE products 
SET sku = products.sku || '_' || sku_duplicates.rn
FROM sku_duplicates 
WHERE products.sku = sku_duplicates.sku 
AND sku_duplicates.rn > 1;
