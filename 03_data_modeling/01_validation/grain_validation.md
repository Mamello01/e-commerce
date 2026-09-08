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

## Overall Finding

The grain of `staging.customers` is established at the `customer_id` level, with each row representing one unique `customer_id` record.

`customer_id` is unique across all 99,441 rows, while `customer_unique_id` is not unique and can be associated with multiple `customer_id` values. Each `customer_id`, however, maps to exactly one `customer_unique_id`.

The two identifiers therefore operate at different levels of granularity. `customer_id` is the appropriate row-level identifier for `staging.customers`, while `customer_unique_id` represents a broader customer identity that may span multiple customer records.

This distinction is important for subsequent relationship validation and analytical modelling, as `customer_unique_id` should not be treated as the unique key of the staging table or used as though it uniquely identifies each row.
