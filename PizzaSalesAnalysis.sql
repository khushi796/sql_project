-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS TOTAL_ORDERS
FROM
    ORDERS;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(Order_Details.quantity * Pizzas.Price),
            2) AS Total_Revenue
FROM
    Order_Details
        LEFT JOIN
    Pizzas ON Order_Details.Pizza_id = Pizzas.Pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pizza_types_utf8.NAME, Pizzas.size, pizzas.price
FROM
    Pizzas
        LEFT JOIN
    Pizza_types_utf8 ON pizzas.Pizza_type_id = pizza_types_utf8.Pizza_type_id
ORDER BY Price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    Pizzas.Size, SUM(Order_Details.Quantity) AS Size_Quantity
FROM
    Order_Details
        LEFT JOIN
    Pizzas ON Order_Details.Pizza_id = Pizzas.Pizza_id
GROUP BY Pizzas.Size
ORDER BY Size_Quantity DESC
LIMIT 5;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    SUM(Order_Details.Quantity) AS QUANTITY_TYPE, SUBQUERY.name
FROM
    Order_details
        LEFT JOIN
    (SELECT 
        pizzas.pizza_id, pizzas.pizza_type_id, pizza_types_utf8.name
    FROM
        PIZZAS
    LEFT JOIN pizza_types_utf8 ON Pizzas.Pizza_type_id = pizza_types_utf8.Pizza_type_id) AS SUBQUERY ON Order_details.Pizza_id = SUBQUERY.Pizza_id
GROUP BY pizza_types_utf8.name
ORDER BY QUANTITY_TYPE DESC
LIMIT 5; 

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    Sq.Category, SUM(Od.quantity) AS Category_Quantity
FROM
    Order_Details AS Od
        LEFT JOIN
    (SELECT 
        Ps.Pizza_id, Pt.Category
    FROM
        Pizzas AS Ps
    LEFT JOIN Pizza_types_utf8 AS Pt ON Ps.Pizza_type_id = Pt.Pizza_type_id) AS Sq ON Od.Pizza_id = Sq.Pizza_id
GROUP BY Sq.Category
ORDER BY Category_Quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_Time) AS Hour_of_the_day,
    COUNT(Order_id) AS Number_Of_Orders
FROM
    Orders
GROUP BY Hour_Of_the_day;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    COUNT(pizza_type_id) AS COUNT, Category
FROM
    pizza_types_utf8
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    SUM(OD.QUANTITY) / COUNT(DISTINCT ORDER_DATE) AS AVG_NUM_OF_PIZZA_PER_DAY
FROM
    orders AS o
        INNER JOIN
    order_details AS od ON o.order_id = od.order_id;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    SUM(od.quantity * ps.price) AS price_type,
    pt.pizza_type_id,
    pt.name
FROM
    pizza_types_utf8 AS pt
        JOIN
    pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = ps.pizza_id
        JOIN
    orders AS os ON od.order_id = os.order_id
GROUP BY pt.pizza_type_id
ORDER BY price_type DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    sq1.pizza_type_id,
    sq1.name,
    (sq1.revenue / sq2.total_revenue) * 100 AS Percent_Contri
FROM
    (SELECT 
        pt.pizza_type_id,
            pt.name,
            SUM(ps.price * od.quantity) AS revenue
    FROM
        pizza_types_utf8 AS pt
    JOIN pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
    JOIN order_details AS od ON od.pizza_id = ps.pizza_id
    GROUP BY Pizza_type_id) AS Sq1
        CROSS JOIN
    (SELECT 
        SUM(Sq1.REVENUE) AS Total_Revenue
    FROM
        (SELECT 
        pt.pizza_type_id,
            pt.name,
            SUM(ps.price * od.quantity) AS revenue
    FROM
        pizza_types_utf8 AS pt
    JOIN pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
    JOIN order_details AS od ON od.pizza_id = ps.pizza_id
    GROUP BY Pizza_type_id) AS Sq1) AS Sq2; 

-- Analyze the cumulative revenue generated over time
SELECT Round(SUM(REVENUE) OVER(ORDER BY ORDER_DATE) ,2) AS Cumulative_Revenue, Order_date from (SELECT 
    ROUND(SUM(od.quantity * ps.price), 2) AS Revenue,
    os.order_date
FROM
    Pizzas AS ps
        JOIN
    Order_Details AS od ON ps.pizza_id = od.pizza_id
        JOIN
    orders AS os ON od.order_id = os.order_id
GROUP BY os.order_date) AS Sq;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT sq2.rank , sq2.category, sq2.name, sq2.revenue from (SELECT row_number() 
over (partition by category order by revenue desc) 
as 'rank',revenue, category, sq.name, pizza_type_id from (SELECT 
    pt.category,
    pt.name,
    pt.pizza_type_id,
    (ps.price * od.quantity) AS revenue
FROM
    pizza_types_utf8 AS pt
        JOIN
    pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
        JOIN
    order_details AS od ON ps.pizza_id = od.pizza_id) as Sq) as sq2 where sq2.rank <= 3 
	order by category,sq2.rank;
