create database orders;
use orders;
select * from orders;
create table new_order(   -- for converting to lowercase and spaces replacing with underscores
order_id INT,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    cost_price  INT,
    list_price  INT,
    quantity INT,
    discount_percent INT
   
);

-- Copy data from old table to new table
INSERT INTO new_order(order_id, order_date, ship_mode, segment, country, city, state, postal_code, region, 
category, sub_category, product_id, cost_price, list_price, quantity, discount_percent)
SELECT `Order Id`, `Order Date`, `Ship Mode`, `Segment`, `Country`, `City`, `State`, `Postal Code`, `Region`, 
`Category`, `Sub Category`, `Product Id`, `cost price`, `List Price`, `Quantity`, `Discount Percent`
FROM orders;

DROP TABLE ORDERS; --  Drop the old table

ALTER TABLE NEW_ORDER RENAME TO ORDERS; -- Rename the new table to the old table name

SELECT * FROM ORDERS;

select distinct(ship_mode) from orders;
update orders set ship_mode=null where ship_mode in ("not available","unknown","n/a");

select date_format(order_date,"%y-%m-%d") from orders;

alter table orders add column discount DECIMAL(7,2);
update orders set discount=(list_price*discount_percent/100);

alter table orders add column sale_price int;
update orders set sale_price=(list_price-discount);

alter table orders add column profit int;
update orders set profit=(sale_price-cost_price);

-- delete unnecessary columns from the table
alter table orders drop column discount_percent, 
drop column cost_price,
drop column list_price;

-- ⏺️⏺️ Data analysis And Retrieve meaningful insights through SQL queries ⏺️⏺️

-- Find top 10 highest revenue generating products.
select product_id,sum(sale_price) as revenue from orders group by product_id order by revenue desc limit 10;

-- Find top 5 highest selling products in each region.
with cte as (select region,product_id,sum(sale_price)as sale from orders group by product_id,region)
select * from (select *,row_number() over(partition by region order by sale desc)as top_5 from cte) as B where top_5<=5;

-- Find month over month growth comparsion for 2022 & 2023 sales eg: jan 2022 vs jan 2023.
with cte as(select month(order_date) as month_order,year(order_date)as year_order ,sum(sale_price) as sale from orders group by month_order,year_order)
select month_order,
sum(case when year_order=2022 then sale else 0 end)as sale_2022,
sum(case when year_order=2023 then sale else 0 end)as sale_2023
from cte group by month_order order by month_order;

-- for each category which month had highest sales.
with cte as (select category,month(order_date) as month_order ,year(order_date)as year_order,sum(sale_price) as sales from orders group by category,month_order,year_order)
select * from (select *,row_number() over(partition by category order by sales)as top_1 from cte)as B where top_1<=1;

-- which sub category had highest growth by profit in 2023 compare to 2022.
with cte as(select sub_category,year(order_date) as order_year , sum(sale_price) as sales from orders group by  order_year, sub_category)
,cte2 as(select sub_category,
sum(case when order_year=2022 then sales else 0 end)as sales_2022,
sum(case when order_year=2023 then sales else 0 end)as sales_2023
from cte group by sub_category )
select * , (sales_2023-sales_2022)as profit_compare_2023_2022 from cte2 order by profit_compare_2023_2022  desc limit 1;


 /* Conclusion 🔘🔘
The analysis reveals that TEC-CO-10004722 is the highest revenue-generating product in the Central, East, and West regions.
In terms of profitability, January, June, August, andSeptember 2022 had higher profits compared to January 2023, but overall, 
2023 generated more profit than 2022. Among product categories, Furniture and Office Supplies had the highest sales in June 2023,
while Technology recorded the highest sales in July 2022. Additionally,the Machine category was the most profitable in 2023 compared to 2022.

Recommendation 🔘🔘
- Focus on TEC-CO-10004722 – Since it performs well in multiple regions.
- Boost Sales During Peak Months – Implement targeted promotions and discounts during peak months to maximize profit.
- Optimize Machine Category – They had the highest profits in 2023.
- Compare Yearly Trends – Continue monitoring sales and profit trends to identify new growth opportunities and improve future business strategies.
