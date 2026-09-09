# Olist Brazilian E-commerce - Grain Validation

## Introduction

Grain validation establishes what each row represents within the cleaned and standardised staging datasets and determines whether the data behaves consistently with its expected level of detail.

The Olist Brazilian E-commerce dataset consists of nine interconnected datasets that represent different entities and business processes within the same e-commerce system. Grain validation therefore considers each dataset individually while maintaining the relational context between datasets, particularly where identifiers are shared across tables.

The validation builds on the data cleaning and standardisation already completed during the preparation phase. Previously addressed data-quality issues are not re-investigated unless they have a direct bearing on grain or downstream modelling decisions.

The findings from this phase provide the evidence required for the subsequent relationship-validation and data-modelling stages. In particular, they support decisions concerning fact and dimension grain, key selection, relationship cardinality, potential row multiplication during joins, and the design of the `analytics` schema.

## Customers

The `customers` dataset contains customer-related records within the Olist e-commerce system. The main identifiers are `customer_id` and `customer_unique_id`. Grain validation focuses on determining which identifier operates at the row level and understanding the cardinality between the two identifiers.

### 1. Establish table and identifier counts

The first step is to establish the total number of records and compare this with the number of distinct values for the two customer identifiers.

| Metric | Result |
| --- | ---: |
| Total rows | 99,441 |
| Distinct `customer_id` | 99,441 |
| Repeated `customer_id` occurrences | 0 |
| Distinct `customer_unique_id` | 96,096 |
| Repeated `customer_unique_id` occurrences | 3,345 |

The number of rows is equal to the number of distinct `customer_id` values, while `customer_unique_id` has fewer distinct values than the total number of rows. This indicates that `customer_id` is unique at the table level, whereas `customer_unique_id` is repeated across multiple records.

### 2. Validate `customer_id` uniqueness

The uniqueness check for `customer_id` returns no records with more than one occurrence.

This confirms that each `customer_id` occurs once within `staging.customers` and can therefore serve as the row-level identifier for the table.

### 3. Validate `customer_unique_id` uniqueness

The uniqueness check shows that `customer_unique_id` occurs multiple times within the table. The repeated identifiers have varying frequencies, with observed occurrences including 17, 9, 7, 6, 5, and lower.

The results confirm that `customer_unique_id` does not uniquely identify rows within `staging.customers`. The repeated values are not treated as duplicate records at this stage because identifier repetition alone does not establish a grain violation.

### 4. Validate the relationship between `customer_unique_id` and `customer_id`

The cardinality analysis shows that a single `customer_unique_id` can be associated with multiple distinct `customer_id` values. The highest observed example is a `customer_unique_id` associated with 17 distinct `customer_id` values.

This establishes a one-to-many relationship from `customer_unique_id` to `customer_id` within the `customers` table.

### 5. Validate the relationship between `customer_id` and `customer_unique_id`

The reverse cardinality analysis shows that each `customer_id` is associated with exactly one distinct `customer_unique_id`.

This establishes a many-to-one relationship from `customer_id` to `customer_unique_id`. Combined with the uniqueness validation, the result confirms that each row-level `customer_id` maps to a single broader customer identity.

## **Overall Finding - Customers**

The grain of `staging.customers` is established at the `customer_id` level, with each row representing one unique `customer_id` record.

`customer_id` is unique across all 99,441 rows, while `customer_unique_id` is not unique and can be associated with multiple `customer_id` values. Each `customer_id`, however, maps to exactly one `customer_unique_id`.

The two identifiers therefore operate at different levels of granularity. `customer_id` is the appropriate row-level identifier for `staging.customers`, while `customer_unique_id` represents a broader customer identity that may span multiple customer records.

This distinction is important for subsequent relationship validation and analytical modelling, as `customer_unique_id` should not be treated as the unique key of the staging table or used as though it uniquely identifies each row.

## Geolocation

The `geolocation` dataset contains geographic observations associated with ZIP-code prefixes within the Olist e-commerce system. The main attributes used to establish the grain are `geolocation_zip_code_prefix`, `geolocation_lat`, `geolocation_lng`, `geolocation_city`, and `geolocation_state`.

### 1. Establish table and attribute counts

