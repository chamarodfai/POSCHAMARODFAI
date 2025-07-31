-- ==========================================
-- FIX PROMOTIONS FOREIGN KEY ISSUE
-- Run this after checking the sales table structure
-- ==========================================

-- Option 1: If promotion_id doesn't exist, add it as UUID
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sales' AND column_name = 'promotion_id'
    ) THEN
        ALTER TABLE sales ADD COLUMN promotion_id UUID;
    END IF;
END
$$;

-- Option 2: If promotion_id exists but wrong type, drop and recreate
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sales' 
        AND column_name = 'promotion_id' 
        AND data_type != 'uuid'
    ) THEN
        -- Drop existing column if wrong type
        ALTER TABLE sales DROP COLUMN IF EXISTS promotion_id;
        -- Add as UUID
        ALTER TABLE sales ADD COLUMN promotion_id UUID;
    END IF;
END
$$;

-- Now try to add the foreign key constraint
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_sales_promotion'
    ) THEN
        ALTER TABLE sales 
        ADD CONSTRAINT fk_sales_promotion 
        FOREIGN KEY (promotion_id) REFERENCES promotions(id);
    END IF;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Could not create foreign key constraint: %', SQLERRM;
END
$$;

-- Verify the fix
SELECT 'Foreign key setup completed' as status;

-- Show current sales table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'sales' AND column_name IN ('id', 'promotion_id')
ORDER BY ordinal_position;
