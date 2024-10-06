USE sakila;

#1 Step 1: Create a View
-- First, create a view that summarizes rental information for each customer.  
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

select * from customer;
select * from rental;

-- rental_count by customer_id

DROP VIEW IF EXISTS rental_count;

create view rental_count as 
select customer_id, count(rental_id) as rental_count
from rental
group by customer_id;

DROP VIEW IF EXISTS rental_informations;

create view rental_informations as 
select c.customer_id, c.first_name, c.last_name, c.email, r.rental_count
from customer c 
join rental_count r on r.customer_id = c.customer_id;

select * from rental_informations;

#2 Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

select * from payment;

DROP TEMPORARY TABLE IF EXISTS total_paid;

create temporary table  total_paid as
select c.customer_id, c.first_name, c.last_name, sum(amount) as total_paid
from payment p 
join customer c on c.customer_id = p.customer_id
group by customer_id;

DROP TEMPORARY TABLE IF EXISTS amount_summary;

create temporary table amount_summary as
select ri.customer_id as customer_id, ri.first_name, ri.last_name, ri.email, ri.rental_count, tp.total_paid
from rental_informations ri 
join total_paid tp on tp.customer_id = ri.customer_id;

select * from amount_summary;

#3 Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.

WITH customer_summary AS (
    SELECT 
        ri.first_name, 
        ri.last_name, 
        ri.email, 
        ri.rental_count, 
        amount_summary.total_paid,
        ROUND(amount_summary.total_paid / ri.rental_count, 2) AS average_payment_per_rental
    FROM rental_informations ri
    JOIN amount_summary ON ri.customer_id = amount_summary.customer_id
)

SELECT 
    first_name, 
    last_name, 
    email, 
    rental_count, 
    total_paid, 
    average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC;





