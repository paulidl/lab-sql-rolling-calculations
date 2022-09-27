/* Lab | SQL Rolling calculations: In this lab, you will be using the Sakila database of movie rentals.

Instructions:

1. Get number of monthly active customers.
2. Active users in the previous month.
3. Percentage change in the number of active customers.
4. Retained customers every month.
*/

USE sakila;

-- 1. Get number of monthly active customers.

SELECT * FROM sakila.rental;

DROP VIEW IF EXISTS customer_activity; 

CREATE OR REPLACE VIEW customer_activity AS
SELECT 
	date_format(convert(rental_date,date), '%m') AS month_number,
    date_format(convert(rental_date,date), '%M') AS month,
	count(customer_id) AS active_customers
FROM sakila.rental
GROUP BY month_number, month
ORDER BY month_number;

SELECT * FROM sakila.customer_activity;	

-- 2. Active users in the previous month.

DROP VIEW IF EXISTS customer_activity_previous_month; 

CREATE OR REPLACE VIEW customer_activity_previous_month AS
SELECT 
	month_number,
	month,
    lag(active_customers, 1) over (ORDER BY month_number) AS active_customers_previous_month,
    active_customers
FROM sakila.customer_activity
GROUP BY month_number, month
ORDER BY month_number;

SELECT * FROM sakila.customer_activity_previous_month;

-- 3. Percentage change in the number of active customers.

DROP VIEW IF EXISTS customer_activity_percentage; 

CREATE OR REPLACE VIEW customer_activity_percentage AS
WITH cte_percentage AS(
SELECT 
	month_number,
	month,
	active_customers_previous_month,
    active_customers
FROM sakila.customer_activity_previous_month
)
SELECT 
	*,
    ROUND(((active_customers-active_customers_previous_month)/active_customers_previous_month)*100, 1) AS percentage
FROM cte_percentage;

SELECT * FROM sakila.customer_activity_percentage;	

-- 4. Retained customers every month.

SELECT * FROM sakila.rental;

WITH retained_customers AS (
SELECT 
	date_format(convert(rental_date,date), '%Y') AS activity_year, 
	date_format(convert(rental_date,date), '%M') AS activity_month,
    date_format(convert(rental_date,date), '%m') AS activity_month_number,
	COUNT(DISTINCT customer_id) AS unique_customers
  FROM sakila.rental 
  GROUP BY activity_year, activity_month, activity_month_number
)    
SELECT activity_year,
       activity_month,
       lag(unique_customers, 1) over(ORDER BY activity_month_number) AS unique_customers_previous_month,
       unique_customers
FROM retained_customers;