The first step is to establish the total number of records and the number of distinct values across the main geographic attributes.

| Metric | Result |
| --- | ---: |
| Total rows | 720,457 |
| Distinct `geolocation_zip_code_prefix` | 19,010 |
| Distinct `geolocation_lat` | 717,316 |
| Distinct `geolocation_lng` | 717,580 |
| Distinct `geolocation_city` | 5,949 |
| Distinct `geolocation_state` | 27 |

The table contains 720,457 records but only 19,010 distinct ZIP-code prefixes. The substantially higher number of distinct latitude and longitude values indicates that the table contains geographic observations at a finer level of detail than the ZIP-code prefix alone.

This establishes that `geolocation_zip_code_prefix` cannot represent the row-level grain by itself.

### 2. Validate `geolocation_zip_code_prefix` uniqueness

The uniqueness check confirms that ZIP-code prefixes occur across multiple records. Some prefixes occur hundreds of times, with the highest observed counts including 746, 727, 726, and 666 records.

This confirms that a ZIP-code prefix can be associated with multiple geographic observations and therefore does not uniquely identify a row in the table.

The repeated ZIP-code prefixes are not treated as duplicate records because the geolocation dataset operates at a finer geographic level than the ZIP-code prefix.

### 3. Determine the number of geographic observations per ZIP-code prefix

The results show that individual ZIP-code prefixes are associated with varying numbers of geographic observations. For example, ZIP prefix `38400` occurs across 746 records, while other prefixes occur across smaller numbers of observations.

This establishes a one-to-many relationship between ZIP-code prefixes and geographic observations within the `geolocation` table.

The result is consistent with the structure of geographic data, where multiple coordinate observations can exist within the same ZIP-code prefix.

### 4. Validate the candidate geographic observation grain

The candidate geographic observation was assessed using the combination of `geolocation_zip_code_prefix`, `geolocation_lat`, `geolocation_lng`, `geolocation_city`, and `geolocation_state`.

The uniqueness check returns no records with repeated combinations of these attributes.

This confirms that the tested combination uniquely identifies the geographic observations in the staging table.

The result does not establish that latitude and longitude alone form a unique identifier, as the validation tested the complete combination of ZIP-code prefix, latitude, longitude, city, and state. Therefore, the grain is documented at the level supported by the validation performed.

### 5. Summarise ZIP-code prefix to geographic observation cardinality

The cardinality distribution shows how many ZIP-code prefixes contain a given number of geographic observations.

| Geographic observations per ZIP prefix | ZIP prefix count |
| ---: | ---: |
| 1 | 1,231 |
| 2 | 712 |
| 3 | 584 |
| 4 | 516 |
| 5 | 493 |
| 6 | 460 |
| 7 | 455 |
| 8 | 406 |
| 9 | 441 |
| 10 | 369 |
| 11 | 412 |
| 12 | 375 |
| 13 | 340 |
| 14 | 315 |
| 15 | 341 |
| 16 | 332 |
| 17 | 306 |
| 18 | 310 |
| 19 | 295 |
| 21 | 285 |
| 22 | 296 |
| 23 | 283 |

The distribution confirms that ZIP-code prefixes can contain multiple geographic observations and that the number of observations varies considerably between prefixes.

This reinforces that ZIP-code prefix should not be treated as a unique key for the geolocation table.

## **Overall Finding - Geolocation**

The grain of `staging.geolocation` is established at the level of an individual geographic observation represented by the combination of `geolocation_zip_code_prefix`, `geolocation_lat`, `geolocation_lng`, `geolocation_city`, and `geolocation_state`.

`geolocation_zip_code_prefix` is not unique and can correspond to multiple geographic observations. The tested combination of geographic attributes is unique across the staging table, providing evidence for the row-level grain.

The relationship between ZIP-code prefix and geographic observations is therefore one-to-many. This is an important consideration for subsequent relationship validation and analytical modelling because joining customer or seller records to `geolocation` using only the ZIP-code prefix could produce multiple matching geolocation records and result in row multiplication.

The geolocation table should therefore not be treated as a one-row-per-ZIP-code lookup without an appropriate modelling or transformation strategy.

## Order Items

