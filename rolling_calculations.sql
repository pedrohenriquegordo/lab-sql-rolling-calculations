use sakila;

#1
CREATE OR REPLACE VIEW customer_activity AS
SELECT DISTINCT(A.customer_id) AS customer_id, month(B.payment_date) AS month, year(B.payment_date) AS year, A.active AS active
FROM customer A JOIN payment B ON A.customer_id = B.customer_id
ORDER BY year, month, customer_id ASC;

SELECT * FROM customer_activity;


CREATE OR REPLACE VIEW monthly_active_customers AS
SELECT month, COUNT(active IN (SELECT active WHERE active = 1)) AS number_active_customers
FROM customer_activity
GROUP BY month
ORDER BY month ASC;

SELECT * FROM monthly_active_customers;

-- SELECT ROUND(AVG(number_active_customers)) AS 'Mean of active customers per month' FROM monthly_active_customers;

#2

SELECT * FROM customer_activity;


CREATE OR REPLACE VIEW prev_month_active_customers AS
SELECT month, COUNT(customer_id) AS active_customers, LAG(COUNT(customer_id)) OVER () AS prev_month_customers
FROM customer_activity
WHERE active IN (SELECT active WHERE active = 1)
GROUP BY month;

SELECT * FROM prev_month_active_customers;

#3
CREATE OR REPLACE VIEW view_delta_active_customers AS
SELECT *, (active_customers - prev_month_customers) AS delta_active_customers
FROM prev_month_active_customers;

SELECT * FROM view_delta_active_customers;

CREATE OR REPLACE VIEW view_percent_active_customers AS
SELECT *, ROUND((delta_active_customers / active_customers)*100) AS percent_active_customers
FROM view_delta_active_customers;

SELECT * FROM view_percent_active_customers;

#4
SELECT * FROM customer_activity ORDER BY customer_id, month;

CREATE OR REPLACE VIEW active_months_customers AS
SELECT customer_id, COUNT(month) AS active_months
FROM customer_activity
WHERE active = 1
GROUP BY customer_id;

SELECT * FROM active_months_customers;

CREATE OR REPLACE VIEW long_active_customers AS
SELECT A.customer_id, B.first_name, B.last_name
FROM active_months_customers A JOIN customer B ON A.customer_id = B.customer_id
WHERE A.active_months = 5;


SELECT * FROM long_active_customers;

-- SELECT COUNT(customer_id) AS total_long_active_customers FROM long_active_customers; Gives the sum of the customers that where always active
