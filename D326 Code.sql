-- D326 - Advanced Data Management - CSN1 Task 1
-- Student ID: 010776164
-- 2/22/2024
-- Matthew Gibson

-- B: SQL function for transforming date to varchar for readability
CREATE OR REPLACE FUNCTION get_date(date_time DATE)
RETURNS varchar(30)
LANGUAGE plpgsql
AS
$$
DECLARE 
	date_day smallint; 
	date_month smallint; 
	date_year smallint;
	date_string varchar(30);
BEGIN
	date_day := EXTRACT(DAY FROM date_time);
	date_month := EXTRACT(MONTH FROM date_time);
	date_year := EXTRACT(YEAR FROM date_time);
	
	date_string := to_char(TO_TIMESTAMP(date_month::text, 'MM'), 'Mon') || ' ' || to_char(date_day, 'FM00') || ', ' || to_char(date_year, 'FM0000');
	
	RETURN date_string;
END;
$$

-- C and D: Code to create a detailed and summary report, extract data for the tables, and place the date into the tables

-- Create detailed report table
CREATE TABLE detailed_category_report AS
SELECT p.customer_id, name AS film_category, title AS film_title, 
	   amount::money AS rental_amount, get_date(DATE(rental_date)) AS rental_date, get_date(DATE(payment_date)) AS payment_date
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE amount IS NOT NULL
GROUP BY p.customer_id, film_category, film_title, rental_amount, rental_date, payment_date
ORDER BY p.customer_id, rental_amount DESC;

-- Create summary report table
CREATE TABLE summary_category_report AS
SELECT p.customer_id, name AS film_category, COUNT(r.rental_id)::smallint AS total_rentals, SUM(amount)::money AS rental_amount
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE amount IS NOT NULL
GROUP BY p.customer_id, film_category
ORDER BY p.customer_id, rental_amount DESC;

-- E: Trigger updates tables when a record is inserted into the payment table

-- Function that calls the stored procedure to update the report tables
CREATE OR REPLACE FUNCTION create_reports_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS
$$
BEGIN
	CALL create_category_reports();
	RETURN NEW;
END;
$$

-- Trigger that updates tables when an insertion is made on the payment table
CREATE TRIGGER new_rental
	AFTER INSERT
	ON payment
	FOR EACH STATEMENT
	EXECUTE PROCEDURE create_reports_trigger();
	
-- F: Original stored procedure to create or replace detailed and summary report tables
CREATE OR REPLACE PROCEDURE create_category_reports()
LANGUAGE plpgsql
AS $$
BEGIN

-- Ensures existing tables are dropped and recreated instead of appended to
DROP TABLE IF EXISTS detailed_category_report;
DROP TABLE IF EXISTS summary_category_report;

-- Create detailed report table
CREATE TABLE detailed_category_report AS
SELECT p.customer_id, name AS film_category, title AS film_title, 
	   amount::money AS rental_amount, get_date(DATE(rental_date)) AS rental_date, get_date(DATE(payment_date)) AS payment_date
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE amount IS NOT NULL
GROUP BY p.customer_id, film_category, film_title, rental_amount, rental_date, payment_date
ORDER BY p.customer_id, rental_amount DESC;

--Create summary report table
CREATE TABLE summary_category_report AS
SELECT p.customer_id, name AS film_category, COUNT(r.rental_id)::smallint AS total_rentals, SUM(amount)::money AS rental_amount
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
LEFT JOIN film f ON i.film_id = f.film_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE amount IS NOT NULL
GROUP BY p.customer_id, film_category
ORDER BY p.customer_id, rental_amount DESC;

RETURN;
END;
$$


DELETE FROM payment WHERE payment_id = 32099;
INSERT INTO payment VALUES (32099, 1, 2, 13756, 4.99, '2007-05-14 13:44:29.996577');
SELECT * FROM payment 
ORDER BY payment_id DESC;

SELECT * FROM detailed_category_report
ORDER BY customer_id;

SELECT * FROM summary_category_report
ORDER BY customer_id;
