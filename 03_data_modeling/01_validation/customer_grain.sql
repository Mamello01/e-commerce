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