-- OLIST BRAZILIAN E-COMMERCE PUBLIC DATASET - GRAIN VALIDATION
-- This script is used to validate the grain across the different tables in the Olist dataset. 
-- The goal is to ensure that the data is consistent and that there are no discrepancies in the relationships between the tables.

-- Customer Grain Validation

-- 1. Establish table and idetifier counts for the customer table --
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids,
    COUNT(*) - COUNT(DISTINCT customer_id) AS repeated_customer_id_occurrences,
    COUNT(DISTINCT customer_unique_id) AS distinct_customer_unique_ids,
    COUNT(*) - COUNT(DISTINCT customer_unique_id) AS repeated_customer_unique_ids_occurrences
FROM staging.customers;

-- 2. Check  for the uniqueness of customer_id and identify any duplicates --
SELECT 
    customer_id,
    COUNT(*) AS count
FROM staging.customers
GROUP BY customer_id 
HAVING COUNT(*) > 1
ORDER BY count DESC;

-- 3. Check for the uniqueness of customer_unique_id and identify any duplicates --
SELECT 
    customer_unique_id,
    COUNT(*) AS count
FROM staging.customers
GROUP BY customer_unique_id 
HAVING COUNT(*) > 1
ORDER BY count DESC;

-- 4. Determine the cardinality from customer_unique_id to customer_id --
SELECT 
    customer_unique_id,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM staging.customers
GROUP BY customer_unique_id
ORDER BY distinct_customer_ids DESC;

-- 5. Determine the cardinality from customer_id to customer_unique_id --
SELECT 
    customer_id,
    COUNT(DISTINCT customer_unique_id) AS distinct_customer_unique_ids
FROM staging.customers
GROUP BY customer_id
ORDER BY distinct_customer_unique_ids DESC;

-- GEOLOCATION GRAIN VALIDATION

-- 1. Establish table and attribute counts for the geolocation table --
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS distinct_zip_codes,
    COUNT(DISTINCT geolocation_lat) AS distinct_latitudes,
    COUNT(DISTINCT geolocation_lng) AS distinct_longitudes,
    COUNT(DISTINCT geolocation_city) AS distinct_cities,
    COUNT(DISTINCT geolocation_state) AS distinct_states
FROM staging.geolocation;

-- 2. Check for the uniqueness of geolocation_zip_code_prefix --
SELECT 
    geolocation_zip_code_prefix,
    COUNT(*) AS zip_code_count
FROM staging.geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1
ORDER BY zip_code_count DESC;

-- 3. Determine the number of geographic observations per zip code prefix --
SELECT 
    geolocation_zip_code_prefix,
    COUNT(*) AS geographic_observations
FROM staging.geolocation
GROUP BY geolocation_zip_code_prefix
ORDER BY geographic_observations DESC;

-- 4. Check whether the candidate geographic observation grain is unique
SELECT 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS geographic_occurrences
FROM staging.geolocation
GROUP BY 
    geolocation_zip_code_prefix, 
    geolocation_lat, 
    geolocation_lng, 
    geolocation_city, 
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY geographic_occurrences DESC;

-- 5. Summarise the ZIP-prefix-to-geographic-observation cardinality
SELECT
    geographic_observations,
    COUNT(*) AS zip_code_prefix_count
FROM (
    SELECT 
        geolocation_zip_code_prefix,
        COUNT(*) AS geographic_observations
    FROM staging.geolocation
    GROUP BY geolocation_zip_code_prefix
) AS zip_code_observations
GROUP BY geographic_observations
ORDER BY zip_code_prefix_count DESC;


-- ORDER ITEM GRAIN VALIDATION

-- 1. Establish table and identifier counts for the order_items table --
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids,
    COUNT(DISTINCT order_item_id) AS distinct_order_item_ids,
    COUNT(DISTINCT product_id) AS distinct_product_ids,
    COUNT(DISTINCT seller_id) AS distinct_seller_ids
FROM staging.items;

-- 2. Check the uniqueness of order_id
SELECT
    order_id,
    COUNT(*) AS order_id_count
FROM staging.items
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id_count DESC;

-- 3. Check the uniqueness of order_item_id
SELECT
    order_item_id,
    COUNT(*) AS order_item_id_count
FROM staging.items
GROUP BY order_item_id
HAVING COUNT(*) > 1
ORDER BY order_item_id_count DESC;

-- 4. Test the composite order_id and order_item_id key 
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS composite_key_count
FROM staging.items
GROUP BY 
    order_id, 
    order_item_id
HAVING COUNT(*) > 1
ORDER BY composite_key_count DESC;

-- 5. Examine product and seller cardinality at the order-item level
SELECT
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT product_id) AS distinct_products,
    COUNT(DISTINCT seller_id) AS distinct_sellers,
    COUNT(*) AS total_order_items
FROM staging.items;


-- ORDER PAYMENT GRAIN VALIDATION

-- 1. Establish table and identifier counts for the order_payments table --
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids,
    COUNT(DISTINCT payment_sequential) AS distinct_payment_sequentials,
    COUNT(DISTINCT payment_type) AS distinct_payment_types,
    COUNT(DISTINCT payment_installments) AS distinct_payment_installments
FROM staging.payments;