The `order_items` dataset contains the individual order-item records associated with orders in the Olist e-commerce system. The main identifiers are `order_id`, `order_item_id`, `product_id`, and `seller_id`. Grain validation focuses on determining whether each row represents an individual item within an order and whether `order_id` and `order_item_id` together uniquely identify that record.

### 1. Establish table and identifier counts for order items

The first step is to establish the total number of records and the number of distinct values for the main identifiers.

| Metric | Result |
| --- | ---: |
| Total rows | 112,650 |
| Distinct `order_id` | 98,666 |
| Distinct `order_item_id` | 21 |
| Distinct `product_id` | 32,951 |
| Distinct `seller_id` | 3,095 |

The table contains 112,650 order-item records and 98,666 distinct orders. The difference between these counts indicates that individual orders can contain multiple order-item records.

Only 21 distinct `order_item_id` values are present, indicating that `order_item_id` does not function as a globally unique identifier. The product and seller identifiers also occur across multiple order-item records, reflecting their participation in the wider order-item structure.

### 2. Validate `order_id` repetition

The next step is to examine how many order-item records are associated with each `order_id`.

The results show that individual orders can contain multiple order-item records. The highest observed order contains 21 order-item records, with other orders containing 20, 15, 14, 13, and fewer records.

This confirms that `order_id` does not uniquely identify rows in `staging.order_items`. Its role is to identify the order to which one or more order-item records belong.

### 3. Validate `order_item_id` uniqueness

The uniqueness check shows that `order_item_id` is repeated across the table. The identifier ranges across 21 distinct values, with `order_item_id` 1 occurring 98,666 times, followed by lower frequencies for subsequent item positions.

This indicates that `order_item_id` is not globally unique. Its meaning is contextual to the associated `order_id`, representing the position of an item within an order rather than uniquely identifying an order-item record across the entire table.

### 4. Validate the composite `order_id` and `order_item_id` grain

The combination of `order_id` and `order_item_id` is tested to determine whether the same combination occurs more than once.

The result returns no repeated combinations.

This confirms that the combination of `order_id` and `order_item_id` uniquely identifies the records within `staging.order_items`. While neither identifier is unique independently, their combination provides a unique identifier for the row-level grain.

### 5. Establish product and seller participation

The order-item table contains 32,951 distinct products and 3,095 distinct sellers across the 112,650 order-item records.

| Metric | Result |
| --- | ---: |
| Distinct orders | 98,666 |
| Distinct products | 32,951 |
| Distinct sellers | 3,095 |
| Total order-item records | 112,650 |

These results establish the population of orders, products, and sellers represented within the order-item grain. The detailed cardinality of the relationships between these entities is reserved for the subsequent relationship-validation stage.

## Overall Finding - Order Items

The grain of `staging.order_items` is established at the level of an individual order item within an order. Each row represents one order-item record rather than one complete order.

`order_id` is not unique because an order can contain multiple order-item records. `order_item_id` is also not globally unique and is meaningful within the context of an order. The combination of `order_id` and `order_item_id` is unique across the staging table and therefore provides the row-level identifier for the order-item grain.

The table contains 112,650 order-item records associated with 98,666 distinct orders, 32,951 distinct products, and 3,095 distinct sellers. The detailed relationships between order items, products, sellers, and orders will be validated separately during relationship validation.

The confirmed order-item grain provides the basis for treating `order_items` as an item-level transactional component of the analytical model and for ensuring that measures based on order-item records are not incorrectly interpreted as order-level measures.

## Order Payments

The `order_payments` dataset contains payment records associated with orders in the Olist e-commerce system. The main identifiers are `order_id` and `payment_sequential`, while `payment_type`, `payment_installments`, and `payment_value` describe attributes of the payment record. Grain validation focuses on determining whether each row represents one payment record associated with an order and whether `order_id` and `payment_sequential` together uniquely identify that record.

### 1. Establish table and attribute counts for Order Payments Table

The first step is to establish the total number of records and the number of distinct values for the main payment identifiers and attributes.

| Metric | Result |
| --- | ---: |
| Total rows | 103,886 |
| Distinct `order_id` | 99,440 |
| Distinct `payment_sequential` | 29 |
| Distinct `payment_type` | 5 |
| Distinct `payment_installments` | 24 |

