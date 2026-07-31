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
| Order type        | Converted placeholder values to NULL                                          |

## Initial Data Quality Issues

The dataset contained several quality problems that required cleaning before analysis:
* Placeholder values (missing, nan, unknown, error)
* Missing menu names and menu IDs
* Invalid transaction dates
* Missing quantity, price, and total transaction values
* Inconsistent category assignments
* Hidden characters in `order_type` column
* Incomplete payment method and order type values

Rather than deleting records, recoverable values were reconstructed using validated business rules, while unrecoverable values were preserved as `NULL`.

## Data Quality Summary
| Column      | Fixed | Remaining |
| ----------- | ----: | --------: |
| `menu`      |   410 |       113 |
| `menu_id`   |   384 |       113 |
| `qty`       |  1340 |       174 |
| `price`     |  1023 |       169 |
|`total_spent`|  1197 |       343 |

## Business Questions
**1. How did revenue change throughout the year?**

*	Revenue increased from 211.7M in Q1 to 225.8M in Q4, representing an overall growth of 6.66% across the year.

*	Food and Drinks consistently generated the largest share of total revenue, providing relatively stable performance throughout the year. 

*	Dessert was the primary source of quarter-to-quarter revenue volatility. Strong Dessert performance drove revenue growth in Q2 and Q4, while its decline was the main reason for the overall revenue slowdown in Q3. 

*	Revenue fluctuations throughout the year were driven primarily by changes in sales volume, as product prices remained largely stable. 

*	The dataset does not include marketing, operational, or customer-level information, so the underlying causes of changes in demand cannot be confirmed.
<p align="center">
<img width="677" height="361" alt="image" src="https://github.com/user-attachments/assets/7f2ba5cd-7091-4d4c-be1f-5d5f8b0d25f7" />
</p>

**Q1 → Q2: Moderate Growth (+3.3%)**

Revenue increased by 6.9M (+3.3%). Dessert was the primary growth driver, contributing approximately 3.47M (50%) of the total quarterly revenue increase.

The category's growth was concentrated in its two best-performing products:

*	New York Cheesecake: Revenue increased by 28.36%, driven by higher sales volume.

*	Classic Tiramisu: Revenue increased by 10.73%, also driven by higher sales volume. 
This indicates that the improvement in Dessert performance was largely demand-driven rather than price-driven.

**Q2 → Q3: Slight Decline (-1.0%)**

Revenue declined by 1.0%, primarily because Dessert revenue fell by 6.5%. Although Food (+1.4%) and Drinks (+2.2%) continued to grow, their gains were insufficient to offset the decline in Dessert.

The decrease in Dessert revenue was concentrated in its two highest-performing products, both of which experienced revenue declines of more than 16%. Since prices remained unchanged during this period, the decline appears to have been driven by lower sales volume rather than pricing.

Food also showed weaker performance during the quarter. Beef Carbonara Pasta, the category's highest-revenue product, declined by 11.89%. However, this was partially offset by strong growth in Grill Chicken Caesar Salad (+9.84%) and Nasi Goreng Kampung (+19.08%), limiting the overall impact on the Food category.
Further Investigation

The available dataset cannot explain why demand declined during this period. Additional business information would be required, such as:

*	Marketing or promotional campaigns 

*	Changes in menu placement or product visibility 

*	Seasonal or external factors affecting customer demand 

*	Product availability or operational issues

**Q3 → Q4: Strong Recovery (+4.4%)**
 	
Revenue rebounded by 4.4%, representing the strongest quarterly growth of the year. The recovery was driven primarily by Dessert (+10.6%) and supported by continued growth in Drinks (+5.4%).

Dessert recovered as New York Cheesecake and Classic Tiramisu returned to growth, while Choco Lava Cake also posted a strong revenue increase of 17.77%. Across the category, revenue growth was driven by increased sales volume rather than price changes.
 
Although Food remained the highest-revenue category overall, it recorded its first quarterly revenue decline. This was largely associated with Beef Carbonara Pasta remaining below its earlier performance level, while Grill Chicken Caesar Salad was unable to sustain the strong growth observed in the previous quarter.




**2. Which product category should the business prioritize?**

Food is the highest value category per transaction, while Drinks is the highest frequency category.

We have two different categories that are valuable for two different reasons: Food and Drinks.

It's worth noting that while the dessert category comes last in revenue it still has a huge impact on our total revenue (close to 29%), so we shouldn't disregard it completely as those supplementary sales are really vital to our business

* Food category is our main leader for revenue since it leads the revenue by (341.8M, 38.8%) due to its high average transaction order value (113606.51)

* The drinks category on the other hand is the most frequent bought category and it leads all the categories in transaction count and quantity(3558 transactions, 8937 units, 36.95% of quantity)

* By AOV the food leads by a wide margin (113606.51 for food VS 83139.41 for dessert VS 79292.02 for drinks)


**3. Which products are the revenue drivers and how concentrated is that revenue?** 

Our total Revenue is 880,934,000 which is broadly balanced across the menu with no overwhelming dominant item, but the top three items reveal two distinct paths to revenue: volume (Caramel Machiato) and price (Beef Carbonara Pasta and Buttermilk Fried Chicken), which matters because it means a single promotional strategy won't suit all the top performers.

* Caramel Machiato is the top item driving the revenue with more than 94M in total revenue (10.69%), it's also the most bought item with over 2500 units sold (10.47% of total quantity percentage), it ranks 8 in average transaction_order_value through the menu, it's worth noting this is also the only item with a price change

* Beef Carbonara Pasta comes second in overall revenue with more than 77M (8.81%) and it comes first overall in AOV per transaction (129609.35)

* Buttermilk Fried Chicken is the third ranking item bringing in more than 73M (8.3%) in revenue and its also ranks the second in AOV per transaction (120434.93)

* Revenue share ranges from 10.69% down to 3.85% across items, with most adjacent items within 1% of each other. The only notable break in that pattern is a 1.88% gap between Caramel Machiato (the top item) and the next-ranked item, suggesting Caramel Machiato is a mild standout rather than a dominant outlier.

* Because the high-AOV items earn their revenue through price rather than volume, discount-driven promotions risk undercutting the very thing that makes them valuable. A non-discount lever (e.g. visibility/awareness) may be a better fit — though this dataset (transaction records only, no marketing or channel data) can't confirm which promotional approach would actually work.
  



