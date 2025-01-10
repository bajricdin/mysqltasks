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

select fd.film_id,
       sum(fd.amount) as total_revenue,
       count(DISTINCT fd.rental_id) as rental_count,
       fd.title as film_title,
       mid(fd.title, 1, 10) as short_title,
       CASE
           when fd.rental_rate >= 3 then 'Premium'
           when fd.rental_rate < 3 and fd.rental_rate > 2 then 'Standard'
           else 'Budget'
       END as price_category
from (SELECT f.film_id,
             f.rental_rate,
             r.rental_id,
             f.title,
             p.amount
      from film f
      join inventory i on f.film_id = i.film_id
      join rental r ON i.inventory_id = r.inventory_id
      join payment p ON p.rental_id = r.rental_id
      where year(p.payment_date) BETWEEN  '2004' and '2006') fd
GROUP BY fd.film_id
having total_revenue > 100
order by film_title asc

# Have to solve this one using derived table


use adventureworks

select pp.name,
       pl.name,
       sum(sd.orderqty * sd.unitprice) as total_sales_revenue
from sales_salesorderdetail sd
join sales_specialofferproduct ss ON sd.specialofferid = ss.specialofferid
join production_product pp ON ss.productid = pp.productid
join production_productinventory pinv ON pp.productid = pinv.productid
join production_location pl on pinv.locationid = pl.locationid
join adventureworks.sales_salesorderheader s ON sd.salesorderid = s.salesorderid
where s.orderdate > "2011-06-30" and pinv.quantity > 100
GROUP BY pp.name, pl.name
order by total_sales_revenue desc
LIMIT 10

select concat_ws(' ', pp.firstname, pp.lastname) as FirstAndLastName
from (SELECT he.businessentityid,
             count(hdh.departmentid) AS workedDepartments
        from humanresources_employee he
        join humanresources_employeedepartmenthistory hdh on hdh.businessentityid = he.businessentityid
        GROUP BY he.businessentityid
        HAVING workedDepartments > 1) as employeesWithEnoguhDepartments
JOIN person_person pp ON employeesWithEnoguhDepartments.businessentityid = pp.businessentityid
order by pp.lastname asc, pp.firstname asc


select pp.name,
       sum(od.unitprice * od.orderqty) as total_sales_amonunt,
       count(od.salesorderid) as sales_count
from sales_salesorderdetail od
join sales_salesorderheader ss ON od.salesorderid = ss.salesorderid
join sales_specialofferproduct so on od.productid = so.productid
join production_productinventory pinv on pinv.productid = so.productid
join production_product pp on pp.productid = pinv.productid
where year(ss.orderdate) = 2012
group BY pp.name
HAVING  sales_count > 100
order by total_sales_amonunt desc
limit 10

select he.businessentityid,
       concat_ws(' ', pp.firstname, pp.lastname) as name,
       count(sh.status) as completed_sales_orders,
       dense_rank() OVER (ORDER BY count(sh.status) DESC ) as employee_rank
FROM sales_salesorderheader sh
join sales_salesperson sp ON sh.salespersonid = sp.businessentityid
join humanresources_employee he ON sp.businessentityid = he.businessentityid
join person_person pp on he.businessentityid = pp.businessentityid
GROUP BY he.businessentityid
order by completed_sales_orders desc

select pp.productid,
       coalesce(pp.name, 'No Name') as product_name,
       mid(pp.name, 1, 10) as short_name,
       pp.unitprice,
       max(pp.orderdate) as last_order_date,
       CASE
           when pp.unitprice >= 1000 then 'High End'
           WHEN pp.unitprice < 1000 and pp.unitprice >= 500 then 'Mid-Range'
           ELSE 'Budget'
       END as price_category
from
    (select odd.productid,
             sum(odd.orderqty * odd.unitprice) as annual_revenue,
             soh.orderdate,
             pp.name,
             odd.unitprice
      from sales_salesorderdetail odd
      join sales_specialofferproduct sop ON odd.productid = sop.productid
      join sales_salesorderheader soh ON odd.salesorderid = soh.salesorderid
      join production_product pp ON sop.productid = pp.productid
      where year(soh.orderdate) = 2014
      GROUP BY odd.productid, pp.name, pp.listprice
      HAVING annual_revenue > 25000
      ) as pp
GROUP BY pp.productid, pp.unitprice
order by pp.name asc

select od.salesorderid,
       soh.salesordernumber,
       soh.orderdate,
       ifnull(soh.freight, 0) as freight_cost,
       CASE
           when soh.freight >= 50 then 'Expensive Freight'
           else 'Cheaper Freight'
       END as freight_category,
       totaldue,
       dense_rank() OVER (ORDER BY totaldue) as total_due_rank,
       SUM(soh.totaldue) OVER (
        ORDER BY soh.totaldue ROWS BETWEEN 10 PRECEDING AND CURRENT ROW
    ) AS sum_last_10_ids
from sales_salesorderdetail od
join sales_salesorderheader soh on od.salesorderid = soh.salesorderid
order by soh.orderdate

SELECT
    od.salesorderid,
    soh.salesordernumber,
    soh.orderdate,
    COALESCE(soh.freight, 0) AS freight_cost,
    CASE
        WHEN COALESCE(soh.freight, 0) >= 50 THEN 'Expensive Freight'
        ELSE 'Cheaper Freight'
    END AS freight_category,
    soh.totaldue,
    DENSE_RANK() OVER (ORDER BY soh.totaldue DESC) AS total_due_rank,
    SUM(soh.totaldue) OVER (
        ORDER BY soh.salesorderid ROWS BETWEEN 10 PRECEDING AND CURRENT ROW
    ) AS sum_last_10_ids
FROM
    sales_salesorderdetail od
JOIN
    sales_salesorderheader soh ON od.salesorderid = soh.salesorderid
ORDER BY
    soh.salesorderid;

select od.salesorderid as salesOrderId,
       soh.orderdate,
       COALESCE(soh.freight, 0) AS freight_cost,
       totaldue
from sales_salesorderdetail od
join sales_salesorderheader soh ON od.salesorderid = soh.salesorderid
where year(soh.orderdate) = 2013
order by orderdate asc, COALESCE(soh.freight, 0) ASC
LIMIT 4