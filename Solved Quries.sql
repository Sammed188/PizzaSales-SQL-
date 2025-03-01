CREATE DATABASE dbpizza;
USE dbpizza;
SELECT * FROM orders;
SELECT * FROM order_details;
SELECT * FROM Pizza_types;
SELECT * FROM pizzas;

-- Retrieve the total number of orders placed.
SELECT count(order_id) as Total_Orders 
FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS Total_price
FROM
    pizzas p
INNER JOIN
    Order_details od ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
SELECT pt.name, p.price as Highest_priced_pizza 
FROM pizza_types pt
INNER JOIN pizzas p 
ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC 
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT p.size as most_commonly_use_size, count(od.order_details_id) as Number_of_orders
FROM pizzas p 
INNER JOIN Order_details od
ON p.pizza_id = od.pizza_id
group by 1
Having count(od.order_details_id)
order by count(od.order_details_id) desc
Limit 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT pt.pizza_type_id, pt.name, count(o.order_id) as Most_purchased, sum(od.quantity) as total_quantity
FROM pizzas p 
INNER JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id 
INNER JOIN order_details od
ON p.pizza_id = od.Pizza_id
Inner join orders o
on o.order_id = od.order_id
group by 1, 2
order by count(o.order_id) desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pt.category, sum(od.quantity) as total_quantity
FROM pizzas p 
INNER JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id 
INNER JOIN order_details od
ON p.pizza_id = od.Pizza_id
GROUP BY 1;

-- Determine the distribution of orders by hour of the day.
SELECT hour(time) as Hours, count(order_id) as Total_orders
FROM orders 
Group by 1;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, count(name) as Total_pizzas
FROM pizza_types
GROUP BY 1;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select ROUND(avg(total_count),2) as average
from (
SELECT o.date, SUM(od.quantity) as  total_count
FROM order_Details od
join orders o
on od.order_id = o.order_id
GROUP BY 1) AS SUB;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name, ROUND(SUM(p.price * od.quantity), 2) AS Total_price
FROM pizzas p
INNER JOIN Order_details od 
ON p.pizza_id = od.pizza_id
INNER JOIN pizza_types pt
ON p.pizza_type_id = PT.pizza_type_id
GROUP BY  1
ORDER BY ROUND(SUM(p.price * od.quantity), 2) DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category, round((SUM(p.price * od.quantity) / (SELECT sum(p.price * od.quantity)
												FROM pizzas p
												INNER JOIN Order_details od 
												ON p.pizza_id = od.pizza_id)) * 100,2) as Percentage_countribution
FROM pizzas p
INNER JOIN Order_details od 
ON p.pizza_id = od.pizza_id
INNER JOIN pizza_types pt
ON p.pizza_type_id = Pt.Pizza_type_id
group by 1;

-- Analyze the cumulative revenue generated over time.

WITH total_revenue as (
SELECT o.date, sum(p.price * od.quantity) as revenue
FROM pizzas p
INNER JOIN Order_details od 
ON p.pizza_id = od.pizza_id
INNER JOIN orders o
ON od.order_id = o.order_id
GROUP BY 1)
SELECT date, sum(revenue) over(order by date) as cum_revenue
FROM total_revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
select category, name, dense_rank() over(partition by category order by revenue desc) as ranking
from (
SELECT pt.category, pt.name, sum(p.price * od.quantity) as revenue
FROM pizzas p
INNER JOIN Order_details od 
ON p.pizza_id = od.pizza_id		
INNER JOIN pizza_types pt
ON p.pizza_type_id = PT.pizza_type_id	
GROUP BY pt.category, pt.name) as sub)
select category, name, ranking
from cte 
where ranking <= 3;
																																	










