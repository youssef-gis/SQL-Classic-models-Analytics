-- Calculate the average order amount for each cuntry
SELECT c.country ,AVG(od.priceEach * od.quantityOrdered) as avg_order_amount 
FROM customers as c
INNER JOIN orders as o
ON c.customerNumber = o.customerNumber
INNER JOIN  orderdetails as od
ON o.orderNumber = od.orderNumber
GROUP BY c.country
ORDER BY avg_order_amount DESC;

-- Calcculate the total sales for each product Line
SELECT p.productLine ,SUM(od.priceEach * od.quantityOrdered) AS total_sales
-- FROM orders as o
FROM orderdetails as od
-- ON o.orderNumber = od.orderNumber
INNER JOIN products as p
ON od.productCode = p.productCode
GROUP BY p.productLine
ORDER BY total_sales DESC ;


--   top 10 best selling products based on total quantity sold
select p.productName, SUM(od.quantityOrdered) as quantity_ordred
FROM orderdetails AS od
INNER JOIN products p
ON od.productCode = p.productCode
GROUP BY p.productName
order by quantity_ordred DESC
LIMIT 10;

-- Evaluate the sales performance of each sale representative
SELECT emp.employeeNumber, emp.lastName, emp.firstName, COUNT(o.orderNumber) AS num_orders, 
		SUM(od.quantityOrdered * od.priceEach) AS sales_amount, emp.jobTitle
FROM classicmodels.employees emp
INNER JOIN classicmodels.customers c 
ON  emp.employeeNumber = c.salesRepEmployeeNumber
INNER JOIN orders o
ON  c.customerNumber = o.customerNumber
INNER JOIN orderdetails od
ON o.orderNumber = od.orderNumber
GROUP BY emp.employeeNumber
ORDER BY sales_amount DESC;

-- Average Number of orders placed by each customers
SELECT COUNT(o.orderNumber) / COUNT(DISTINCT c.customerNumber) as avg_num_orders
FROM customers as c
LEFT JOIN orders as o
ON c.customerNumber = o.customerNumber;

-- Calculate the percentage of orders that were shipped on time
SELECT  100*(SUM(CASE WHEN requiredDate >= shippedDate THEN 1
		ELSE 0
        END )/COUNT(orderNumber)) AS shipped_on_time_percent
FROM orders;

-- Net profit per product
SELECT productName, SUM(Net_profit) AS Net_profit
FROM
(SELECT  p.productName, ((od.quantityOrdered * od.priceEach) - (od.quantityOrdered * p.buyPrice)) AS Net_profit
FROM products p
LEFT JOIN orderdetails od
ON p.productCode = od.productCode
) t1
GROUP BY productName
ORDER BY Net_profit DESC;


-- seguement customers based on their purchase amount
SELECT customerNumber,customerName, purchase_amount, 
		CASE WHEN purchase_amount >= 87468 THEN 'High'
			 WHEN purchase_amount >= 55866 THEN 'Medium'
             ELSE 'Low'
	     END AS purchase_segument
FROM 
(select  c.customerNumber,c.customerName,SUM(od.quantityOrdered * od.priceEach) AS purchase_amount
from customers c
LEFT JOIN orders o
ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od
ON o.orderNumber = od.orderNumber
GROUP BY c.customerNumber,c.customerName
ORDER BY purchase_amount DESC ) t1 ;

-- Identify frequently co-purchased products
select  od.productCode, p.productName, od1.productCode, p1.productName,  COUNT(*) AS pair_purchase
from orderdetails od
INNER JOIN orderdetails od1
ON od.orderNumber = od1.orderNumber AND od.productCode < od1.productCode
INNER JOIN products p
ON od1.productCode = p.productCode
INNER JOIN products p1
ON od.productCode = p1.productCode
GROUP BY   od.productCode, p.productName, od1.productCode, p1.productName
ORDER BY pair_purchase DESC