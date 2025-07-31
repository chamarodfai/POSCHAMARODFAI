-- ==========================================
-- เพิ่มคอลัมน์ที่จำเป็นสำหรับตาราง products
-- ==========================================

-- ตรวจสอบโครงสร้างตารางปัจจุบัน
SELECT 
    'โครงสร้างตารางปัจจุบัน' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'products' 
ORDER BY ordinal_position;

-- เพิ่มคอลัมน์ที่ขาดหายไป
DO $$
BEGIN
    -- เพิ่ม price column (ราคาขาย)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'price'
    ) THEN
        ALTER TABLE products ADD COLUMN price DECIMAL(12,2) NOT NULL DEFAULT 0;
        RAISE NOTICE 'Added price column';
    ELSE
        RAISE NOTICE 'price column already exists';
    END IF;
    
    -- เพิ่ม cost_price column (ราคาต้นทุน)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'cost_price'
    ) THEN
        ALTER TABLE products ADD COLUMN cost_price DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Added cost_price column';
    ELSE
        RAISE NOTICE 'cost_price column already exists';
    END IF;
    
    -- เพิ่ม sku column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'sku'
    ) THEN
        ALTER TABLE products ADD COLUMN sku VARCHAR(100);
        RAISE NOTICE 'Added sku column';
    ELSE
        RAISE NOTICE 'sku column already exists';
    END IF;
    
    -- เพิ่ม barcode column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'barcode'
    ) THEN
        ALTER TABLE products ADD COLUMN barcode VARCHAR(100);
        RAISE NOTICE 'Added barcode column';
    ELSE
        RAISE NOTICE 'barcode column already exists';
    END IF;
    
    -- เพิ่ม unit column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'unit'
    ) THEN
        ALTER TABLE products ADD COLUMN unit VARCHAR(50) DEFAULT 'ชิ้น';
        RAISE NOTICE 'Added unit column';
    ELSE
        RAISE NOTICE 'unit column already exists';
    END IF;
    
    -- เพิ่ม min_stock_level column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'min_stock_level'
    ) THEN
        ALTER TABLE products ADD COLUMN min_stock_level INTEGER DEFAULT 5;
        RAISE NOTICE 'Added min_stock_level column';
    ELSE
        RAISE NOTICE 'min_stock_level column already exists';
    END IF;
    
    -- เพิ่ม is_active column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE products ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_active column';
    ELSE
        RAISE NOTICE 'is_active column already exists';
    END IF;
    
    -- เพิ่ม image_url column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'image_url'
    ) THEN
        ALTER TABLE products ADD COLUMN image_url TEXT;
        RAISE NOTICE 'Added image_url column';
    ELSE
        RAISE NOTICE 'image_url column already exists';
    END IF;
    
    -- แก้ไขชื่อคอลัมน์ stock เป็น stock_quantity ถ้าจำเป็น
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'stock'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'stock_quantity'
    ) THEN
        ALTER TABLE products RENAME COLUMN stock TO stock_quantity;
        RAISE NOTICE 'Renamed stock to stock_quantity';
    END IF;
    
    -- เพิ่ม stock_quantity ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'stock_quantity'
    ) THEN
        ALTER TABLE products ADD COLUMN stock_quantity INTEGER DEFAULT 0;
        RAISE NOTICE 'Added stock_quantity column';
    ELSE
        RAISE NOTICE 'stock_quantity column already exists';
    END IF;
    
    RAISE NOTICE '=== Table structure update completed ===';
END
$$;

-- อัพเดทข้อมูลเดิมให้มี default values
UPDATE products 
SET 
    price = COALESCE(price, 100),
    cost_price = COALESCE(cost_price, price * 0.6, 60),
    sku = COALESCE(sku, 'PRD' || LPAD(id::text, 3, '0')),
    unit = COALESCE(unit, 'ชิ้น'),
    min_stock_level = COALESCE(min_stock_level, 5),
    is_active = COALESCE(is_active, true),
    stock_quantity = COALESCE(stock_quantity, 10)
WHERE price IS NULL OR price = 0 OR sku IS NULL OR sku = '';

-- แสดงโครงสร้างตารางหลังอัพเดท
SELECT 
    'โครงสร้างตารางหลังอัพเดท' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'products' 
ORDER BY ordinal_position;

-- แสดงตัวอย่างข้อมูล
SELECT 
    'ตัวอย่างข้อมูลในตาราง' as info,
    id,
    name,
    price,
    cost_price,
    sku,
    category,
    stock_quantity,
    unit,
    is_active
FROM products 
LIMIT 3;

-- Success message
SELECT '✅ อัพเดทโครงสร้างตารางเรียบร้อยแล้ว - ลองเพิ่มสินค้าใหม่ได้เลย!' AS message;
