-- ============================================================================
-- CAFE SALES — DATA CLEANING
-- ============================================================================


-- ============================================================================
-- 1. MENU_ID CLEANING
-- ============================================================================
-- Investigated invalid menu_id values.
-- Used valid menu -> menu_id relationships.
-- Updated only invalid values using the dominant mapping.

WITH menu_map AS (
    SELECT
        menu,
        menu_id,
        ROW_NUMBER() OVER (
            PARTITION BY menu
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM cafe_sales
    WHERE LOWER(menu) NOT IN ('missing', 'nan', 'unknown', 'error')
      AND LOWER(menu_id) NOT IN ('missing', 'nan', 'unknown', 'error')
    GROUP BY menu, menu_id
)
UPDATE cafe_sales c
JOIN menu_map m
    ON c.menu = m.menu
    AND m.rn = 1
SET c.menu_id = m.menu_id;


-- ============================================================================
-- 2. MENU NAME CLEANING
-- ============================================================================
-- Recovered missing menu values using valid menu_id mappings.

WITH item_map AS (
    SELECT DISTINCT menu, menu_id
    FROM cafe_sales
    WHERE LOWER(menu) NOT IN ('missing', 'nan', 'unknown', 'error')
      AND LOWER(menu_id) NOT IN ('missing', 'nan', 'unknown', 'error')
)
UPDATE cafe_sales c1
JOIN item_map c2
    ON c1.menu_id = c2.menu_id
SET c1.menu = c2.menu
WHERE LOWER(c1.menu) IN ('missing', 'nan', 'unknown', 'error');


-- ============================================================================
-- 3. TRANSACTION DATE CLEANING
-- ============================================================================
-- Invalid dates were converted to NULL instead of deleting rows.
-- Reason: other transaction information is still valuable.

UPDATE cafe_sales
SET transaction_date = NULL
WHERE LOWER(transaction_date) IN ('missing', 'nan', 'unknown', 'error');


-- ============================================================================
-- 4. CATEGORY CLEANING
-- ============================================================================
-- Tested menu -> category relationship.
-- Found Caramel Machiato had multiple categories:
--   Drinks:  689
--   Dessert: 124
--   Food:    106
--
-- Decision:
-- Standardize Caramel Machiato to Drinks because it is the dominant category.

UPDATE cafe_sales
SET category = 'Drinks'
WHERE menu = 'Caramel Machiato';


WITH category_map AS (
    SELECT
        menu,
        menu_id,
        category,
        ROW_NUMBER() OVER (
            PARTITION BY menu
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM cafe_sales
    WHERE LOWER(category) NOT IN ('nan', 'unknown', 'error', 'missing')
    GROUP BY menu, menu_id, category
)
UPDATE cafe_sales c
JOIN category_map m
    ON c.menu = m.menu
    AND c.menu_id = m.menu_id
    AND m.rn = 1
SET c.category = m.category
WHERE c.category IS NULL;


-- ============================================================================
-- 5. MENU AND MENU_ID BOTH INVALID
-- ============================================================================
-- No reliable information exists to recover these rows.

UPDATE cafe_sales
SET menu = NULL,
    menu_id = NULL
WHERE LOWER(menu) IN ('missing', 'nan', 'unknown', 'error')
  AND LOWER(menu_id) IN ('missing', 'nan', 'unknown', 'error');


-- ============================================================================
-- 6. QUANTITY CLEANING
-- ============================================================================
-- Found business rule:
--   qty * price = total_spent
--
-- Validation showed 100% matching rate.
-- Used this relationship to recover missing quantities.

UPDATE cafe_sales
SET qty = NULL
WHERE LOWER(TRIM(qty)) IN ('nan', 'unknown', 'error', 'missing', '');

UPDATE cafe_sales
SET price = NULL
WHERE LOWER(TRIM(price)) IN ('nan', 'unknown', 'error', 'missing', '');

UPDATE cafe_sales
SET total_spent = NULL
WHERE LOWER(TRIM(total_spent)) IN ('nan', 'unknown', 'error', 'missing', '');

UPDATE cafe_sales
SET qty = total_spent / price
WHERE qty IS NULL
  AND price IS NOT NULL
  AND total_spent IS NOT NULL
  AND price <> 0;

SELECT *
FROM cafe_sales
WHERE qty IS NULL;

SELECT
    CASE
        WHEN price IS NULL AND total_spent IS NULL THEN 'Missing price and total_spent'
        WHEN price IS NULL THEN 'Missing price'
        WHEN total_spent IS NULL THEN 'Missing total_spent'
    END AS reason,
    COUNT(*) AS cnt
FROM cafe_sales
WHERE qty IS NULL
GROUP BY reason;


-- ============================================================================
-- 7. PRICE CLEANING
-- ============================================================================
-- Using the same formula to find a valid price for those null values:
--   price = total_spent / qty
-- Found 1192 rows that have price as a null value.

SELECT COUNT(*)
FROM cafe_sales
WHERE price IS NULL;

-- Updating all price null values

UPDATE cafe_sales
SET price = (total_spent / qty)
WHERE price IS NULL
  AND qty IS NOT NULL
  AND total_spent IS NOT NULL
  AND qty <> 0;

SELECT
    CASE
        WHEN qty IS NULL AND total_spent IS NULL THEN 'Missing qty and total_spent'
        WHEN qty IS NULL THEN 'Missing qty'
        WHEN total_spent IS NULL THEN 'Missing total_spent'
        WHEN qty = 0 THEN 'qty is zero'
    END AS reason,
    COUNT(*) AS cnt
FROM cafe_sales
WHERE price IS NULL
GROUP BY reason;
-- we got 169 rows where price is null that we can't recover because we are missing total spent
-- these have qty but couldn't be recovered because total_spent itself is also missing


-- ============================================================================
-- 8. TOTAL_SPENT CLEANING
-- ============================================================================
-- Using the same formula to find a valid total spent for those null values:
--   total_spent = price * qty
-- Found 1540 rows that have total_spent as a null value.

SELECT COUNT(*)
FROM cafe_sales
WHERE total_spent IS NULL;

-- 1197 values are recoverable

SELECT COUNT(*)
FROM cafe_sales
WHERE total_spent IS NULL
  AND price IS NOT NULL
  AND qty IS NOT NULL;

-- Updating all total_spent null values

UPDATE cafe_sales
SET total_spent = (price * qty)
WHERE total_spent IS NULL
  AND qty IS NOT NULL
  AND price IS NOT NULL;

SELECT
    COUNT(*),
    SUM(CASE WHEN qty = 0 THEN 1 ELSE 0 END) AS zero_qty,
    SUM(CASE WHEN price IS NULL OR qty IS NULL THEN 1 ELSE 0 END) AS non_recoverable
FROM cafe_sales
WHERE total_spent IS NULL;
-- 343 non recoverable


-- ============================================================================
-- 9. PAYMENT_METHOD CLEANING
-- ============================================================================
-- Found 1655 invalid values.

SELECT COUNT(*)
FROM cafe_sales
WHERE LOWER(TRIM(payment_method)) IN ('nan', 'unknown', 'error', 'missing', '')
  AND payment_method IS NOT NULL;

-- Updating all invalid values to null values

UPDATE cafe_sales
SET payment_method = NULL
WHERE LOWER(TRIM(payment_method)) IN ('nan', 'unknown', 'error', 'missing', '')
  AND payment_method IS NOT NULL;


-- ============================================================================
-- 10. ORDER_TYPE CLEANING
-- ============================================================================
-- couldn't find the dirty data values in order_type

SELECT *
FROM cafe_sales
WHERE LOWER(TRIM(order_type)) IN ('nan', 'unknown', 'error', 'missing', '')
  AND order_type IS NOT NULL;

-- checking the length of those words

SELECT DISTINCT
    order_type,
    LENGTH(order_type),
    LENGTH(TRIM(order_type))
FROM cafe_sales
ORDER BY order_type;
-- there's some hidden characters
-- using like function

SELECT *
FROM cafe_sales
WHERE order_type IS NULL
   OR order_type = ''
   OR LOWER(TRIM(order_type)) LIKE '%nan%'
   OR LOWER(TRIM(order_type)) LIKE '%unknown%'
   OR LOWER(TRIM(order_type)) LIKE '%error%'
   OR LOWER(TRIM(order_type)) LIKE '%missing%';
-- found 1479 dirty values

SELECT COUNT(*)
FROM cafe_sales
WHERE order_type IS NULL
   OR order_type = ''
   OR LOWER(TRIM(order_type)) LIKE '%nan%'
   OR LOWER(TRIM(order_type)) LIKE '%unknown%'
   OR LOWER(TRIM(order_type)) LIKE '%error%'
   OR LOWER(TRIM(order_type)) LIKE '%missing%';

-- updating invalid values to null values

UPDATE cafe_sales
SET order_type = NULL
WHERE order_type IS NULL
   OR order_type = ''
   OR LOWER(TRIM(order_type)) LIKE '%nan%'
   OR LOWER(TRIM(order_type)) LIKE '%unknown%'
   OR LOWER(TRIM(order_type)) LIKE '%error%'
   OR LOWER(TRIM(order_type)) LIKE '%missing%';

-- checking if all invalid values were updated successfully

SELECT COUNT(*)
FROM cafe_sales
WHERE order_type IS NULL;


-- ============================================================================
-- 11. CHANGE COLUMN TYPE (transaction_date) TO DATE
-- ============================================================================
-- Convert valid strings to DATE values

UPDATE cafe_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d/%m/%Y')
WHERE transaction_date IS NOT NULL;

ALTER TABLE cafe_sales
MODIFY COLUMN transaction_date DATE;