The table contains 103,886 payment records associated with 99,440 distinct orders. The difference between these counts indicates that some orders are associated with multiple payment records.

There are 29 distinct `payment_sequential` values, confirming that this field does not function as a globally unique identifier. The table also contains five distinct payment types and 24 distinct installment values.

### 2. Validate `order_id` repetition in Order Payments

The next step is to examine the number of payment records associated with each `order_id`.

The results show that individual orders can contain multiple payment records. The highest observed order is associated with 29 payment records, followed by orders with 26, 22, 21, 19, and fewer payment records.

This confirms that `order_id` does not uniquely identify rows in `staging.order_payments`. Instead, it identifies the order to which one or more payment records belong.

### 3. Validate `payment_sequential` uniqueness

The uniqueness check shows that `payment_sequential` values are repeated throughout the table. The value `1` occurs 99,360 times, while subsequent sequence values occur with progressively lower frequencies.

This confirms that `payment_sequential` is not globally unique. Its behaviour is consistent with a sequence that is meaningful within the context of an individual order rather than an identifier that uniquely identifies a payment record across the entire table.

### 4. Validate the composite `order_id` and `payment_sequential` grain

The combination of `order_id` and `payment_sequential` is tested to determine whether the same combination occurs more than once.

The result returns no repeated combinations.

This confirms that the combination of `order_id` and `payment_sequential` uniquely identifies the payment records within `staging.order_payments`. While neither identifier is unique independently, their combination provides a unique identifier for the row-level payment grain.

### 5. Summarise payment-record cardinality per order

The payment-record distribution provides a compact view of how many payment records are associated with individual orders.

| Payment records per order | Number of orders |
| ---: | ---: |
| 29 | 1 |
| 26 | 1 |
| 22 | 1 |
| 21 | 1 |
| 19 | 2 |
| 15 | 2 |
| 14 | 2 |
| 13 | 3 |
| 12 | 8 |
| 11 | 8 |
| 10 | 5 |
| 9 | 9 |
| 8 | 11 |
| 7 | 28 |
| 6 | 36 |
| 5 | 52 |

The distribution confirms that payment records operate at a finer grain than orders, with individual orders associated with varying numbers of payment records.

The difference between the number of distinct orders and the number of records with `payment_sequential = 1` is noted for further business-rule validation. The grain validation establishes the structure of the payment records but does not determine the reason for this difference.

## Overall Finding - Order Payments

The grain of `staging.order_payments` is established at the level of an individual payment record associated with an order.

`order_id` is not unique because an order can have multiple payment records. `payment_sequential` is also not globally unique and is meaningful within the context of an order. The combination of `order_id` and `payment_sequential` is unique across the staging table and therefore provides the row-level identifier for the payment grain.

The table contains 103,886 payment records associated with 99,440 distinct orders. The observed payment-record cardinality demonstrates that payment data operates at a finer grain than order-level data.

This distinction has an important modelling implication. Payment measures such as `payment_value` must be handled carefully when payment records are joined to other datasets containing multiple records per order, as incorrect joins could result in row multiplication and inflated payment totals.

The observed difference between distinct orders and records beginning with `payment_sequential = 1` is retained as a business-rule validation item rather than being resolved during grain validation.

## Orders

The `orders` dataset contains order-level records within the Olist e-commerce system. The primary identifiers examined are `order_id` and `customer_id`, while `order_status` represents an attribute of the order. Grain validation focuses on determining whether each row represents one order and establishing the relationship between orders and customers.

### 1. Establish table and identifier counts for Orders

The first step is to establish the total number of records and the distinct counts for the main order identifiers and attributes.

| Metric | Result |
| --- | ---: |
| Total rows | 99,441 |
| Distinct `order_id` | 99,441 |
| Distinct `customer_id` | 99,441 |
| Distinct order statuses | 8 |

The number of rows is equal to the number of distinct `order_id` values, indicating that each row contains a distinct order identifier. The number of distinct `customer_id` values also equals the number of rows, indicating that each customer identifier occurs once within the table.

The relationship between the two identifiers is examined separately to establish the order-to-customer cardinality.

### 2. Validate `order_id` uniqueness

The uniqueness check returns no records with repeated `order_id` values.

