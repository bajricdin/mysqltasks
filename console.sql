
use classicmodels

# select c.customername, c.customernumber
# from customers c
# where exists(
#     select 1
#     from orders o
#     join orderdetails od on od.ordernumber = o.ordernumber
#     join products p on p.productcode = od.productcode
#     where o.customernumber = c.customernumber
#     group by o.customernumber
#     HAVING count(DISTINCT p.productline) > 3
# )
# and exists(
#     select 1
#     from orderdetails od
#     join orders o on o.ordernumber = od.ordernumber
#     WHERE od.ordernumber = o.ordernumber
#     group by o.ordernumber
#     HAVING sum(od.quantityordered) > 10
# )

# select productLine, totalRevenue
# from (
#         SELECT p.productLine, sum(od.quantityordered * od.priceeach) as totalRevenue
#         from products p
#         join orderdetails od on od.productcode = p.productcode
#         group by p.productLine
#      ) revenueByProductLine
# WHERE totalRevenue = (
#     SELECT MAX(totalRevenue)
#     FROM (
#         SELECT SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
#         FROM products p
#         JOIN orderdetails od ON od.productCode = p.productCode
#         GROUP BY p.productLine
#     ) maxRevenue
# );

select c.customername
from customers c
WHERE exists(select *
from (select c.customername, count(p.productline) as total_productLines
from productlines pl
JOIN  products p on p.productline = pl.productline
JOIN orderdetails od on od.productcode = p.productcode
join orders o on o.ordernumber = od.ordernumber
join customers c on c.customernumber = o.customernumber
group BY od.ordernumber) as total
where total_productLines > 2)

# SELECT DISTINCT c.customerName
# FROM customers c
# JOIN (
#     SELECT o.customerNumber, COUNT(DISTINCT p.productLine) AS totalProductLines
#     FROM products p
#     JOIN orderdetails od ON p.productCode = od.productCode
#     JOIN orders o ON o.orderNumber = od.orderNumber
#     GROUP BY o.customerNumber
# ) productLineCount ON c.customerNumber = productLineCount.customerNumber
# WHERE productLineCount.totalProductLines > 2;

SELECT p.productCode, p.productName, revenue.totalRevenue
FROM products p
JOIN (
    SELECT od.productCode, SUM(od.priceEach * od.quantityOrdered) AS totalRevenue
    FROM orderdetails od
    GROUP BY od.productCode
) revenue ON revenue.productCode = p.productCode
WHERE revenue.totalRevenue = (
    SELECT MIN(totalRevenue)
    FROM (
        SELECT SUM(od.priceEach * od.quantityOrdered) AS totalRevenue
        FROM orderdetails od
        GROUP BY od.productCode
    ) productRevenues
);

use employees
select avg(total.sum) as avg_salary
FROM
(select s.emp_no, sum(s.salary) as sum
from employees e
join salaries s on s.emp_no = e.emp_no
where e.hire_date >
(select avg(e.hire_date)
from employees e)
GROUP BY s.emp_no) total

SELECT AVG(total.sum) AS avg_salary
FROM (
    SELECT s.emp_no, SUM(s.salary) AS sum
    FROM employees e
    JOIN salaries s ON s.emp_no = e.emp_no
    WHERE e.hire_date > (
        SELECT AVG(hire_date)
        FROM employees
    )
    GROUP BY s.emp_no
) total;

SELECT AVG(total.sum) AS avg_salary
FROM (
    SELECT s.emp_no, SUM(s.salary) AS sum
    FROM employees e
    JOIN salaries s ON s.emp_no = e.emp_no
    WHERE e.hire_date > (
        SELECT AVG(hire_date)
        FROM employees
    )
    GROUP BY s.emp_no
) total;

SELECT e.emp_no, e.first_name, e.last_name
FROM employees e
WHERE e.emp_no IN (
    SELECT de.emp_no
    FROM dept_emp de
    GROUP BY de.emp_no
    HAVING COUNT(DISTINCT de.dept_no) > 1
);


SELECT tit.title, tit.emp_no, e.first_name
FROM (SELECT t.emp_no, t.title, count(*) as types
from titles t
GROUP BY t.emp_no, t.title) tit
JOIN employees e on e.emp_no = tit.emp_no
where tit.types > 1

select e.emp_no, e.first_name, e.last_name
FROM (
select de.emp_no, count(de.dept_no) as dep
from dept_emp de
group BY de.emp_no) a
JOIN employees e on e.emp_no = a.emp_no
where a.dep > 1

