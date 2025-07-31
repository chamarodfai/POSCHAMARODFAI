-- ==========================================
-- ตรวจสอบและปรับปรุงตาราง products อย่างง่าย
-- ==========================================

-- 1. ตรวจสอบโครงสร้างตาราง products ปัจจุบัน
SELECT 
    'ตรวจสอบโครงสร้างตาราง products' as step,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'products' 
ORDER BY ordinal_position;

-- 2. เพิ่มคอลัมน์ที่จำเป็นอย่างปลอดภัย
DO $$
BEGIN
    -- เพิ่ม sku ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'sku'
    ) THEN
        ALTER TABLE products ADD COLUMN sku VARCHAR(100);
        RAISE NOTICE 'Added sku column';
    ELSE
        RAISE NOTICE 'sku column already exists';
    END IF;
    
    -- เพิ่ม barcode ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'barcode'
    ) THEN
        ALTER TABLE products ADD COLUMN barcode VARCHAR(100);
        RAISE NOTICE 'Added barcode column';
    ELSE
        RAISE NOTICE 'barcode column already exists';
    END IF;
    
    -- เพิ่ม cost_price ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'cost_price'
    ) THEN
        ALTER TABLE products ADD COLUMN cost_price DECIMAL(12,2) DEFAULT 0;
        RAISE NOTICE 'Added cost_price column';
    ELSE
        RAISE NOTICE 'cost_price column already exists';
    END IF;
    
    -- เพิ่ม unit ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'unit'
    ) THEN
        ALTER TABLE products ADD COLUMN unit VARCHAR(50) DEFAULT 'ชิ้น';
        RAISE NOTICE 'Added unit column';
    ELSE
        RAISE NOTICE 'unit column already exists';
    END IF;
    
    -- เพิ่ม is_active ถ้ายังไม่มี
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'products' AND column_name = 'is_active'
    ) THEN
        ALTER TABLE products ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_active column';
    ELSE
        RAISE NOTICE 'is_active column already exists';
    END IF;
    
    RAISE NOTICE '=== Table update completed ===';
END
$$;

-- 3. อัพเดท SKU สำหรับข้อมูลที่ไม่มี SKU
UPDATE products 
SET sku = 'PRD' || LPAD(id::text, 3, '0')
WHERE sku IS NULL OR sku = '';

-- 4. แสดงข้อมูลตาราง products หลังอัพเดท
SELECT 
    id,
    name,
    category,
    sku,
    cost_price,
    unit,
    is_active,
    created_at
FROM products 
ORDER BY id
LIMIT 5;

-- 5. ตรวจสอบโครงสร้างตารางสุดท้าย
SELECT 
    'โครงสร้างตารางหลังอัพเดท' as final_structure,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'products' 
ORDER BY ordinal_position;

-- 6. Success message
SELECT '✅ อัพเดทตารางเรียบร้อยแล้ว - ลองเพิ่มสินค้าใหม่ได้เลย!' AS message;
