-- ==========================================
-- อัพเดทฐานข้อมูลที่มีอยู่แล้ว
-- เพิ่มฟิลด์ใหม่โดยไม่ลบข้อมูลเดิม
-- ==========================================

-- ตรวจสอบว่าตาราง products มีอยู่หรือไม่
DO $$
BEGIN
    -- เพิ่มคอลัมน์ใหม่ในตาราง products ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'sku'
    ) THEN
        ALTER TABLE products ADD COLUMN sku VARCHAR(100) UNIQUE;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'barcode'
    ) THEN
        ALTER TABLE products ADD COLUMN barcode VARCHAR(100) UNIQUE;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'cost_price'
    ) THEN
        ALTER TABLE products ADD COLUMN cost_price DECIMAL(12,2) DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'unit'
    ) THEN
        ALTER TABLE products ADD COLUMN unit VARCHAR(50) DEFAULT 'ชิ้น';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'min_stock_level'
    ) THEN
        ALTER TABLE products ADD COLUMN min_stock_level INTEGER DEFAULT 5;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE products ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
    
    -- แก้ไขชื่อคอลัมน์ถ้าจำเป็น
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'stock'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'stock_quantity'
    ) THEN
        ALTER TABLE products RENAME COLUMN stock TO stock_quantity;
    END IF;
    
    RAISE NOTICE 'Products table updated successfully';
END
$$;

-- ตรวจสอบโครงสร้างตาราง products ก่อน
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'products' 
ORDER BY ordinal_position;

-- อัพเดทข้อมูลเดิมให้มี cost_price (ตรวจสอบชื่อคอลัมน์ก่อน)
DO $$
BEGIN
    -- ถ้ามีคอลัมน์ price ให้อัพเดท cost_price
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'price'
    ) THEN
        UPDATE products 
        SET cost_price = price * 0.6 
        WHERE cost_price = 0 OR cost_price IS NULL;
        RAISE NOTICE 'Updated cost_price from price column';
    -- ถ้าไม่มีคอลัมน์ price แต่มี sell_price
    ELSIF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'sell_price'
    ) THEN
        UPDATE products 
        SET cost_price = sell_price * 0.6 
        WHERE cost_price = 0 OR cost_price IS NULL;
        RAISE NOTICE 'Updated cost_price from sell_price column';
    ELSE
        RAISE NOTICE 'No price column found, cost_price will remain 0';
    END IF;
END
$$;

-- อัพเดทข้อมูลเดิมให้มี SKU
UPDATE products 
SET sku = 'PRD' || LPAD(id::text, 3, '0')
WHERE sku IS NULL OR sku = '';

-- แสดงข้อมูลสินค้าปัจจุบัน (ใช้ชื่อคอลัมน์ที่มีจริง)
SELECT 
    id,
    name,
    COALESCE(sku, 'ไม่มี') as sku,
    category,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'price') 
        THEN price::text
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'sell_price') 
        THEN sell_price::text
        ELSE 'ไม่มีราคา'
    END as selling_price,
    COALESCE(cost_price, 0) as cost_price,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'stock_quantity') 
        THEN stock_quantity::text
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'stock') 
        THEN stock::text
        ELSE '0'
    END as stock_qty,
    COALESCE(is_active, true) as is_active
FROM products 
LIMIT 10;

-- Success message
SELECT 'ฐานข้อมูลได้รับการอัพเดทเรียบร้อยแล้ว! ✅' AS message;
