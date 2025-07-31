-- ==========================================
-- แก้ไขปัญหาคอลัมน์ selling_price ในตาราง products
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

-- แก้ไขปัญหา selling_price constraint
DO $$
BEGIN
    -- ถ้ามีคอลัมน์ selling_price แต่เป็น NOT NULL ให้เปลี่ยนเป็น nullable ก่อน
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'selling_price' AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE products ALTER COLUMN selling_price DROP NOT NULL;
        RAISE NOTICE 'Removed NOT NULL constraint from selling_price';
    END IF;
    
    -- เพิ่มคอลัมน์ selling_price ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'selling_price'
    ) THEN
        ALTER TABLE products ADD COLUMN selling_price DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Added selling_price column';
    ELSE
        RAISE NOTICE 'selling_price column already exists';
    END IF;
    
    -- เพิ่มคอลัมน์อื่นๆ ที่จำเป็น
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'cost_price'
    ) THEN
        ALTER TABLE products ADD COLUMN cost_price DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Added cost_price column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'sku'
    ) THEN
        ALTER TABLE products ADD COLUMN sku VARCHAR(100);
        RAISE NOTICE 'Added sku column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'barcode'
    ) THEN
        ALTER TABLE products ADD COLUMN barcode VARCHAR(100);
        RAISE NOTICE 'Added barcode column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'unit'
    ) THEN
        ALTER TABLE products ADD COLUMN unit VARCHAR(50) DEFAULT 'ชิ้น';
        RAISE NOTICE 'Added unit column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'min_stock_level'
    ) THEN
        ALTER TABLE products ADD COLUMN min_stock_level INTEGER DEFAULT 5;
        RAISE NOTICE 'Added min_stock_level column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE products ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_active column';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'image_url'
    ) THEN
        ALTER TABLE products ADD COLUMN image_url TEXT;
        RAISE NOTICE 'Added image_url column';
    END IF;
    
    -- เพิ่ม stock_quantity ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'stock_quantity'
    ) THEN
        ALTER TABLE products ADD COLUMN stock_quantity INTEGER DEFAULT 0;
        RAISE NOTICE 'Added stock_quantity column';
    END IF;
    
    RAISE NOTICE '=== Table structure update completed ===';
END
$$;

-- อัพเดทข้อมูลให้มี default values
UPDATE products 
SET 
    selling_price = COALESCE(selling_price, 100),
    cost_price = COALESCE(cost_price, selling_price * 0.6, 60),
    sku = COALESCE(sku, 'PRD' || LPAD(id::text, 3, '0')),
    unit = COALESCE(unit, 'ชิ้น'),
    min_stock_level = COALESCE(min_stock_level, 5),
    is_active = COALESCE(is_active, true),
    stock_quantity = COALESCE(stock_quantity, 10)
WHERE selling_price IS NULL OR selling_price = 0 OR sku IS NULL OR sku = '';

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
    selling_price,
    cost_price,
    sku,
    category,
    stock_quantity,
    unit,
    is_active
FROM products 
LIMIT 3;

-- Success message
SELECT '✅ แก้ไข selling_price เรียบร้อยแล้ว - ลองเพิ่มสินค้าใหม่ได้เลย!' AS message;