select *
from(
select s.emp_no, max(s.salary) as sal
from salaries s
GROUP BY s.emp_no) a


use employees

select *, dense_rank() OVER (ORDER BY dep.department_count) as department_rank
FROM
(select e.emp_no, e.first_name, e.last_name, count(de.emp_no) as department_count
from employees e
JOIN dept_emp de on de.emp_no = e.emp_no
GROUP BY e.emp_no,e.first_name, e.last_name) dep
ORDER BY department_rank ASC

SELECT *,
       DENSE_RANK() OVER (ORDER BY department_count DESC ) AS department_rank
FROM (
    SELECT e.emp_no,
           e.first_name,
           e.last_name,
           COUNT(de.emp_no) AS department_count
    FROM employees e
    JOIN dept_emp de ON de.emp_no = e.emp_no
    GROUP BY e.emp_no, e.first_name, e.last_name
) dep
ORDER BY department_rank ASC;

select e.emp_no, e.first_name, e.last_name, t.title, avg(s.salary) as salary,
       dense_rank() OVER (PARTITION BY t.title ORDER BY avg(s.salary) DESC ) as rankk
from employees e
JOIN salaries s on s.emp_no = e.emp_no
JOIN titles t on t.emp_no = e.emp_no
group by e.emp_no

SELECT e.emp_no, e.first_name, e.last_name, t.title, avg(s.salary) as salary,
       dense_rank() OVER (PARTITION BY t.title ORDER BY avg(s.salary) DESC) as rankk
FROM employees e
JOIN salaries s ON s.emp_no = e.emp_no
JOIN titles t ON t.emp_no = e.emp_no
GROUP BY e.emp_no, t.title

use classicmodels

select o.customernumber,
       year(last_value(o.orderdate) OVER (ORDER BY o.orderdate)) - 2001  as yearsActive,
        count(o.ordernumber) as totalOrders,
        COUNT(DISTINCT YEAR(o.orderDate)) / NULLIF(COUNT(o.orderNumber), 0) AS retentionRate
from orders o
GROUP BY o.customernumber
order BY o.customernumber ASC

SELECT
    o.customernumber,
    YEAR(FIRST_VALUE(o.orderdate) OVER (ORDER BY o.orderdate)) - YEAR(LAST_VALUE(o.orderdate) OVER (ORDER BY o.orderdate)) as yearsActive,
    COUNT(o.ordernumber) as totalOrders,
    COUNT(DISTINCT YEAR(o.orderDate)) / NULLIF(COUNT(o.orderNumber), 0) AS retentionRate
FROM orders o
GROUP BY o.customernumber;


use sakila

select f.title,AVG(DATE(r.return_date) - DATE(r.rental_date)) as avgRentalDuration,
       dense_rank() OVER (ORDER BY AVG(DATE(r.return_date) - DATE(r.rental_date))desc ) as rentalDurationRank
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
GROUP BY f.title
HAVING avgRentalDuration is not null
order BY rentalDurationRank ASC

use sakila

select c.customer_id, sum(DATEDIFF("2005-11-10", r.rental_date) > 90) as churnedRentails,
       count(r.rental_id) as totalRentals,
       100 * SUM(DATEDIFF("2005-11-10", rental_date) > 90) / NULLIF(COUNT(DISTINCT rental_id), 0) AS churnRate
from rental r
join customer c on c.customer_id = r.customer_id
group by c.customer_id
order BY c.customer_id ASC

use employees

select e.emp_no, e.first_name, e.last_name, s.salary,
       cume_dist() OVER (ORDER BY s.salary DESC ) as salaryDistribution
from employees e
join salaries s on s.emp_no = e.emp_no

use classicmodels

select count(o.ordernumber) as "Number of created status", o.status
from orders o
where DATE (o.orderdate) > DATE("2003-10-10") and o.orderdate < DATE("2004-09-09")
group BY o.status
ORDER BY `Number of created status` DESC


use classicmodels

select p.productcode, od.orderlinenumber, avg(od.priceeach) as 'Average price each'
from products p
join orderdetails od on od.productcode = p.productcode
GROUP BY p.productcode, od.orderlinenumber
having max(od.priceeach) > 100
ORDER BY p.productcode DESC

select c.customername, sum(od.quantityordered * od.priceeach) as totalRevenue,
       count(o.ordernumber) as numberOfOrders
