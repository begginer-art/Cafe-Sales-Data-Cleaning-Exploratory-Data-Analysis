# Cafe Sales Data Cleaning & Exploratory Data Analysis 
This project demonstrates an end-to-end SQL workflow for cleaning, validating, and analyzing a café sales dataset containing 10,000 transactions.  
The objective was not only to prepare the data for analysis but also to answer practical business questions regarding product performance, category strategy, revenue trends, and data quality.

## **Executive Summary**

After cleaning 10,000 cafe transactions, the analysis found:

* Revenue grew 6.7% across the year.

* Food generated the highest revenue (38.8%).

* Drinks generated the highest transaction volume.

* Dessert drove most quarter-to-quarter revenue fluctuations.

* Top 5 products contributed ~50% of revenue.

* Revenue concentration was low, indicating a diversified menu.

* Sales changes were primarily driven by volume rather than pricing.

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

## **Dataset Source**

This project uses Dataset 1 (10,000 transactions) from the Sunrise Cafe Sales Dataset Series, a synthetic dataset intentionally designed with realistic data quality issues for practicing data cleaning and business analysis. The dataset contains placeholder values, inconsistent labels, missing data, and corrupted records that simulate common real-world data quality problems.

**Source:** https://github.com/beniii-data/dirty-cafe-dataset/

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

## **Analysis Scope**

Although the cleaned dataset contains 10,000 transactions, all revenue and quantity analyses were performed using 9,657 transactions.

The remaining 343 transactions (3.43%) were excluded because the three key analytical fields (`qty`, `price`and `total_spent`) could not be reliably reconstructed and therefore remained `NULL`.

Rather than imputing unsupported values or removing the records during cleaning, these transactions were preserved in the dataset but excluded only from analyses requiring sales metrics.

This approach maintains data integrity while ensuring that reported business metrics are based only on complete and reliable transaction data.

## Business Questions
**1. How did revenue change throughout the year?**

<p align="left">
<img width="680" height="365" alt="image" src="https://github.com/user-attachments/assets/7ec4c393-1f3f-4340-afec-e27278f4069d" />
</p>

*	Revenue increased from 211.7M in Q1 to 225.8M in Q4, representing an overall growth of 6.66% across the year.

*	Food and Drinks consistently generated the largest share of total revenue, providing relatively stable performance throughout the year. 

*	Dessert was the primary source of quarter-to-quarter revenue volatility. Strong Dessert performance drove revenue growth in Q2 and Q4, while its decline was the main reason for the overall revenue slowdown in Q3. 

*	Revenue fluctuations throughout the year were driven primarily by changes in sales volume, as product prices remained largely stable. 

*	The dataset does not include marketing, operational, or customer-level information, so the underlying causes of changes in demand cannot be confirmed.

**Quarter-by-Quarter Revenue Analysis**

<p align="left">
<img width="676" height="358" alt="image" src="https://github.com/user-attachments/assets/7d3dfdbf-be72-4ac3-9ce9-2cc8941b7db4" />
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




**2.How do product categories differ in revenue contribution, purchase frequency, and transaction value?**

Food is the highest value category per transaction, while Drinks is the highest frequency category.

We have two different categories that are valuable for two different reasons: Food and Drinks.

It's worth noting that while the dessert category comes last in revenue it still has a huge impact on our total revenue (close to 29%), so we shouldn't disregard it completely as those supplementary sales are really vital to our business

* Food category is our main leader for revenue since it leads the revenue by (341.8M, 38.8%) due to its high average transaction order value (113606.51)

* The drinks category on the other hand is the most frequent bought category and it leads all the categories in transaction count and quantity(3558 transactions, 8937 units, 36.95% of quantity)

* By AOV the food leads by a wide margin (113606.51 for food VS 83139.41 for dessert VS 79292.02 for drinks)

**3. Which products are the revenue drivers and how concentrated is that revenue?** 

<p align="left">
<img width="680" height="361" alt="image" src="https://github.com/user-attachments/assets/f113546c-0883-463d-8416-ca3db9d431be" />
</p>
The café generated 880.9M in revenue during 2023. Revenue is relatively well distributed across the menu, with no single product dominating sales.

The top five menu items generated approximately 50% of total revenue, while the top ten accounted for roughly 82%, indicating a diversified revenue mix.

* Caramel Machiato was the highest-revenue product, contributing 94.1M (10.69%) of total revenue. It was also the most frequently purchased item, accounting for 10.47% of all units sold despite ranking only 8th in average order value (AOV). It was also the only product whose price changed during the year.

* Beef Carbonara Pasta ranked second in revenue (77.6M, 8.81%) and had the highest AOV across the menu.

* Buttermilk Fried Chicken ranked third in revenue (73.1M, 8.30%) and had the second-highest AOV.

**Business Insight**

The three highest-performing products generate revenue through different mechanisms:

* Caramel Machiato succeeds through high sales volume.

* Beef Carbonara Pasta and Buttermilk Fried Chicken succeed through higher transaction value rather than purchase frequency.

This distinction suggests that a single promotional strategy is unlikely to maximize revenue across all top-performing products.

**Recommendation**
* Focus on maintaining purchase volume for Caramel Machiato through visibility and customer engagement.

* Preserve the premium positioning of Beef Carbonara Pasta and Buttermilk Fried Chicken, as discounting could reduce the price advantage that drives their performance.

* Because this dataset contains only transaction-level sales data, the effectiveness of specific promotional strategies cannot be validated without additional information such as marketing campaigns, customer segments, or channel performance.

**4. How do customers order and pay?**

**Payment Methods**

<img width="556" height="362" alt="image" src="https://github.com/user-attachments/assets/0f08b040-3b0a-4acb-8de7-48ea71e7261d" />

* Revenue was relatively evenly distributed across the identified payment methods. Debit Card generated the largest share at 32.75%, closely followed by Digital Wallet at 31.87%, while Cash accounted for 18.84%. No recorded payment method clearly dominates revenue.

* 16.55% of revenue is associated with uncategorized payment methods, which limits the reliability of conclusions

**Order Types**

<img width="560" height="362" alt="image" src="https://github.com/user-attachments/assets/6764cb42-6e15-4e40-8bf0-83c0a8f0cea2" />

* Order type revenue was relatively evenly distributed across the three identified channels: Dine In (28.79%), Take Away (28.53%), and Online Order (27.60%). No single order type generated a substantially larger share of revenue. However, 15.09% of revenue is associated with uncategorized order types, which limits the reliability of conclusions about channel performance.

* The available data does not indicate that one order channel should be prioritized over the others based on revenue alone. Improving the completeness of order-type data would be valuable before making channel-specific investment decisions.