This confirms that `order_id` uniquely identifies records within `staging.orders`. Therefore, the table operates at an order-level grain, with each row representing one order.

### 3. Validate the `order_id` to `customer_id` relationship

The cardinality check returns no records where an `order_id` is associated with more than one distinct `customer_id`.

This establishes that each order is associated with one customer identifier within the `orders` table.

### 4. Validate the `customer_id` to `order_id` relationship

The reverse cardinality check shows that each `customer_id` is associated with one distinct `order_id` within `staging.orders`.

This establishes a one-to-one relationship between `customer_id` and `order_id` within this table. This finding should be interpreted at the identifier level represented by `customer_id` and should not be generalised to the broader customer identity represented elsewhere in the customer data.

### 5. Establish order-status cardinality

The order-status distribution identifies eight distinct statuses within the order-level table.

| Order status | Number of orders |
| --- | ---: |
| delivered | 96,478 |
| shipped | 1,107 |
| canceled | 625 |
| unavailable | 609 |
| invoiced | 314 |
| processing | 301 |
| created | 5 |
| approved | 2 |

The status distribution confirms that `order_status` functions as an attribute of the order-level record. The distribution itself does not establish whether the statuses are consistent with the associated order timestamps; such chronological and business-rule checks are reserved for later validation.

## Overall Finding - Orders

The grain of `staging.orders` is established at the level of one order per row.

`order_id` is unique across all 99,441 records and therefore serves as the row-level identifier for the table. Each `order_id` is associated with one `customer_id`, while each `customer_id` is associated with one `order_id` within this table.

The table contains eight distinct order statuses, with `delivered` representing the largest observed category at 96,478 orders.

The validated order-level grain provides an important reference point for the other transactional datasets. `order_items` and `order_payments` operate at finer grains and can contain multiple records associated with a single order. This distinction must be considered during subsequent relationship validation and analytical modelling to prevent incorrect joins and potential measure duplication.

## Order Reviews

The `order_reviews` dataset contains review records associated with orders in the Olist e-commerce system. The primary identifiers examined are `review_id` and `order_id`, while `review_score` represents an attribute of the review record. Grain validation focuses on determining what one row represents, whether either identifier is unique independently, and whether the combination of `review_id` and `order_id` uniquely identifies a record.

### 1. Establish table and identifier counts for order reviews

The first step is to establish the total number of records and the distinct counts for the main review identifiers and attributes.

| Metric | Result |
| --- | ---: |
| Total rows | 99,224 |
| Distinct `review_id` | 98,410 |
| Distinct `order_id` | 98,673 |
| Distinct `review_score` | 5 |

The table contains 99,224 review records, with 98,410 distinct `review_id` values and 98,673 distinct `order_id` values. The difference between the total number of rows and the distinct identifier counts indicates that both identifiers are repeated within the table.

There are five distinct `review_score` values, confirming that review scores function as attributes of the review records rather than as row-level identifiers.

### 2. Validate `review_id` uniqueness

The uniqueness check identifies repeated `review_id` values. Some `review_id` values occur three times within the table.

This confirms that `review_id` does not uniquely identify a row in `staging.order_reviews`.

The repeated values indicate that `review_id` must be interpreted together with other attributes when identifying an individual review record. The validation does not establish the reason why a `review_id` occurs across multiple records; determining the cause is outside the scope of grain validation.

### 3. Validate `order_id` repetition

The `order_id` repetition check identifies orders associated with multiple review records. Some orders occur three times, while others occur twice.

This confirms that `order_id` does not uniquely identify a row in `staging.order_reviews`.

Therefore, the review table operates at a finer grain than the order-level `orders` table.

### 4. Determine the `review_id` to `order_id` cardinality

The cardinality check shows that some `review_id` values are associated with three distinct `order_id` values.

This establishes that `review_id` does not uniquely identify an order within the review table. A single `review_id` value can occur in records associated with multiple orders.

The reason for this behaviour is not determined during grain validation and is therefore not interpreted as a business rule at this stage.

### 5. Determine the `order_id` to `review_id` cardinality

The reverse cardinality check shows that some `order_id` values are associated with multiple distinct `review_id` values, with some orders having three distinct review identifiers.

This confirms that one order can have multiple review records.