-- 2. Check the repetition of order_id in the order_payments table
SELECT
    order_id,
    COUNT(*) AS payment_record_count
FROM staging.payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_record_count DESC;   

-- 3. Check the payment_sequential uniqueness in the order_payments table
SELECT
    payment_sequential,
    COUNT(*) AS payment_sequential_count
FROM staging.payments
GROUP BY payment_sequential
HAVING COUNT(*) > 1
ORDER BY payment_sequential_count DESC;   

-- 4. Test the composite order_id and payment_sequential key
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS composite_key_count 
FROM staging.payments
GROUP BY 
    order_id, 
    payment_sequential
HAVING COUNT(*) > 1
ORDER BY composite_key_count DESC;

-- 5. Summarise payment-record cardinality per order
SELECT
    payment_record_count,
    COUNT(*) AS order_count
FROM (
    SELECT
        order_id,
        COUNT(*) AS payment_record_count
    FROM staging.payments
    GROUP BY order_id
) AS order_payment_counts
GROUP BY payment_record_count
ORDER BY payment_record_count DESC;


-- ORDER GRAIN VALIDATION

-- 1. Establish table and identifier counts for the orders table --
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids,
    COUNT(DISTINCT order_status) AS distinct_order_statuses
FROM staging.orders;

-- 2. Check the uniqueness of order_id in the orders table
SELECT
    order_id,
    COUNT(*) AS order_id_occurrences
FROM staging.orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id_occurrences DESC;

-- 3. Examine the cardinality of order_id to customer_id
SELECT
    order_id,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM staging.orders
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1
ORDER BY distinct_customer_ids DESC;

-- 4. Examine the cardinality of customer_id to order_id
SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS distinct_order_ids
FROM staging.orders
GROUP BY customer_id
ORDER BY distinct_order_ids DESC;

-- 5. Establish order-status cardinality
SELECT
    order_status,
    COUNT(*) AS number_of_orders
FROM staging.orders
GROUP BY order_status
ORDER BY number_of_orders DESC;

 
 -- ORDER REVIEW GRAIN VALIDATION

 -- 1. Establish table and identifier counts for the order_reviews table --
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT review_id) AS distinct_review_ids,
    COUNT(DISTINCT order_id) AS distinct_order_ids,
    COUNT(DISTINCT review_score) AS distinct_review_scores 
FROM staging.reviews;

-- 2. Check the uniqueness of review_id in the order_reviews table
SELECT
    review_id,
    COUNT(*) AS review_id_occurrences
FROM staging.reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY review_id_occurrences DESC;

-- 3. Check the uniqueness of order_id in the order_reviews table
SELECT
    order_id,
    COUNT(*) AS order_id_occurrences
FROM staging.reviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id_occurrences DESC;

-- 4. Examine the cardinality of review_id to order_id
SELECT
    review_id,
    COUNT(DISTINCT order_id) AS distinct_order_ids
FROM staging.reviews
GROUP BY review_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY distinct_order_ids DESC;

-- 5. Examine the cardinality of order_id to review_id
SELECT
    order_id,
    COUNT(DISTINCT review_id) AS distinct_review_ids
FROM staging.reviews
GROUP BY order_id
HAVING COUNT(DISTINCT review_id) > 1
ORDER BY distinct_review_ids DESC;

-- 6. Test the composite review_id and order_id key
SELECT
    review_id,
    order_id,
    COUNT(*) AS composite_key_count
FROM staging.reviews
GROUP BY 
    review_id, 
    order_id
HAVING COUNT(*) > 1
ORDER BY composite_key_count DESC;


-- PRODUCT GRAIN VALIDATION

-- 1. Establish table and identifier counts
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS distinct_product_ids,
    COUNT(DISTINCT product_category_name) AS distinct_product_categories
FROM staging.products;


-- 2. Check the uniqueness of product_id
SELECT 
    product_id,
    COUNT(*) AS occurrence_count
FROM staging.products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;


-- 3. Check whether repeated product IDs have identical or differing records
SELECT 
    product_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT product_category_name) AS distinct_categories,
    COUNT(DISTINCT product_name_lenght) AS distinct_name_lengths,
    COUNT(DISTINCT product_description_lenght) AS distinct_description_lengths,
    COUNT(DISTINCT product_photos_qty) AS distinct_photo_counts,
    COUNT(DISTINCT product_weight_g) AS distinct_weights,
    COUNT(DISTINCT product_length_cm) AS distinct_lengths,
    COUNT(DISTINCT product_height_cm) AS distinct_heights,
    COUNT(DISTINCT product_width_cm) AS distinct_widths
FROM staging.products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- 4. Determine the cardinality from product_id to product_category_name
SELECT 
    product_id,
    COUNT(DISTINCT product_category_name) AS distinct_product_categories
FROM staging.products
GROUP BY product_id
HAVING COUNT(DISTINCT product_category_name) > 1
ORDER BY distinct_product_categories DESC;


-- 5. Determine the cardinality from product_category_name to product_id
SELECT 
    product_category_name,
    COUNT(DISTINCT product_id) AS distinct_product_ids
FROM staging.products
GROUP BY product_category_name
ORDER BY distinct_product_ids DESC;