from customers c
join orders o on o.customernumber = c.customernumber
join orderdetails od on od.ordernumber = o.ordernumber
group BY c.customername
HAVING totalRevenue > 50000
order BY numberOfOrders DESC


select e.firstname, e.lastname, count(DISTINCT o.customernumber) as totalCustomers,
       sum(od.quantityordered * od.priceeach) as totalSales
from employees e
join customers c on c.salesrepemployeenumber = e.employeenumber
JOIN  orders o on o.customernumber = c.customernumber
join orderdetails od on od.ordernumber = o.ordernumber
GROUP BY e.firstname, e.lastname
HAVING count(DISTINCT c.customernumber) > 5
order BY totalSales DESC

use sakila

select c.name, avg(f.rental_rate) as 'Avg rental rate'
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
GROUP BY c.name
HAVING avg(f.rental_rate) > 3

select c.city, avg(f.rental_duration) as 'Average rental duration'
from film f
join inventory i on i.film_id = f.film_id
join store s on s.store_id = i.store_id
join address a on a.address_id = s.address_id
join city c on c.city_id = a.city_id
GROUP BY c.city
HAVING avg(f.rental_duration) > 4

select a.first_name, a.last_name, SUM(p.amount) AS totalRevenue,
       count(DISTINCT f.film_id) as totalFilms
from film f
join film_actor fa on fa.film_id = f.film_id
join actor a on a.actor_id = fa.actor_id
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
GROUP BY a.first_name, a.last_name ,a.actor_id
HAVING totalRevenue > 2000
ORDER BY totalFilms DESC


SELECT a.first_name, a.last_name,
       SUM(p.amount) AS totalRevenue,
       COUNT(DISTINCT f.film_id) AS totalFilms
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING totalRevenue > 2000
ORDER BY totalRevenue DESC;

select c.name, avg(f.rental_duration) as avgRentalDuration
from film f
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
GROUP BY c.name
having avgRentalDuration > 5
order BY avgRentalDuration DESC


select c.city, count(DISTINCT r.rental_id) as totalRentals,
       sum(p.amount) as totalRevenue
from city c
join address a on a.city_id = c.city_id
join customer cu on cu.address_id = a.address_id
join rental r on r.customer_id = cu.customer_id
join payment p on p.rental_id = r.rental_id
GROUP BY c.city
HAVING totalRentals > 25
order by totalRevenue DESC

use employees

select e.first_name, e.last_name, e.emp_no, min(s.salary) as minSalray,
       max(s.salary) as maxSalary
from employees e
join salaries s on s.emp_no = e.emp_no
GROUP BY e.emp_no

select t.title, avg(s.salary)
from employees e
join salaries s on s.emp_no = e.emp_no
join titles t on t.emp_no = e.emp_no
GROUP BY t.title

select d.dept_name, json_arrayagg(json_object("title", t.title, "lastName", e.last_name, "firstName", e.first_name)) as employeeTitles
from employees e
join titles t on t.emp_no = e.emp_no
join dept_emp de on de.emp_no = e.emp_no
join departments d on d.dept_no = de.dept_no
group BY d.dept_name, d.dept_no

SELECT d.dept_name AS departmentName,
       JSON_ARRAYAGG(JSON_OBJECT('firstName', e.first_name, 'lastName', e.last_name, 'title', t.title)) AS employeeTitles
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
JOIN titles t ON e.emp_no = t.emp_no
GROUP BY d.dept_no, d.dept_name;


select e.emp_no, e.first_name, e.last_name
from employees e
join dept_emp de on de.emp_no = e.emp_no
GROUP BY e.emp_no
HAVING count(de.dept_no) > 1
order by e.emp_no ASC

select e.emp_no, e.first_name, e.last_name
FROM employees e
join salaries s on s.emp_no = e.emp_no
where e.first_name LIKE "%r"
group by e.emp_no, e.first_name, e.last_name
HAVING max(s.salary) < 80000 and min(s.salary) > 70000


use classicmodels

select DISTINCT od.productcode, round(sum(od.priceeach * od.quantityordered),2) as subtotal
from orderdetails od
WHERE od.quantityordered > 20 and od.priceeach < 120
group BY od.productcode

select e.firstname, e.lastname,
       sum(od.quantityordered * od.priceeach) as totalSales