The relationship therefore operates as a one-to-many relationship from the order level to the review-record level.

### 6. Validate the `review_id` and `order_id` combination

The combination of `review_id` and `order_id` is tested to determine whether the same combination occurs more than once.

The result returns no repeated combinations.

This confirms that the combination of `review_id` and `order_id` uniquely identifies the records within `staging.order_reviews`.

While neither `review_id` nor `order_id` is unique independently, their combination provides a unique row-level identifier for the observed review grain.

## Overall Finding - Order Reviews

The grain of `staging.order_reviews` is established at the level of one review record associated with an order.

Neither `review_id` nor `order_id` uniquely identifies a row independently. `order_id` can be associated with multiple review records, while the same `review_id` can occur across records associated with multiple orders. The combination of `review_id` and `order_id` is unique across the staging table and therefore provides the row-level identifier for the observed review grain.

The table contains 99,224 review records associated with 98,673 distinct orders and 98,410 distinct review identifiers. There are five distinct review scores, which function as attributes of the review record.

The established review-level grain is important for subsequent relationship validation and analytical modelling. Because one order can have multiple review records, combining `order_reviews` with other datasets that also contain multiple records per order can result in row multiplication if the relationships are not handled at the appropriate grain.

The validation establishes the structural relationships present in the staging data but does not determine why some `review_id` values are associated with multiple orders. Any investigation into the business meaning or data-quality implications of this behaviour should be handled during later validation.

## Products — Grain Validation

The `products` dataset contains product-level information within the Olist e-commerce system. Grain validation was performed to establish what one row represents, determine whether `product_id` uniquely identifies a product, and examine the relationship between products and product categories.

### 1. Establish table and identifier counts for  Products

The first validation established the total number of records and the distinct counts for the primary product identifier and product category.

| Metric | Result |
| --- | ---: |
| Total rows | 32,951 |
| Distinct `product_id` | 32,951 |
| Distinct `product_category_name` | 73 |

The table contains 32,951 rows and 32,951 distinct `product_id` values. The matching counts indicate that each row corresponds to a distinct product.

There are 73 distinct non-null product category values. A separate category-level analysis identified 610 products with a `NULL` `product_category_name`.

### 2. Validate `product_id` uniqueness

The uniqueness check grouped records by `product_id` and searched for identifiers occurring more than once.

The query returned no results, confirming that no `product_id` occurs more than once in the staging table.

Therefore, `product_id` uniquely identifies each product record and can serve as the row-level identifier.

### 3. Investigate repeated product IDs

A further validation was designed to examine whether repeated `product_id` values represented identical or differing product attributes.

The query returned no results because no repeated `product_id` values were identified.

As a result, there are no repeated product records requiring further attribute-level comparison at the grain-validation stage.

### 4. Determine the `product_id` to `product_category_name` cardinality

The cardinality check examined whether a single product was associated with multiple distinct product categories.

The query returned no results, indicating that no product was associated with more than one distinct category value.

Therefore, each product maps to at most one `product_category_name` within the staging data.

This does not mean that every product has a category. Products with missing category information remain represented by `NULL` values.

### 5. Determine the `product_category_name` to `product_id` cardinality

The reverse cardinality analysis examined the number of distinct products associated with each product category.

The results show that product categories can contain multiple products. For example, the category `cama_mesa_banho` is associated with 3,029 distinct products.

A `NULL` category value is also associated with 610 products.

The `NULL` category values were retained rather than arbitrarily assigned to a category because the appropriate business interpretation of the missing category information has not yet been established. This can be investigated during subsequent data-quality or business-rule validation.

### Overall Finding - Products

The grain of `staging.products` is established at the **product level**:

> **1 row = 1 product**

`product_id` is unique across the staging table and therefore serves as the row-level identifier.

The established relationship between products and categories is:

> **One product → at most one product category**

while the reverse relationship is:

> **One product category → many products**

The dataset contains **32,951 products**, **73 distinct non-null product categories**, and **610 products with a `NULL` category value**.

The `NULL` category values have not been assigned an assumed category because their business meaning has not yet been established. This issue should be revisited during later validation.

The product-level grain will be used during subsequent relationship validation and data modelling to establish how products connect to transactional datasets such as `order_items`.
