-- Sales Summary View for Reports
CREATE OR REPLACE VIEW sales_summary_view AS
SELECT 
    DATE(s.sale_date) as sale_date,
    COUNT(s.id) as total_orders,
    SUM(s.total_amount) as total_sales,
    SUM(si.quantity) as total_items,
    CASE 
        WHEN COUNT(s.id) > 0 THEN SUM(s.total_amount) / COUNT(s.id)
        ELSE 0 
    END as avg_order_value
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
GROUP BY DATE(s.sale_date)
ORDER BY sale_date DESC;

-- Product Sales Summary View for Reports
CREATE OR REPLACE VIEW product_sales_summary_view AS
SELECT 
    DATE(s.sale_date) as sale_date,
    p.name as product_name,
    SUM(si.quantity) as quantity_sold,
    SUM(si.quantity * si.unit_price) as total_revenue
FROM sales s
JOIN sale_items si ON s.id = si.sale_id
JOIN products p ON si.product_id = p.id
GROUP BY DATE(s.sale_date), p.id, p.name
ORDER BY total_revenue DESC;

-- Weekly Sales Summary View
CREATE OR REPLACE VIEW weekly_sales_summary_view AS
SELECT 
    DATE_TRUNC('week', s.sale_date) as week_start,
    COUNT(s.id) as total_orders,
    SUM(s.total_amount) as total_sales,
    SUM(si.quantity) as total_items,
    CASE 
        WHEN COUNT(s.id) > 0 THEN SUM(s.total_amount) / COUNT(s.id)
        ELSE 0 
    END as avg_order_value
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
GROUP BY DATE_TRUNC('week', s.sale_date)
ORDER BY week_start DESC;

-- Monthly Sales Summary View
CREATE OR REPLACE VIEW monthly_sales_summary_view AS
SELECT 
    DATE_TRUNC('month', s.sale_date) as month_start,
    COUNT(s.id) as total_orders,
    SUM(s.total_amount) as total_sales,
    SUM(si.quantity) as total_items,
    CASE 
        WHEN COUNT(s.id) > 0 THEN SUM(s.total_amount) / COUNT(s.id)
        ELSE 0 
    END as avg_order_value
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
GROUP BY DATE_TRUNC('month', s.sale_date)
ORDER BY month_start DESC;

-- Yearly Sales Summary View
CREATE OR REPLACE VIEW yearly_sales_summary_view AS
SELECT 
    DATE_TRUNC('year', s.sale_date) as year_start,
    COUNT(s.id) as total_orders,
    SUM(s.total_amount) as total_sales,
    SUM(si.quantity) as total_items,
    CASE 
        WHEN COUNT(s.id) > 0 THEN SUM(s.total_amount) / COUNT(s.id)
        ELSE 0 
    END as avg_order_value
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
GROUP BY DATE_TRUNC('year', s.sale_date)
ORDER BY year_start DESC;

-- Revenue by Category View
CREATE OR REPLACE VIEW revenue_by_category_view AS
SELECT 
    p.category,
    SUM(si.quantity * si.unit_price) as total_revenue,
    SUM(si.quantity) as total_quantity,
    COUNT(DISTINCT s.id) as total_orders
FROM sales s
JOIN sale_items si ON s.id = si.sale_id
JOIN products p ON si.product_id = p.id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Daily Revenue Trend View (Last 30 days)
CREATE OR REPLACE VIEW daily_revenue_trend_view AS
SELECT 
    DATE(s.sale_date) as sale_date,
    SUM(s.total_amount) as daily_revenue,
    COUNT(s.id) as daily_orders,
    LAG(SUM(s.total_amount)) OVER (ORDER BY DATE(s.sale_date)) as previous_day_revenue,
    CASE 
        WHEN LAG(SUM(s.total_amount)) OVER (ORDER BY DATE(s.sale_date)) IS NOT NULL 
        THEN ((SUM(s.total_amount) - LAG(SUM(s.total_amount)) OVER (ORDER BY DATE(s.sale_date))) / LAG(SUM(s.total_amount)) OVER (ORDER BY DATE(s.sale_date))) * 100
        ELSE 0
    END as growth_percentage
FROM sales s
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(s.sale_date)
ORDER BY sale_date DESC;

-- Top Selling Products View
CREATE OR REPLACE VIEW top_selling_products_view AS
SELECT 
    p.id,
    p.name as product_name,
    p.category,
    p.selling_price,
    SUM(si.quantity) as total_quantity_sold,
    SUM(si.quantity * si.unit_price) as total_revenue,
    COUNT(DISTINCT s.id) as total_orders,
    AVG(si.quantity) as avg_quantity_per_order
FROM products p
JOIN sale_items si ON p.id = si.product_id
JOIN sales s ON si.sale_id = s.id
GROUP BY p.id, p.name, p.category, p.selling_price
ORDER BY total_revenue DESC;

-- Customer Analytics View (if we had customer data)
-- CREATE OR REPLACE VIEW customer_analytics_view AS
-- SELECT 
--     c.id as customer_id,
--     c.name as customer_name,
--     COUNT(s.id) as total_orders,
--     SUM(s.total_amount) as total_spent,
--     AVG(s.total_amount) as avg_order_value,
--     MIN(s.sale_date) as first_purchase,
--     MAX(s.sale_date) as last_purchase
-- FROM customers c
-- JOIN sales s ON c.id = s.customer_id
-- GROUP BY c.id, c.name
-- ORDER BY total_spent DESC;

-- Inventory Status View
CREATE OR REPLACE VIEW inventory_status_view AS
SELECT 
    p.id,
    p.name,
    p.category,
    p.stock_quantity,
    p.min_stock_level,
    p.selling_price,
    p.cost_price,
    (p.selling_price - p.cost_price) as profit_per_unit,
    (p.stock_quantity * p.cost_price) as inventory_value,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'หมดสต็อก'
        WHEN p.stock_quantity <= p.min_stock_level THEN 'สต็อกต่ำ'
        ELSE 'สต็อกปกติ'
    END as stock_status
FROM products p
WHERE p.is_active = true
ORDER BY p.stock_quantity ASC;