from employees e
join customers c on c.salesrepemployeenumber = e.employeenumber
join orders o on o.customernumber = c.customernumber
join orderdetails od on od.ordernumber = o.ordernumber
GROUP BY e.firstname, e.lastname
HAVING totalSales > 150000
ORDER BY totalSales DESC

select p.productline, count(DISTINCT od.ordernumber) as totalOrders,
       sum(od.quantityordered) as totalQuantity
from orderdetails od
join products p on p.productcode = od.productcode
GROUP BY p.productline
HAVING totalOrders > 200

select p.productname, p.productline,
       sum(od.quantityordered*od.priceeach) as totalSales
from products p
join orderdetails od on od.productcode = p.productcode
GROUP BY p.productname, p.productline
HAVING  totalSales > 50000
order by totalSales DESC

select max(c.creditlimit) as maxCreditLimit,
       min(c.creditlimit) as minCreditLimit,
       sum(c.creditlimit) as totalCreditLimit,
       avg(c.creditLimit) as avgCreditLimit
from customers c
WHERE c.country is not null and c.city is not null
GROUP BY c.city, c.country
order by c.country Desc, c.city ASC

use sakila

select a.first_name,a.last_name , f.rating as filmRating,
       count(f.film_id) as numberOfFilms
from film f
join film_actor fa on fa.film_id = f.film_id
join actor a on a.actor_id = fa.actor_id
WHERE a.first_name = "Jennifer" and a.last_name = "Davis"
GROUP BY f.rating
HAVING numberOfFilms > 4
order by filmRating desc

use sakila

SELECT c.city, sum(p.amount)
FROM city c
JOIN address a ON c.city = a.city_id
JOIN customer cu ON cu.address_id = a.address_id
join rental r on r.customer_id = cu.customer_id
join payment p on p.customer_id = r.customer_id

select c.city,
       sum(p.amount) as totalRevenue
from payment p
join customer cu on cu.customer_id = p.customer_id
join address a on cu.address_id = a.address_id
join city c on c.city_id = a.city_id
group by c.city_id
having totalRevenue > 190
order by totalRevenue desc

SELECT SUM(p.amount) AS "Total revenue", ci.city
FROM
    city ci
    JOIN address a on ci.city_id = a.city_id
    JOIN customer c on a.address_id = c.address_id
    JOIN payment p on c.customer_id = p.customer_id
GROUP BY
    ci.city_id
HAVING
    SUM(p.amount) > 190
ORDER BY SUM(p.amount) DESC;

select c.name as categoryName,
       sum(p.amount) as totalRevenue,
       count(p.rental_id) as totalRental
FROM category c
join film_category fc on fc. category_id = c.category_id
join film f on f.film_id = fc.film_id
join inventory i on i.film_id = f.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on p.rental_id = r.rental_id
GROUP BY c.name
HAVING totalRevenue > 1000
order by totalRevenue desc

use employees
select d.dept_name, count(e.emp_no) as 'Number of Employees'
from employees e
join dept_emp de on de.emp_no = e.emp_no
join departments d on d.dept_no = de.dept_no
GROUP BY d.dept_name
order BY count(e.emp_no) DESC

select d.dept_name, e.first_name, e.last_name,
       datediff(max(de.to_date), min(de.from_date)) as duration_days
FROM employees e
JOIN dept_emp de on de.emp_no = e.emp_no
join departments d on d.dept_no = de.dept_no
GROUP BY d.dept_name, d.dept_no
order by d.dept_name, duration_days DESC


select d.dept_name,
       sum(s.salary) as totalExpenditure
FROM employees e
join salaries s on s.emp_no = e.emp_no
join dept_emp de on de.emp_no = e.emp_no
join departments d on d.dept_no = de.dept_no
GROUP BY d.dept_name
HAVING totalExpenditure > 500000
order by totalExpenditure DESC

SELECT t.title,
       count(e.emp_no) as totalEmployees,
       avg(s.salary) as avgSalary
FROM employees e
join titles t on t.emp_no = e.emp_no
JOIN salaries s on s.emp_no = e.emp_no
GROUP BY t.title
HAVING totalEmployees > 1000
ORDER BY totalEmployees DESC

select d.dept_name,
       max(datediff(de.to_date, de.from_date)) as longesTenure
from employees e
join dept_emp de on de.emp_no = e.emp_no
join departments d on d.dept_no = de.dept_no
GROUP BY d.dept_name
order by longesTenure DESC

select d.dept_name,
       group_concat(json_object("title", t.title, "salary", s.salary, "hireDate", e.hire_date, "lastName", e.last_name, "firstName", e.first_name))
       as employeeDetails
