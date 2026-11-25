USE dwbs_nrg;

-- Question 1: Which product categories generate the highest gross margin in each sales channel?
SELECT 
    c.channel_type,
    p.category,
    p.sub_category,
    t.year,
    t.quarter,
    ROUND(SUM(f.net_sales), 2) AS total_net_sales,
    ROUND(SUM(f.gross_margin), 2) AS total_gross_margin
FROM fact_sales f
JOIN dim_channel c   ON f.channel_key = c.channel_key
JOIN dim_product p   ON f.product_key = p.product_key
JOIN dim_timestamp t ON f.timestamp_key = t.timestamp_key
GROUP BY c.channel_type, p.category, p.sub_category, t.year, t.quarter
ORDER BY c.channel_type, total_gross_margin DESC, t.year DESC, t.quarter;

-- Question 2: Are online customers the same people as store member-card customers?
SELECT 
    CASE 
        WHEN c.is_web_member_match = 1 OR (c.member_id IS NOT NULL AND c.customer_id IS NOT NULL) THEN 'Omnichannel Customer (Both Web & Store Member)'
        WHEN c.customer_id IS NOT NULL THEN 'Online-Only Shopper (Web)'
        WHEN c.member_id IS NOT NULL THEN 'Store-Only Member'
        WHEN c.buyer_hash IS NOT NULL THEN 'Marketplace Shopper'
        ELSE 'Anonymous / Walk-in Guest'
    END AS customer_profile_segment,
    COUNT(DISTINCT c.customer_key) AS total_unique_customers,
    COUNT(DISTINCT f.source_txn_id) AS total_orders_placed,
    ROUND(SUM(f.net_sales), 2) AS total_revenue_contribution,
    ROUND((SUM(f.net_sales) / (SELECT SUM(net_sales) FROM fact_sales)) * 100, 2) AS revenue_share_pct
FROM dim_customer c
LEFT JOIN fact_sales f ON c.customer_key = f.customer_key
GROUP BY customer_profile_segment
ORDER BY total_revenue_contribution DESC;

-- Question 3: Which promotional campaigns increase sales without reducing profit too much?
SELECT 
    d.campaign_code,
    d.campaign_name,
    d.campaign_scope,
    d.target_discount_pct,
    COUNT(f.sales_key) AS total_line_items_sold,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.gross_sales), 2) AS gross_revenue,
    ROUND(SUM(f.discount_amount), 2) AS total_discount_given,
    ROUND(SUM(f.net_sales), 2) AS net_revenue,
    ROUND(SUM(f.gross_margin), 2) AS total_gross_margin_generated,
    ROUND((SUM(f.gross_margin) / NULLIF(SUM(f.net_sales), 0)) * 100, 2) AS effective_margin_pct
FROM fact_sales f
JOIN dim_campaign d ON f.campaign_key = d.campaign_key
GROUP BY d.campaign_key, d.campaign_code, d.campaign_name, d.campaign_scope, d.target_discount_pct
ORDER BY total_units_sold DESC;

-- Question 4: Which products sell better in marketplaces than in stores or the website?
SELECT 
    p.material_no,
    p.product_name,
    p.category,
    p.sub_category,
    COALESCE(SUM(CASE WHEN f.source_system = 'S3' THEN f.quantity ELSE 0 END), 0) AS marketplace_qty_sold,
    COALESCE(SUM(CASE WHEN f.source_system = 'S2' THEN f.quantity ELSE 0 END), 0) AS physical_store_qty_sold,
    COALESCE(SUM(CASE WHEN f.source_system = 'S1' THEN f.quantity ELSE 0 END), 0) AS web_qty_sold,
    ROUND(SUM(CASE WHEN f.source_system = 'S3' THEN f.net_sales ELSE 0 END), 2) AS marketplace_net_sales,
    ROUND(SUM(CASE WHEN f.source_system = 'S3' THEN f.gross_margin ELSE 0 END), 2) AS marketplace_gross_margin
FROM dim_product p
JOIN fact_sales f ON p.product_key = f.product_key
GROUP BY p.product_key, p.material_no, p.product_name, p.category, p.sub_category
HAVING marketplace_qty_sold > physical_store_qty_sold 
   AND marketplace_qty_sold > web_qty_sold
ORDER BY marketplace_qty_sold DESC
LIMIT 10;