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

