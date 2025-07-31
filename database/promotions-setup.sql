-- ==========================================
-- POS CHAMA PROMOTIONS SYSTEM SQL SCRIPT
-- Copy and paste this into Supabase SQL Editor
-- ==========================================

-- 1. Create promotions table
CREATE TABLE IF NOT EXISTS promotions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(50) NOT NULL CHECK (type IN ('percentage', 'fixed')),
  value DECIMAL(10, 2) NOT NULL,
  min_amount DECIMAL(10, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  usage_count INTEGER DEFAULT 0,
  max_usage INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Add new columns to existing sales table (not orders)
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS promotion_id UUID,
ADD COLUMN IF NOT EXISTS promotion_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS discount_percentage DECIMAL(5,2) DEFAULT 0;

-- 3. Update existing discount_amount column to include promotion discounts
-- (discount_amount already exists in sales table)

-- 4. Add foreign key constraint for promotion_id (skip if incompatible types)
-- ALTER TABLE sales 
-- ADD CONSTRAINT fk_sales_promotion 
-- FOREIGN KEY (promotion_id) REFERENCES promotions(id);

-- 5. Insert sample promotions data
INSERT INTO promotions (name, type, value, min_amount, description, is_active) VALUES
('ลดราคา 10%', 'percentage', 10, 50, 'ลด 10% เมื่อซื้อครบ 50 บาท', true),
('ลด 20 บาท', 'fixed', 20, 100, 'ลด 20 บาท เมื่อซื้อครบ 100 บาท', true),
('ลดราคา 15%', 'percentage', 15, 200, 'ลด 15% เมื่อซื้อครบ 200 บาท', true),
('ลด 50 บาท', 'fixed', 50, 300, 'ลด 50 บาท เมื่อซื้อครบ 300 บาท', true),
('ลดราคา 25%', 'percentage', 25, 500, 'ลด 25% เมื่อซื้อครบ 500 บาท', true),
('ลดราคาพิเศษ', 'percentage', 30, 1000, 'ลด 30% เมื่อซื้อครบ 1,000 บาท', true),
('ส่วนลดสมาชิก', 'percentage', 5, 0, 'ส่วนลด 5% สำหรับสมาชิก', true),
('โปรสุดคุ้ม', 'fixed', 100, 800, 'ลด 100 บาท เมื่อซื้อครบ 800 บาท', true);

-- 6. Enable Row Level Security
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;

-- 7. Create policy for public access (adjust for production security)
CREATE POLICY "Allow all operations on promotions" ON promotions FOR ALL USING (true);

-- 8. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions(is_active);
CREATE INDEX IF NOT EXISTS idx_promotions_type ON promotions(type);
CREATE INDEX IF NOT EXISTS idx_promotions_dates ON promotions(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_promotions_min_amount ON promotions(min_amount);
CREATE INDEX IF NOT EXISTS idx_sales_promotion_id ON sales(promotion_id);

-- 9. Create trigger for updating promotion usage count
CREATE OR REPLACE FUNCTION update_promotion_usage()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.promotion_id IS NOT NULL AND OLD.promotion_id IS DISTINCT FROM NEW.promotion_id THEN
    UPDATE promotions 
    SET usage_count = usage_count + 1 
    WHERE id = NEW.promotion_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_promotion_usage
  AFTER INSERT OR UPDATE ON sales
  FOR EACH ROW
  EXECUTE FUNCTION update_promotion_usage();

-- 10. Create view for active promotions
CREATE OR REPLACE VIEW active_promotions AS
SELECT 
  id,
  name,
  description,
  type,
  value,
  min_amount,
  usage_count,
  max_usage,
  start_date,
  end_date,
  CASE 
    WHEN end_date IS NULL OR end_date > NOW() THEN true
    ELSE false
  END AS is_valid,
  created_at
FROM promotions 
WHERE is_active = true
ORDER BY min_amount ASC;

-- 11. Create function to calculate discount
CREATE OR REPLACE FUNCTION calculate_discount(
  subtotal DECIMAL(12,2),
  promotion_id UUID
) RETURNS TABLE(
  discount_amount DECIMAL(12,2),
  discount_percentage DECIMAL(5,2),
  promotion_name VARCHAR(255)
) AS $$
DECLARE
  promo_record RECORD;
  calculated_discount DECIMAL(12,2) := 0;
  calculated_percentage DECIMAL(5,2) := 0;
BEGIN
  -- Get promotion details
  SELECT * INTO promo_record 
  FROM promotions 
  WHERE id = promotion_id 
    AND is_active = true
    AND (end_date IS NULL OR end_date > NOW())
    AND subtotal >= min_amount;
    
  IF FOUND THEN
    IF promo_record.type = 'percentage' THEN
      calculated_discount := subtotal * (promo_record.value / 100);
      calculated_percentage := promo_record.value;
    ELSE -- fixed
      calculated_discount := promo_record.value;
      calculated_percentage := ROUND((promo_record.value / subtotal * 100)::numeric, 2);
    END IF;
    
    RETURN QUERY SELECT 
      calculated_discount,
      calculated_percentage,
      promo_record.name;
  ELSE
    RETURN QUERY SELECT 
      0::DECIMAL(12,2),
      0::DECIMAL(5,2),
      ''::VARCHAR(255);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 12. Verify the setup
SELECT 'POS CHAMA Promotions system created successfully! 🎉' as status;
SELECT count(*) as total_promotions FROM promotions;
SELECT name, type, value, min_amount, description FROM promotions WHERE is_active = true ORDER BY min_amount;

-- 13. Show sample usage
SELECT 'Sample discount calculation for 150 baht purchase:' as info;
SELECT * FROM calculate_discount(150, (SELECT id FROM promotions WHERE min_amount <= 150 AND is_active = true ORDER BY value DESC LIMIT 1));
