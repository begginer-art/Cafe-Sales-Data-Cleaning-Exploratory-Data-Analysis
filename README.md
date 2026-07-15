# Cafe Sales Data Cleaning & Exploratory Data Analysis 
This project demonstrates an end-to-end SQL workflow for cleaning, validating, and analyzing a café sales dataset containing 10,000 transactions.  
The objective was not only to prepare the data for analysis but also to answer practical business questions regarding product performance, category strategy, revenue trends, and data quality.
## Business Problem

The cafe has one year of transaction-level sales data, but the dataset contains missing values, inconsistent labels, placeholder values (missing, nan, error, unknown), and invalid records.

The goal is to:

• Clean and validate the dataset

• Recover missing values where possible

• Preserve unrecoverable information as NULL

• Analyze sales performance

• Generate business recommendations supported by data
Dataset

This project uses a café sales dataset containing 10,000 transaction-level records covering the period from January 2023 to December 2023.

Each row represents a single customer transaction and includes information about the purchased menu item, quantity, price, payment method, order type, and transaction date.

## Dataset characteristics

| Attribute         | Description                          |
| ----------------- | ------------------------------------ |
| Time Period       | January 2023 – December 2023         |
| Number of Records | 10,000 transactions                  |
| Granularity       | One row per transaction              |
| Primary Key       | `transaction_id`                     |
| Main Entities     | Menu items, categories, transactions |

## Key Columns
| Column             | Description                              |
| ------------------ | ---------------------------------------- |
| `transaction_id`   | Unique transaction identifier            |
| `transaction_date` | Date of purchase                         |
| `menu`             | Purchased menu item                      |
| `category`         | Product category (Food, Drinks, Dessert) |
| `menu_id`          | Menu item identifier                     |
| `qty`              | Quantity purchased                       |
| `price`            | Unit price                               |
| `total_spent`      | Total amount paid                        |
| `payment_method`   | Payment method used                      |
| `order_type`       | Dine In, Take Away, or Online Order      |


## Data Cleaning
Every recovery rule was validated before updates were applied.

| Step              | Description                                                                   |
| ----------------- | ----------------------------------------------------------------------------- |
| Menu mapping      | Recovered invalid menu_id values using validated menu → menu_id relationships |
| Menu recovery     | Filled missing menu names using menu_id                                       |
| Category cleaning | Standardized inconsistent categories after validating dominant mappings       |
| Transaction dates | Converted invalid dates to NULL and standardized DATE format                  |
| Quantity          | Recovered using qty = total_spent ÷ price                                     |
| Price             | Recovered using price = total_spent ÷ qty                                     |
| Total spent       | Recovered using total_spent = qty × price                                     |
| Payment method    | Converted placeholder values to NULL                                          |
| Order type        | Removed hidden invalid placeholder values                                     |

## Initial Data Quality Issues

The dataset contained several quality problems that required cleaning before analysis:

Placeholder values (missing, nan, unknown, error)

Missing menu names and menu IDs

Invalid transaction dates

Missing quantity, price, and total transaction values

Inconsistent category assignments

Hidden characters in categorical fields

Incomplete payment method and order type values

Rather than deleting records, recoverable values were reconstructed using validated business rules, while unrecoverable values were preserved as `NULL`.
