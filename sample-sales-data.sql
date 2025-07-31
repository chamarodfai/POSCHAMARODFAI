-- Insert sample sales data for testing reports
-- (Run this only if you want to test with sample data)

-- First, let's check if we have any sales data
-- SELECT COUNT(*) FROM sales;

-- If no sales data exists, insert some sample data
INSERT INTO sales (total_amount, sale_date, payment_method, created_at) 
VALUES 
    (120.00, '2025-01-25', 'cash', '2025-01-25 10:30:00'),
    (85.50, '2025-01-25', 'card', '2025-01-25 14:15:00'),
    (240.00, '2025-01-26', 'cash', '2025-01-26 09:45:00'),
    (156.75, '2025-01-26', 'transfer', '2025-01-26 16:20:00'),
    (95.00, '2025-01-27', 'cash', '2025-01-27 11:30:00'),
    (180.50, '2025-01-28', 'card', '2025-01-28 13:45:00'),
    (320.00, '2025-01-29', 'transfer', '2025-01-29 15:10:00'),
    (75.25, '2025-01-30', 'cash', '2025-01-30 10:20:00'),
    (145.00, '2025-01-31', 'card', '2025-01-31 12:30:00')
ON CONFLICT (id) DO NOTHING;

-- Get the sales IDs for sample sale items
-- Assuming we have products with IDs 1, 2, 3 (adjust based on your actual product data)
INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) 
SELECT 
    s.id,
    CASE 
        WHEN random() < 0.4 THEN (SELECT id FROM products WHERE is_active = true ORDER BY random() LIMIT 1)
        WHEN random() < 0.7 THEN (SELECT id FROM products WHERE is_active = true ORDER BY random() LIMIT 1)
        ELSE (SELECT id FROM products WHERE is_active = true ORDER BY random() LIMIT 1)
    END as product_id,
    FLOOR(random() * 3 + 1)::integer as quantity,
    (SELECT selling_price FROM products WHERE is_active = true ORDER BY random() LIMIT 1) as unit_price
FROM sales s
WHERE NOT EXISTS (SELECT 1 FROM sale_items WHERE sale_id = s.id)
LIMIT 20;

-- Update sales total_amount to match sale_items
UPDATE sales 
SET total_amount = (
    SELECT COALESCE(SUM(si.quantity * si.unit_price), 0)
    FROM sale_items si 
    WHERE si.sale_id = sales.id
)
WHERE EXISTS (SELECT 1 FROM sale_items WHERE sale_id = sales.id);
