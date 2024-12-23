CREATE DATABASE sales_coffee_database;

SELECT * FROM coffee_shop_sales;

DESCRIBE coffee_sales_data;

SELECT COUNT(*) AS total_rows 
FROM coffee_sales_data;	

-- Changing the date format and converting it into DATE type
UPDATE coffee_sales_data
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

ALTER TABLE coffee_sales_data
MODIFY COLUMN transaction_date DATE;

-- Changing the time format and converting it into TIME type
UPDATE coffee_sales_data
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_sales_data
MODIFY COLUMN transaction_time TIME;

DESCRIBE coffee_sales_data;

SELECT MONTH(transaction_date) AS Month_Num,
ROUND(SUM(transaction_qty*unit_price),1) AS Total_Sales
FROM coffee_sales_data
GROUP BY Month_Num;

-- Total Sales
SELECT ROUND(SUM(transaction_qty*unit_price),1)
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5;  -- for any month to calculate

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT MONTH(transaction_date) AS month,
ROUND(SUM(transaction_qty*unit_price),1) AS Total_Sales,
(SUM(transaction_qty*unit_price) - LAG(SUM(transaction_qty*unit_price),1) 
OVER(ORDER BY MONTH(transaction_date))) / 
LAG(SUM(transaction_qty*unit_price),1)
OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee_sales_data
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY month;

-- Total Orders
SELECT COUNT(transaction_id) AS Total_orders
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5;

-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT MONTH(transaction_date) AS month,
MONTHNAME(transaction_date) AS month_name,
COUNT(transaction_id) AS Total_Orders,
(COUNT(transaction_id) - LAG(COUNT(transaction_id),1)
OVER(ORDER BY MONTH(transaction_date))) / 
LAG(COUNT(transaction_id)) OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee_sales_data
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY month, month_name; 

-- Total Quantity
SELECT SUM(transaction_qty) AS total_quantity
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5;

-- TOTAL QUANTITY KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT MONTH(transaction_date) as month,
MONTHNAME(transaction_date) as month_name,
SUM(transaction_qty) AS total_quantity,
(SUM(transaction_qty) - LAG(SUM(transaction_qty),1)
OVER(ORDER BY MONTH(transaction_date))) /
LAG(SUM(transaction_qty)) OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee_sales_data
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY month, month_name;

-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT CONCAT(ROUND(SUM(transaction_qty*unit_price)/1000,1), "K") AS Total_Sales,
CONCAT(ROUND(COUNT(transaction_id),1)/1000, "K") AS Total_Orders,
CONCAT(ROUND(SUM(transaction_qty)/1000,1), "K") AS Total_Quantity
FROM coffee_sales_data
WHERE transaction_date = '2023-05-18';

-- Sales of Weekdays & Weekends 
SELECT 
    CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'WeekDays'
    END AS day_type,
    CONCAT(ROUND(SUM(transaction_qty*unit_price)/1000,1),'K') AS Total_Sales
FROM coffee_sales_data
GROUP BY  CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'WeekDays'
    END;
    
-- Sales by Store Location
SELECT store_location, 
CONCAT(ROUND(SUM(transaction_qty*unit_price)/1000,1),'K') AS Total_Sales
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5
GROUP BY store_location
ORDER BY Total_Sales DESC;

-- Avg sales of the month
SELECT CONCAT(ROUND(AVG(Total_sales)/1000,1),'K') AS Avg_Sales
FROM(
SELECT DAY(transaction_date) as day,
SUM(unit_price*transaction_qty) as Total_Sales
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5
GROUP BY day) AS internal_query;


-- Sales of the month per day
SELECT DAY(transaction_date) as day,
CONCAT(ROUND(SUM(unit_price*transaction_qty),1),'K') as Total_Sales_Per_Day
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5
GROUP BY day;

SELECT day_of_month,
CASE WHEN total_sales > avg_sales THEN 'Above Average'
     WHEN total_sales < avg_sales THEN 'Below Average'
     ELSE 'Average'
     END AS sales_status,
     total_sales
FROM (
SELECT DAY(transaction_date) as day_of_month,
ROUND(SUM(unit_price*transaction_qty),2) as total_sales,
AVG(SUM(unit_price*transaction_qty)) OVER() AS avg_sales
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5
GROUP BY day_of_month
) AS internal_query;

-- Top 10 product_type by sales
SELECT product_type,
ROUND(SUM(unit_price*transaction_qty),2) AS total_Sales
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5 AND product_category='Coffee'
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;

-- Total Sales, Total Qty sold, Total order per hour of the day
SELECT 
ROUND(SUM(unit_price*transaction_qty),2) AS total_Sales,
COUNT(transaction_id) AS total_orders,
SUM(transaction_qty) AS total_quantity
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5 
AND DAYOFWEEk(transaction_date) = 6
AND HOUR(transaction_time) = 8;

-- Sales by hour
SELECT HOUR(transaction_time) AS hour,
ROUND(SUM(unit_price*transaction_qty),2) AS total_Sales
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5 
GROUP BY hour
ORDER BY total_sales;

-- Sales by Weekday
SELECT
CASE 
    WHEN DAYOFWEEK(transaction_date)=2 THEN 'Monday'
	WHEN DAYOFWEEK(transaction_date)=3 THEN 'Tuesday'
    WHEN DAYOFWEEK(transaction_date)=4 THEN 'Wednesday'
    WHEN DAYOFWEEK(transaction_date)=5 THEN 'Thursday'
    WHEN DAYOFWEEK(transaction_date)=6 THEN 'Friday'
    WHEN DAYOFWEEK(transaction_date)=7 THEN 'Saturday'
    ELSE 'Sunday'
    END AS day,
ROUND(SUM(unit_price*transaction_qty),2) AS total_Sales
FROM coffee_sales_data
WHERE MONTH(transaction_date)=5 
GROUP BY day


    






