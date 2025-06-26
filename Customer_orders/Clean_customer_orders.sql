/* 
Cleaning Tasks You Can Try:
1. Standardize customer names: Capitalize and trim. -----------------------------------------DONE
2. Fix inconsistent product names: Normalize case (e.g., LAPTOP → Laptop).-------------------DONE
3. Clean phone numbers: Remove special characters and ensure consistent formatting.----------DONE
4. Fix email issues: Correct obvious typos (e.g., maria@@email.com) and missing fields.------DONE
5. Correct date formats: Convert 02/16/2024 to 2024-02-16.-----------------------------------DONE
6. Check data types: Ensure price, total, and quantity are numeric.--------------------------DONE
7. Calculate missing or incorrect totals: Recalculate total = price * quantity.-------------- THATS FINE
8. Remove or flag duplicates: Based on order_id, customer_name, and order_date.
9. Handle NULLs and blanks appropriately.
10. Flag or correct negative quantities and totals.-----------------------------------------DONE*/

DESC customer_orders;

SELECT * FROM customer_orders;

-- Create and insert to a stage table 
CREATE TABLE stage_customer_orders
LIKE customer_orders;
INSERT INTO stage_customer_orders
SELECT * FROM customer_orders;

SELECT * FROM stage_customer_orders;


-- Viewing changes to column
SELECT customer_name, CASE
WHEN customer_name LIKE "jane%" THEN 'Jane Smith'
END
FROM stage_customer_orders
WHERE customer_name LIKE "jane%";

-- Update changes to column
UPDATE stage_customer_orders
SET customer_name = 'Jane Smith'
WHERE customer_name LIKE "jane%";

SELECT * FROM stage_customer_orders;
DESC stage_customer_orders;

-- View untrim quantity
SELECT quantity, TRIM('-' FROM quantity)
FROM stage_customer_orders;

-- Update columns
UPDATE stage_customer_orders
SET quantity = TRIM('-' FROM quantity);

-- Another way of doing the same
SELECT quantity, ABS(quantity)
FROM customer_orders;

SELECT price, REPLACE(price, ',','') FROM stage_customer_orders;

-- update columns
UPDATE stage_customer_orders
SET price = REPLACE(price, ',','');

SELECT * FROM stage_customer_orders;

SELECT ABS(total) FROM stage_customer_orders;
-- Update columns 
UPDATE stage_customer_orders
SET total = ABS(total);

SELECT * FROM stage_customer_orders;

CREATE TABLE stage_customer_orders2
SELECT * FROM stage_customer_orders;

SELECT * FROM stage_customer_orders2;

SELECT product, CONCAT(
UPPER(LEFT(product,1)),
LOWER(SUBSTRING(product,2)))
FROM stage_customer_orders2;

-- Update new column
UPDATE stage_customer_orders2
SET product = CONCAT(
UPPER(LEFT(product,1)),
LOWER(SUBSTRING(product,2)));

SELECT * FROM stage_customer_orders2;
DESC stage_customer_orders2;

SELECT order_date, STR_TO_DATE(order_date, '%Y-%m-%d') `date`
FROM stage_customer_orders2;

-- Update date column
UPDATE stage_customer_orders2
SET order_date = STR_TO_DATE(order_date, '%Y-%m-%d');

-- Alter columnn in table
ALTER TABLE stage_customer_orders2
MODIFY COLUMN order_date DATE;

SELECT * FROM stage_customer_orders2;
ALTER TABLE stage_customer_orders2
MODIFY COLUMN order_date DATE;

-- Testing replacing @@
SELECT email, CASE
				WHEN email LIKE "%@@%" THEN REPLACE(email,"@@", "@")
                ELSE email
                END
FROM stage_customer_orders2;

CREATE TABLE stage_customer_orders3
SELECT * FROM stage_customer_orders2;

UPDATE stage_customer_orders3
SET email = REPLACE(email,"@@", "@")
WHERE email LIKE "%@@%";

SELECT * FROM stage_customer_orders2;
SELECT * FROM stage_customer_orders3;

DESC stage_customer_orders3;

ALTER TABLE stage_customer_orders3
MODIFY COLUMN price DOUBLE;


SELECT phone, CASE 
					WHEN phone IS NOT NULL AND phone != "" THEN CONCAT("(+",
					LEFT(REGEXP_REPLACE(phone, '[^0-9]', ""), 3),") ",
                    SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', ""), 4)
                    )
                    ELSE ""
                    END
FROM stage_customer_orders3;

UPDATE stage_customer_orders3
SET phone = CONCAT("(+",
					LEFT(REGEXP_REPLACE(phone, '[^0-9]', ""), 3),") ",
                    SUBSTRING(REGEXP_REPLACE(phone, '[^0-9]', ""), 4)
                    )
WHERE phone IS NOT NULL AND phone != "";

CREATE TABLE stage_customer_orders4
SELECT * FROM stage_customer_orders3;

SELECT * FROM stage_customer_orders4;

-- Update table with nnull values
UPDATE stage_customer_orders4
SET
  phone = NULLIF(TRIM(phone), ''),
  customer_name = NULLIF(TRIM(customer_name), ''),
  product = NULLIF(TRIM(product), ''),
  price = NULLIF(TRIM(price), ''),
  email = NULLIF(TRIM(email), ''),
  order_date = NULLIF(TRIM(order_date), '');

-- Find dups
SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_name, email, order_date ORDER BY order_id ASC) dups
FROM stage_customer_orders4;

CREATE TABLE stage_customer_orders5
SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_name, email, order_date ORDER BY order_id ASC) dups
FROM stage_customer_orders4;

SELECT * FROM stage_customer_orders5
WHERE dups >1;

-- Delete dups
DELETE FROM stage_customer_orders5
WHERE dups >1;

SELECT * FROM stage_customer_orders5
ORDER BY order_id;

ALTER TABLE stage_customer_orders5
ORDER BY order_id;

SELECT * FROM stage_customer_orders5;

ALTER TABLE stage_customer_orders5
DROP dups;


-- TABLE SORTED
SELECT * FROM stage_customer_orders5;
