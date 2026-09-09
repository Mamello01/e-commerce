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