from employees e
join dept_emp de on de.emp_no = e.emp_no
join departments d on d.dept_no = de.emp_no
join titles t on t.emp_no = e.emp_no
join salaries s on s.emp_no = e.emp_no
WHERE e.last_name like "%x%"
GROUP BY d.dept_name, d.dept_no


use classicmodels

SELECT e.firstName,
	   e.lastName,
	   CASE
		    WHEN e.firstName = 'Diane' THEN "OK"
		    WHEN e.firstName = 'Mary' THEN "NOT OK"
		    WHEN e.lastName = 'Bow' THEN "GOOD SURNAME"
		    ELSE e.firstName
	   END AS conditions
FROM employees e


select c.customername,
       c.addressline1,
       c.city,
       c.country,
       p.amount,
       paymentdate
from customers c
JOIN payments p on p.customernumber = c.customernumber
order by p.paymentdate DESC

select e.employeenumber,
       e.firstname,
       e.lastname,
       ifnull(od.priceeach * od.quantityordered, 0) as totalSales
from employees e
left join customers c on c.salesrepemployeenumber = e.employeenumber
left join orders o on o.customernumber = c.customernumber
left join orderdetails od on o.ordernumber = od.ordernumber
order BY totalSales DESC

select c.customername,
       c.country,
       o.ordernumber,
       o.orderdate
from customers c
join orders o ON c.customernumber = o.customernumber
order by o.orderdate DESC

select p.productname,
       pl.productline,
       p.quantityinstock,
       p.buyprice
from products p
join productlines pl on p.productline = pl.productline

select c.customername,
       o.orderdate,
       o.orderdate,
       o.status
FROM customers c
join orders o ON c.customernumber = o.customernumber


select c.customername
from customers c
WHERE c.country like "USA"
UNION
select c.customername
from customers c
WHERE creditlimit > 50000

select c.customername
from customers c
JOIN orders o ON c.customernumber = o.customernumber
GROUP BY c.customername
HAVING count(o.ordernumber) > 0
INTERSECT
SELECT c.customername
FROM customers c
JOIN payments p ON c.customernumber = p.customernumber
GROUP BY c.customername
HAVING count(p.customernumber) > 0

use sakila

select c.customer_id,
       c.first_name,
       c.last_name,
       p.amount,
       p.payment_date
FROM payment p
JOIN customer c USING(customer_id)
UNION
SELECT p.staff_id,
       s.first_name,
       s.last_name,
       p.amount,
       p.payment_date
from staff s
join payment p USING (staff_id)
order by payment_date DESC

select c.customer_id,
       c.first_name,
       c.last_name,
       p.amount,
       p.payment_date
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
UNION
SELECT p.staff_id,
       s.first_name,
       s.last_name,
       p.amount,
       p.payment_date
from staff s
join payment p ON s.staff_id = p.staff_id
order by payment_date DESC

select c.customer_id
from customer c
join rental r USING(customer_id)
INTERSECT
SELECT c.customer_id
FROM customer c
join payment p using(customer_id)

select staff_id
from staff
join rental r USING(staff_id)
INTERSECT
SELECT staff.staff_id
from staff
join payment p USING(staff_id)

use employees

select e.emp_no,
       e.first_name,
       e.last_name,
       round(datediff(current_date, e.hire_date)/365) as length_of_service_years,
       d.dept_name
from employees e
join dept_emp de on e.emp_no = de.emp_no
join departments d ON de.dept_no = d.dept_no


use classicmodels

start transaction

select *
from customers c


update customers
SET addressline1 = "New address line1",
    city = "Sarajevo",
    state = "FBiH",
    postalcode = "7100",
    country = "Bosnia and Herzegovina"
where customernumber = 103;

UPDATE orders
SET shipAddress = 'New Address Line 1',
    shipCity = 'New City',
    shipState = 'New State',
    shipPostalCode = 'New Postal Code',
    shipCountry = 'New Country'
WHERE customerNumber = 103; -- Replace 103 with the actual customer number

ROLLBACK

start transaction

update customers c
SET c.city = "Tuzla";

ROLLBACK

select *
FROM customers c

SELECT productLine,
	   	    SUM(buyPrice) AS total
FROM products p
GROUP BY productLine;

SELECT productCode,
	   	    productName,
    productLine,
	   	    buyPrice,
	   	    SUM(buyPrice) OVER(
	   		PARTITION BY productLine
	   	    )
