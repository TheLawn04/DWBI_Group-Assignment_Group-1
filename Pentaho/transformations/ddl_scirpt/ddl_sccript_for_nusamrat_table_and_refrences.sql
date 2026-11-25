CREATE DATABASE IF NOT EXISTS `dwbs_nrg` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `dwbs_nrg`;

-- droping any existing table with the name below to prvent import error
DROP TABLE IF EXISTS `fact_sales`;
DROP TABLE IF EXISTS `dim_campaign`;
DROP TABLE IF EXISTS `dim_channel`;
DROP TABLE IF EXISTS `dim_customer`;
DROP TABLE IF EXISTS `dim_product`;
DROP TABLE IF EXISTS `dim_timestamp`;
DROP TABLE IF EXISTS `map_product`;
DROP TABLE IF EXISTS `std_city_ref`;
DROP TABLE IF EXISTS `stg_product_cost`;

-- dim_campaign table
CREATE TABLE `dim_campaign` (
    `campaign_key` INT(11) NOT NULL AUTO_INCREMENT,
    `voucher_id` INT(11) DEFAULT NULL,
    `campaign_code` VARCHAR(50) DEFAULT NULL,
    `campaign_name` VARCHAR(255) DEFAULT NULL,
    `campaign_type` VARCHAR(100) DEFAULT NULL,
    `campaign_scope` VARCHAR(100) DEFAULT NULL,
    `target_discount_pct` DECIMAL(5,2) DEFAULT NULL,
    `discount_value` DECIMAL(10,2) DEFAULT NULL,
    `min_purchase` DECIMAL(10,2) DEFAULT NULL,
    `quota` INT(11) DEFAULT NULL,
    `start_date` DATETIME DEFAULT NULL,
    `end_date` DATETIME DEFAULT NULL,
    `pic` VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (`campaign_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- dim_channel table
CREATE TABLE `dim_channel` (
    `channel_key` INT(11) NOT NULL AUTO_INCREMENT,
    `channel_code` VARCHAR(20) NOT NULL,
    `channel_name` VARCHAR(100) NOT NULL,
    `channel_type` VARCHAR(50) NOT NULL,
    `store_format` VARCHAR(50) DEFAULT NULL,
    `province` VARCHAR(50) DEFAULT NULL,
    `city_std` VARCHAR(50) DEFAULT NULL,
    `source_system` VARCHAR(10) NOT NULL,
    PRIMARY KEY (`channel_key`),
    UNIQUE KEY `uk_channel_code` (`channel_code`),
    KEY `idx_channel_type` (`channel_type`),
    KEY `idx_channel_city` (`city_std`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- dim_customer table
CREATE TABLE `dim_customer` (
    `customer_key` INT(11) NOT NULL AUTO_INCREMENT,
    `customer_id` VARCHAR(50) DEFAULT NULL,
    `customer_name` VARCHAR(150) DEFAULT NULL,
    `member_id` VARCHAR(50) DEFAULT NULL,
    `phone` VARCHAR(30) DEFAULT NULL,
    `buyer_hash` VARCHAR(100) DEFAULT NULL,
    `city` VARCHAR(100) DEFAULT NULL,
    `customer_type` VARCHAR(30) NOT NULL DEFAULT 'UNKNOWN',
    `is_web_member_match` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`customer_key`),
    KEY `idx_cust_customer_id` (`customer_id`),
    KEY `idx_cust_member_id` (`member_id`),
    KEY `idx_cust_buyer_hash` (`buyer_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- dim_product table
CREATE TABLE `dim_product` (
    `product_key` INT(11) NOT NULL AUTO_INCREMENT,
    `material_no` VARCHAR(20) COLLATE utf8mb4_general_ci NOT NULL,
    `product_name` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
    `category` VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `sub_category` VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `brand` VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `base_price` DECIMAL(12,2) DEFAULT NULL,
    `status` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `available_since` DATE DEFAULT NULL,
    `supplier_name` VARCHAR(40) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `supplier_homecity` VARCHAR(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `supplier_contact` VARCHAR(30) COLLATE utf8mb4_general_ci DEFAULT NULL,
    PRIMARY KEY (`product_key`),
    UNIQUE KEY `uk_material_no` (`material_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- dim_timestamp table
CREATE TABLE `dim_timestamp` (
    `timestamp_key` INT NOT NULL,
    `full_timestamp` TIMESTAMP NULL,
    `date_value` DATE NOT NULL,
    `year` INT NOT NULL,
    `quarter` VARCHAR(2) NOT NULL,
    `year_quarter` VARCHAR(7) NOT NULL,
    `month` INT NOT NULL,
    `day` INT NOT NULL,
    `is_weekend` BOOLEAN NOT NULL,
    PRIMARY KEY (`timestamp_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- map_product table
CREATE TABLE `map_product` (
    `map_id` INT(11) NOT NULL AUTO_INCREMENT,
    `product_id` INT(11) DEFAULT NULL,
    `sku` VARCHAR(50) COLLATE utf8mb4_general_ci NOT NULL,
    `product_name` VARCHAR(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `category` VARCHAR(1000) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `sub_category` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `material_no` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `barcode` VARCHAR(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
    PRIMARY KEY (`map_id`),
    UNIQUE KEY `uk_sku` (`sku`),
    INDEX `idx_material_no` (`material_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- std_city_ref table
CREATE TABLE `std_city_ref` (
    `city_alias` VARCHAR(50) NOT NULL,
    `city_std` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`city_alias`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- stg_product_cost table
CREATE TABLE `stg_product_cost` (
    `cost_id` INT(11) NOT NULL AUTO_INCREMENT,
    `material_no` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
    `product_name` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
    `brand` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
    `category` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
    `sub_category` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
    `base_price` DECIMAL(12,2) NOT NULL,
    `supplier` VARCHAR(150) COLLATE utf8mb4_unicode_ci NOT NULL,
    `status` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
    `available_since` DATE NOT NULL,
    PRIMARY KEY (`cost_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- fact_sales table
CREATE TABLE `fact_sales` (
    `sales_key` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `source_system` VARCHAR(10) NOT NULL,
    `source_txn_id` VARCHAR(50) NOT NULL,
    `source_line_no` VARCHAR(50) NOT NULL,
    `order_status` VARCHAR(50) DEFAULT NULL,
    `txn_ts_wib` DATETIME DEFAULT NULL,
    `timestamp_key` INT(11) NOT NULL,
    `product_key` INT(11) NOT NULL,
    `customer_key` INT(11) DEFAULT NULL,
    `channel_key` INT(11) DEFAULT NULL,
    `campaign_key` INT(11) DEFAULT NULL,
    `quantity` INT(11) NOT NULL DEFAULT 1,
    `unit_price_ex_vat` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `gross_sales` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `discount_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `net_sales` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `unit_cost` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `cogs` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `commission_fee` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    `gross_margin` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (`sales_key`),
    KEY `idx_fact_timestamp` (`timestamp_key`),
    KEY `idx_fact_product` (`product_key`),
    KEY `idx_fact_customer` (`customer_key`),
    KEY `idx_fact_channel` (`channel_key`),
    KEY `idx_fact_campaign` (`campaign_key`),
    KEY `idx_fact_source` (`source_system`, `source_txn_id`),
    CONSTRAINT `fk_fact_campaign` FOREIGN KEY (`campaign_key`) REFERENCES `dim_campaign` (`campaign_key`) ON UPDATE CASCADE,
    CONSTRAINT `fk_fact_channel` FOREIGN KEY (`channel_key`) REFERENCES `dim_channel` (`channel_key`) ON UPDATE CASCADE,
    CONSTRAINT `fk_fact_customer` FOREIGN KEY (`customer_key`) REFERENCES `dim_customer` (`customer_key`) ON UPDATE CASCADE,
    CONSTRAINT `fk_fact_product` FOREIGN KEY (`product_key`) REFERENCES `dim_product` (`product_key`) ON UPDATE CASCADE,
    CONSTRAINT `fk_fact_timestamp` FOREIGN KEY (`timestamp_key`) REFERENCES `dim_timestamp` (`timestamp_key`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;