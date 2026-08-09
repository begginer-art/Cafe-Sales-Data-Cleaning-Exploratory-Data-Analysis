-- Exploratory Data Analysis
-- -------------------------------------------------
-- timeframe for our dataset
select min(transaction_date),max(transaction_date)
from cafe_sales;
-- -------------------------------------------------
-- checking if every transaction_id is unique
select transaction_id ,count(*)
from cafe_sales 
group by 1 
having count(*)>1;
 --  all of our transaction_id are unique
 -- -------------------------------------------------
 -- count of null values in menu 
select count(*) 
from cafe_sales 
where menu is null ;
-- there is 113 rows where menu is null 
-- -------------------------------------------------
-- exploring the menu 
select distinct category , menu
from cafe_sales
where category is not null and menu is not null
order by category ;
-- Menu contain 15 items
-- -------------------------------------------------
-- number of items by category 
select category , count(distinct menu) item_count
from cafe_sales
where category is not null 
group by  category;
-- every category have 5 items 
-- -------------------------------------------------
-- menu_price history 
select menu , count(distinct price ) distinct_prices   
from cafe_SALES  
where menu is not null and price is not null 
group by menu 
having distinct_prices > 1 ; 
-- only caramel machiato price changed over time 
-- Caramel machiato price change history
with caramel_machiato_price_change as (
select distinct transaction_date, menu, price ,dense_rank()OVER(partition by menu, price order by transaction_date) rn 
from cafe_sales
where menu = 'Caramel Machiato' and price is not null and transaction_date is not null )
select *  
from caramel_machiato_price_change
where rn = 1; 
-- first and last price change for Caramel machiato 
select price ,min(transaction_date) first_seen ,max(transaction_date) last_seen 
from cafe_sales 
where menu = 'Caramel Machiato' and price is not null and transaction_date is not null
group by price ;
--
select  coalesce(date_format(transaction_date,'%Y-%m'),'Mixed months') year_mnth ,sum(total_spent) total_revenue
from cafe_sales
where menu = 'Caramel Machiato'
group by year_mnth
order by year_mnth
;
-- -------------------------------------------------
	--  #1 What drives revenue?
-- -------------------------------------------------
-- total revenue
select sum(total_spent) total_revenue
from cafe_sales ;
-- 	total revenue is 880,934,000 
-- -------------------------------------------------
-- revenue by months
select coalesce(date_format(transaction_date,'%Y-%m'),'Mixed months') year_mnth ,sum(total_spent) total_revenue
from cafe_sales 
group by year_mnth
order by year_mnth	;
-- -------------------------------------------------
	-- which menu item generate most revenue?
select count(*)
from cafe_sales 
where qty is  null and total_spent is  null ;
-- we have found 174 rows where qty is null and total_spent is null  from the 10000 rows that we have (1.74%)
-- creating a view that include all the important metrics for menu analysis 
CREATE OR REPLACE VIEW menu_performance as(
with menu_agg  AS(
select coalesce(menu,'Mixed menu items') menu,
count(*)count_of_transactions,
sum(qty) quantity ,
sum(total_spent) revenue,
 round(avg(total_spent),2) avg_transaction_order_value
from cafe_sales 
where qty is not null and total_spent is not null 
group by menu
order by revenue desc )

select 
* ,ROUND((quantity*100/sum(quantity)OVER()),2)qty_perc,ROUND((revenue*100/sum(revenue)OVER()),2)revenue_perc
from menu_agg  );
 ;
  select *,round((revenue_perc-lead (revenue_perc) over (order by revenue_perc desc)),2) revenue_perc_gap,round((sum(revenue_perc)OVER(order by revenue_perc desc)),1) 'sum of revenue percentage by the number of items based on their revenue desc',
    dense_rank()over(order by revenue desc) 'revenue_rank'
from menu_performance ; 
-- Using the created menu_performance view, the top 3 items that drive revenue are : 'Caramel Machiato','Beef Carbonara Pasta' and 'Buttermilk Fried Chicken' with 'Caramel Machiato' as our clear top item
-- -------------------------------------------------
-- Average order value (AOV) ranking 
select *, dense_rank() over (order by avg_transaction_order_value desc) as aov_rank
from menu_performance 
order by avg_transaction_order_value desc;
-- -------------------------------------------------
-- average quantity per transaction
select menu ,round((sum(qty)/count(*)),2) avg_qty_per_transaction 
from cafe_sales 
where qty is not null and total_spent  is not null and menu is not null 
group by menu 
order by avg_qty_per_transaction  desc;
-- -------------------------------------------------
-- #2 Which category deserves more focus
-- -------------------------------------------------
-- Category performance
-- creating a view that include all the important metrics for category analysis 
create view category_performance  as  (
with category_agg as(
select coalesce(category, 'Uncategorized') category ,
count(*)count_of_transactions, 
sum(qty) quantity ,
sum(total_spent) revenue,
 round(avg(total_spent),2) avg_transaction_order_value
from cafe_sales 
where qty is not null and total_spent is not null 
group by category	
order by revenue desc )

select 
* ,ROUND((quantity*100/sum(quantity)OVER()),2)qty_perc,ROUND((revenue*100/sum(revenue)OVER()),2)revenue_perc
from category_agg); 
select *
from category_performance;
-- to decide which category deserve  more focus that will depend on the the  result that the business owner want
-- -------------------------------------------------
-- categories by year_month (total quantity&revenue)
select date_format(transaction_date,'%Y-%m') year_mnth , category, sum(qty) total_qty , sum(total_spent) revenue
from cafe_sales 
where transaction_date is not null and category is  not null  
group by year_mnth ,category
order by category,year_mnth  ;
 -- ------------------------------------------------
 -- 3. Monthly revenue trend 
 -- -------------------------------------------------
