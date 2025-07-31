-- Add topping products to database
INSERT INTO products (name, category, sku, barcode, selling_price, cost_price, stock_quantity, min_stock_level, description, is_active) VALUES
('ไข่มุก', 'topping', 'TOPPING001', '2000000000001', 10.00, 5.00, 1000, 50, 'ไข่มุกสำหรับเครื่องดื่ม', true),
('วุ้นกะทิ', 'topping', 'TOPPING002', '2000000000002', 8.00, 4.00, 1000, 50, 'วุ้นกะทิสำหรับเครื่องดื่ม', true),
('เจลลี่ใส', 'topping', 'TOPPING003', '2000000000003', 8.00, 4.00, 1000, 50, 'เจลลี่ใสสำหรับเครื่องดื่ม', true),
('แป้งมัน', 'topping', 'TOPPING004', '2000000000004', 8.00, 4.00, 1000, 50, 'แป้งมันสำหรับเครื่องดื่ม', true),
('ลูกตาล', 'topping', 'TOPPING005', '2000000000005', 12.00, 6.00, 1000, 50, 'ลูกตาลสำหรับเครื่องดื่ม', true),
('โค้ก', 'topping', 'TOPPING006', '2000000000006', 15.00, 8.00, 1000, 50, 'โค้กเพิ่มเติม', true);