FROM products p;

SELECT p.customerNumber,
	   	    p.paymentDate AS payment_date,
     	    p.amount,
	   	    ROW_NUMBER() OVER (
	   		ORDER BY p.amount
	   	    ) AS row_numberr
FROM payments p;

SELECT p.customerNumber,
	   	    p.paymentDate AS payment_date,
	          p.amount,
	   	    CUME_DIST() OVER (
	   		ORDER BY p.amount
	   	    ) AS cume_dist_value
FROM payments p;

SELECT p.customerNumber,
	   p.paymentDate AS payment_date,
	   p.amount,
	   RANK() OVER (
	   	ORDER BY p.customerNumber
	   ) AS rankk
FROM payments p
ORDER BY p.customerNumber;

select p.customernumber, p.amount, first_value(p.amount) OVER (PARTITION BY p.customernumber ORDER BY p.amount DESC range between UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as rankk
from payments p;

SELECT p.customerNumber,
	   p.paymentDate AS payment_date,
	   p.amount,
	   NTILE(5) OVER (
	   	ORDER BY p.customerNumber
	   ) AS rankk
FROM payments p
ORDER BY p.customerNumber;

SELECT p.customerNumber,
	   p.paymentDate AS payment_date,
	   p.amount,
	   LAG(p.amount, 1, 0) OVER (
	   	ORDER BY p.customerNumber
	   ) AS lag_val
FROM payments p
ORDER BY p.customerNumber;

SELECT p.customerNumber,
	   p.paymentDate AS payment_date,
	   p.amount,
	   LEAD(p.amount, 1) OVER (
	   	PARTITION BY p.customerNumber ORDER BY p.customerNumber
	   ) AS lag_val,
	   p.amount - LEAD(p.amount, 1) OVER (
	   	PARTITION BY p.customerNumber ORDER BY p.customerNumber
	   ) AS sub_value
FROM payments p
ORDER BY p.customerNumber;

SELECT p.customerNumber,
	   p.paymentDate AS payment_date,
	   p.amount,
	   NTH_VALUE(p.paymentDate, 3) OVER (
	   	PARTITION BY p.customerNumber
	   	ORDER BY p.customerNumber
	   	RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	   ) AS nth_values
FROM payments p
ORDER BY p.customerNumber;

use classicmodels
-- Start the transaction
START TRANSACTION;

-- Update the customerNumber for the affected order in the orders table
UPDATE orders
SET customerNumber = 103 -- Replace with the correct customer number
WHERE orderNumber = 10101; -- Replace with the affected order number

-- Check if the order belongs to the new customer (to ensure consistency, optional check)
-- This query can be used for validation purposes.
SELECT * FROM orders
WHERE customerNumber = 103;

-- Commit the transaction if everything is correct
COMMIT;
ROLLBACK
-- If any part fails, you can roll back the transaction
-- ROLLBACK;  -- Uncomment if handling errors explicitly

use sakila

select r.rental_id,
       rental_date,
       datediff(current_date, rental_date) as days_since_rental,
       if (datediff(return_date, rental_date) > 3, 'Overdue', 'OnTime') as return_status,
       COALESCE(rpad(CONCAT_WS(' ', upper(first_name), upper(last_name)), 30, '*'), 'UNKNOWN') as customer_name
from rental r
join customer c on c.customer_id = r.customer_id
order by days_since_rental DESC

select f.film_id AS film_number,
       concat(reverse(mid(f.title, 1, 5)), lower(mid(f.title, 5))) as fancy_film,
       length(description) as description_lenght,
       round(avg(p.amount), 2) as avg_payment,
       count(DISTINCT c.customer_id) as total_customers_rented,
       if(bit_count(f.film_id) > 4, 'Bitty', 'Not Bitty') as bit_status,
       if(count(c.customer_id) > 5, if(avg(f.replacement_cost) OVER (ORDER BY
           f.replacement_cost ROWS BETWEEN UNBOUNDED PRECEDING and unbounded following) <=
           f.replacement_cost, 'ABOVE AVG COST' ,'BELOW AVG COST'), 'BELOW AVG COST') as cost_category,
       f.replacement_cost
from film f
join inventory i on i.film_id = f.film_id
join rental r on i.inventory_id = r.inventory_id
join customer c on r.customer_id = c.customer_id
join payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id
order by avg_payment DESC, fancy_film asc




















