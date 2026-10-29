use Pizzahut;

create table order_details(order_details_id  int not null,
order_id int not null,
pizza_id text not null,
qantity int not null,
primary key(order_details_id) ); 

select * from orders;
select * from pizzas;
select * from order_details;
select * from pizza_types;


---Retrive the total number of order placed..

select count(order_id) as total_no_order from orders; --21350


--calculate the total number revenue generated from pizza sales...

select round(sum(p.price*o.quantity),2) as total_revenue from order_details o 
join pizzas p on p.pizza_id = CAST(o.pizza_id AS nvarchar(50)); ---817860.05

--identify the highest price of pizza
select top (1) p.price as highest_priced_pizza ,pt.name from pizzas 
as p join pizza_types pt on pt.pizza_type_id=p.pizza_type_id order by p.price desc ; --35.9500007629395 -The Greek Pizza


--identify the most common pizza size ordered...

select  top (1) pizzas.size,count(order_details.order_details_id) as order_count from pizzas join order_details on pizzas.pizza_id = cast(order_details.pizza_id as nvarchar(50))
group by pizzas.size order by order_count desc;


--list the top 5 pizza types along with their quantities,

select  top (5) pizza_types.name , sum(order_details.quantity) as quantity_sum from  pizza_types join pizzas on pizza_types.pizza_type_id =
pizzas.pizza_type_id join order_details on cast(order_details.pizza_id as nvarchar)=
.pizzas.pizza_id  group by pizza_types.name order by quantity_sum desc;


---OutPut
--The Classic Deluxe Pizza     2453
--The Barbecue Chicken Pizza   2432
--The Hawaiian Pizza           2422
--The Pepperoni Pizza          2418
--The Thai Chicken Pizza       2371



--join the neccessary tables to find the total quantity of each pizza ordered

select sum(od.quantity) as quantity_sum,pt.name  from pizza_types pt join pizzas p on pt.pizza_type_id=p.pizza_type_id 
join order_details od on cast(od.pizza_id as nvarchar(50))=p.pizza_id
group by pt.name;


--join the neccessary tables to find the total quantity of each pizza category  ordered

select sum(od.quantity) as quantity_sum,pt.category  from pizza_types pt join pizzas p on pt.pizza_type_id=p.pizza_type_id 
join order_details od on cast(od.pizza_id as nvarchar(50))=p.pizza_id
group by pt.category order by quantity_sum desc;


--Output --
--14888	Classic
--11987	Supreme
--11649	Veggie
--11050	Chicken

--determine the distribution of orders by hour of the day..

select datepart(hour,time) as hour, count(order_id) as order_id_count from 
orders group by  datepart(hour,time) order by hour desc;
 
--join the relevent tables to find the category - wise distribution of pizzas;
select count(name) as categoryy_count ,category from pizza_types group by category;

--6	Chicken
--8	Classic
--9	Supreme
--9	Veggie

---group the orders by date and calculate the average number of pizzas ordered per day..

select round(avg( sum_of_daily_order ),0) avg_of_quantity from(select  o.date , sum(od.quantity) as sum_of_daily_order from orders o
join order_details od on o.order_id=od.order_id group by o.date ) as order_quantity_date_based;

-- 138 -avg_of_quantity

--determine the top 3 most ordered pizza types based on revenue ..
select top(3) pt.name, sum(od.quantity*p.price) as revenue from pizza_types pt  join pizzas p on 
pt.pizza_type_id=p.pizza_type_id join order_details od  on cast(od.pizza_id as nvarchar )=p.pizza_id 
group by pt.name   order by revenue desc;
 

 --Calculate the percentage contribution  of each pizza type to total revenue...
 select pt.category ,concat(round( (sum(od.quantity*p.price)/(select sum(od.quantity*p.price) as total_sales from order_details od 
 join pizzas p on p.pizza_id=cast( od.pizza_id as nvarchar)))*100,2),'%') as revenue from pizza_types pt join pizzas p on pt.pizza_type_id=p.pizza_type_id 
 join order_details od on cast( od.pizza_id as nvarchar)=p.pizza_id group by pt.category order by revenue desc;
 

--Analyze the cumulative revenue generated over time ..
200 200
300 500
450 950
250 1200

select date , sum(revenue) over(order by date) as cum_revenue from(select o.date , sum(od.quantity*p.price) as revenue from order_details od join pizzas p on cast(od.pizza_id as nvarchar)=p.pizza_id
join orders o on o.order_id =od.order_id group by o.date) as sales  ;



-- determine the top (3) most ordered pizza types based on revenue for each pizza category..
SELECT category, name, revenue, rn
FROM
(
    SELECT category, name, revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM
    (
        SELECT
            pt.category,
            pt.name,
            SUM(od.quantity * p.price) AS revenue
        FROM pizza_types pt
        JOIN pizzas p
            ON pt.pizza_type_id = p.pizza_type_id
        JOIN order_details od
            ON CAST(od.pizza_id AS NVARCHAR) = p.pizza_id
        GROUP BY pt.category, pt.name
    ) AS a
) AS b
WHERE rn <= 3
ORDER BY category, rn;

select * from orders;
select * from pizzas;
select * from order_details;
select * from pizza_types;

