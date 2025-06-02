-- ========================================
-- Pizza Sales Analysis SQL Queries
-- Author: Osama Audi
-- Description: KPI metrics, trend analysis,
-- and product performance insights
-- ========================================

-- A. KPI's

-- 1. Total Revenue
SELECT SUM(total_price) AS Total_Revenue 
FROM pizza_sales;

-- 2. Average Order Value
SELECT 
    SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value 
FROM pizza_sales;

-- 3. Total Pizzas Sold
SELECT SUM(quantity) AS Total_Pizzas_Sold 
FROM pizza_sales;

-- 4. Total Orders
SELECT COUNT(DISTINCT order_id) AS Total_Orders 
FROM pizza_sales;

-- 5. Average Pizzas Per Order
SELECT 
    CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
    CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS Avg_Pizzas_Per_Order
FROM pizza_sales;


-- B. Hourly Trend for Total Pizzas Sold
SELECT 
    DATEPART(HOUR, order_time) AS Order_Hour, 
    SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY DATEPART(HOUR, order_time)
ORDER BY Order_Hour;


-- C. Weekly Trend for Orders
SELECT 
    DATEPART(ISO_WEEK, order_date) AS Week_Number,
    YEAR(order_date) AS Year,
    COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY 
    DATEPART(ISO_WEEK, order_date),
    YEAR(order_date)
ORDER BY Year, Week_Number;


-- D. % of Sales by Pizza Category
SELECT 
    pizza_category, 
    CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue,
    CAST(SUM(total_price) * 100.0 / 
        (SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS Percentage_of_Total
FROM pizza_sales
GROUP BY pizza_category;


-- E. % of Sales by Pizza Size
SELECT 
    pizza_size, 
    CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue,
    CAST(SUM(total_price) * 100.0 / 
        (SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS Percentage_of_Total
FROM pizza_sales
GROUP BY pizza_size
ORDER BY pizza_size;


-- F. Total Pizzas Sold by Pizza Category (February Only)
SELECT 
    pizza_category, 
    SUM(quantity) AS Total_Quantity_Sold
FROM pizza_sales
WHERE MONTH(order_date) = 2
GROUP BY pizza_category
ORDER BY Total_Quantity_Sold DESC;


-- G. Top 5 Pizzas by Revenue
SELECT 
    pizza_name, 
    SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC
LIMIT 5;


-- H. Bottom 5 Pizzas by Revenue
SELECT 
    pizza_name, 
    SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue ASC
LIMIT 5;


-- I. Top 5 Pizzas by Quantity Sold
SELECT 
    pizza_name, 
    SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizzas_Sold DESC
LIMIT 5;


-- J. Bottom 5 Pizzas by Quantity Sold
SELECT 
    pizza_name, 
    SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizzas_Sold ASC
LIMIT 5;


-- K. Top 5 Pizzas by Number of Orders
SELECT 
    pizza_name, 
    COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders DESC
LIMIT 5;


-- L. Bottom 5 Pizzas by Number of Orders
SELECT 
    pizza_name, 
    COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders ASC
LIMIT 5;