with monthly_rev as (
 SELECT date_format(transaction_date,'%Y-%m') as year_mnth , sum(total_spent) monthly_revenue 
 from cafe_sales 
 where total_spent is not null and transaction_date is not null  
 group by 1
 order by 1),
 monthly_rev_lag as (
 select year_mnth ,monthly_revenue,lag(monthly_revenue)OVER(order by year_mnth) prev_monthly_revenue
 from monthly_rev)

 select *,ROUND(((monthly_revenue-prev_monthly_revenue)*100/prev_monthly_revenue),2) monthly_rev_perc
 from monthly_rev_lag;
-- revenue isn't showing a clear upward or downward trend, the last 3 months are worth further investigation 
-- -------------------------------------------------
 -- Monthly quantity trend 
 -- since the price haven't change at all for the other items except for Caramel Machiato 
 with monthly_qty as (
 SELECT date_format(transaction_date,'%Y-%m') as year_mnth , sum(qty) monthly_qty
 from cafe_sales 
 where qty is not null and transaction_date is not null  
 group by 1
 order by 1),
 monthly_qty_lag as (
 select year_mnth ,monthly_qty,lag(monthly_qty)OVER(order by year_mnth) prev_monthly_qty
 from monthly_qty)
 select *,ROUND(((monthly_qty-prev_monthly_qty)*100/prev_monthly_qty),2) monthly_qty_perc
 from monthly_qty_lag;
-- -------------------------------------------------
 -- 4. Seasonal patterns by category/item
-- -------------------------------------------------
-- top 3 month by revenue in each category 
 with peak_months as (
 select date_format(transaction_date,'%Y-%m') year_mnth,category,sum(total_spent )  revenue ,dense_rank()over(partition by category order by sum(total_spent ) desc)  rn 
 from cafe_sales 
 where transaction_date is not null and category is not null  and total_spent is not null 
 group by year_mnth,category
 order by revenue desc)
 select *,count(year_mnth)over(Partition by year_mnth) cnt
 from peak_months 
 where rn <=3
 order by 2 desc,3 desc ;
 -- october and december appear in all the 3 categories 
 --
 select count(*)
from cafe_sales 
 where total_spent is null and transaction_date is not null and category is not null ;
 -- making sure that those unrecoverable rows of total spent isn't all concentrated  in one month
 select date_format(transaction_date ,'%Y-%m') year_mnth ,category, count(*) unrecoverable
 from cafe_sales 
 where total_spent is null and transaction_date is not null and category is not null 
 group by 1,2 
 order by 3 desc ; 
 ;
 -- -------------------------------------------------
 -- 5. unattributed revenue
 -- -------------------------------------------------
  -- 10260000 of revenue we don't know which item it belongs 
   select sum(total_spent)
 from cafe_sales 
 where menu is null and total_spent is not null   ;
 -- count  of null values in  menu column (113)
 -- which come to 1.13% of our total rows
 select count(*)
 from cafe_sales 
 where menu is null and total_spent is not null ; 
 
 -- -------------------------------------------------
 -- 6.Transaction & Ordering Behavior
  -- -------------------------------------------------
  
-- which order type does our the customer prefer ?
select coalesce(order_type,'Uncategorize') order_type, count(*) transaction_count ,round(count(*)*100/sum(count(*)) over(),2)transaction_pct,
round(avg(total_spent),2) average_transaction_value , sum(total_spent) revenue,round(sum(total_spent)*100/sum(sum(total_spent)) over(),2)revenue_pct
from cafe_sales 
where total_spent is not null 
group by order_type
order by revenue desc;

-- which payment methode does customers prefer the most
select coalesce(payment_method,'Uncategorize') payment_method, count(*) transaction_count ,round(count(*)*100/sum(count(*)) over(),2)transaction_pct,
round(avg(total_spent),2) average_transaction_value , sum(total_spent) revenue,round(sum(total_spent)*100/sum(sum(total_spent)) over(),2)revenue_pct
from cafe_sales 
where total_spent is not null 
group by payment_method
order by revenue desc

