/*Q.1 Retrieve the total number of orders placed.*/
select count(order_id) as total_orders from orders;

/*Q.2 Calculate the total revenue generated from pizza sales.*/
select round(sum(pizzas.price*order_details.quantity), 2) as revenue 
from pizzas 
join order_details 
on pizzas.pizza_id = order_details.pizza_id;

/* Q.3 Total no pizza sold per month */
select monthname(orders.order_date) as orders_placed, sum(order_details.quantity) as quantity_per_month
from orders 
join order_details
on orders.order_id = order_details.order_id
group by orders_placed
order by quantity_per_month; 
 
/*Q.4 Identify the highest-priced pizza.*/
select pizza_types.name, pizzas.price 
from pizzas 
join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
order by pizzas.price desc 
limit 1;

/*Q.5 Identify the most common pizza size ordered.*/
select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas
join order_details 
on pizzas.pizza_id = order_details.pizza_id 
group by pizzas.size 
order by order_count desc 
limit 1;

/*Q.6 Identify the highest order value made in the year*/
select order_details.order_id, sum(order_details.quantity*pizzas.price) as order_value
from pizzas
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by order_details.order_id
order by order_value desc
limit 1;

/*Q.7 List the top 5 most ordered pizza types along with their quantities.*/
select pizza_types.name, sum(order_details.quantity) as order_quantity
from pizzas 
join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id 
group by pizza_types.name 
order by order_quantity desc 
limit 5;

/* Q.8 Find the total quantity of each pizza category ordered.*/
select pizza_types.category as pizza_category, sum(order_details.quantity) as total_quantity
from pizzas 
join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id 
group by pizza_category
order by total_quantity desc;

/* Q.9 Determine the distribution of orders by hour of the day.*/
 select hour(order_time) as order_distribution, count(order_id) as orders_placed 
 from orders 
 group by order_distribution 
 order by orders_placed desc; 
 
/* Q.10 Find the category-wise distribution of pizzas.i.e. how many types of pizza each category contain*/
select category, count(name) as no_of_pizzas from pizza_types group by category order by no_of_pizzas desc; 

/* Q.11 Calculate the average number of pizzas ordered per day.*/
select round(avg(quantity_ordered), 0) as avg_pizza_ordered_per_day
from (select orders.order_date as date, sum(order_details.quantity) as quantity_ordered 
from orders 
join order_details 
on orders.order_id = order_details.order_id 
group by date 
order by quantity_ordered) as total_order_per_day; /* here subquery is giving us the total no of pizzas ordered per day

/* Q.12 Determine the top 3 most ordered pizza types based on revenue.*/
select pizza_types.name as most_ordered_pizza, sum(pizzas.price*order_details.quantity) as revenue_generated
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on pizzas.pizza_id = order_details.pizza_id 
group by most_ordered_pizza
order by revenue_generated desc
limit 3; 

/*Q.13 Determine the least 3 ordered pizza types based on revenue.*/
select pizza_types.name as most_ordered_pizza, sum(pizzas.price*order_details.quantity) as revenue_generated
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on pizzas.pizza_id = order_details.pizza_id 
group by most_ordered_pizza
order by revenue_generated asc
limit 3; 

/* Q.14 Calculate the percentage contribution of each pizza type/category to total revenue.*/
select pizza_types.category, round(sum(order_details.quantity*pizzas.price)/(select round(sum(pizzas.price*order_details.quantity), 2) as revenue 
from pizzas 
join order_details 
on pizzas.pizza_id = order_details.pizza_id)*100, 2) as revenue 
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category order by revenue desc; /* here subquery is giving total revenue generated overall*/

/* Q.15 Analyze the cumulative revenue generated over time.*/
select order_date, sum(revenue) over (order by order_date) as cumulative_revenue 
from
(select orders.order_date, sum(pizzas.price*order_details.quantity) as revenue 
from pizzas 
join order_details 
on pizzas.pizza_id = order_details.pizza_id  
join orders 
on orders.order_id = order_details.order_id 
group by orders.order_date) as sales; /* Subquery is giving sum of revenue based on date
 
/* Q.16 Determine the top 3 most ordered pizza types(names) based on revenue for each pizza category.*/
select name, revenue
from 
(select category, name, revenue, 
rank() over(partition by category order by revenue desc ) as rn
from
(select pizza_types.category, pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue 
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;