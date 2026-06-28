-- Business Analysis
-- ------------------------Revenue---------------------

-- Total Revenue
select round(sum(payment_value),2) as Total_Revenue
from payments;

-- Monthly Revenue - Growth trend
select o.order_year, o.order_month_name, round(sum(payment_value),2) as Total_monthly_revenue
from Payments p
left join orders o
on p.order_id = o.order_id
group by o.order_year,
o.order_month_name
order by o.order_year,
o.order_month_name;

-- Revenue Growth % - Is business improving?
with monthly_revenue as (
    select
        o.order_year,
        o.order_month,
        o.order_month_name,
        round(sum(p.payment_value), 2) as revenue
    from payments p
    join orders o
        on p.order_id = o.order_id
    group by
        o.order_year,
        o.order_month,
        o.order_month_name
)

select
    order_year,
    order_month,
    order_month_name,
    revenue,
    lag(revenue) over (
	order by order_year, order_month
    ) as previous_revenue,
    round((revenue -lag(revenue) 
    over ( order by order_year, order_month)
        ) /
        lag(revenue) over (
            order by order_year, order_month
        ) * 100,
        2
    ) as revenue_growth_pct
from monthly_revenue
order by
    order_year,
    order_month;
    
-- Revenue by Category - Which products make money?
select
    pd.product_category_name,
    round(sum(oi.price), 2) as revenue
from order_items oi
join products pd
    on oi.product_id = pd.product_id
group by pd.product_category_name
order by revenue desc;

-- Revenue by State

select
c.customer_state,
round(sum(oi.price), 2) as revenue
from order_items oi
join orders o
on oi.order_id = o.order_id
join customers c
on o.customer_id = c.customer_id
group by c.customer_state
order by revenue desc;


-- ------------------------order---------------------

-- Total Orders
select count(order_id) as Total_orders from orders;

-- Orders per Month

select order_year, order_month, count(order_id) as Tot_order
from orders
group by order_year, order_month
order by order_year, order_month;

-- Average Order Value
select
round(sum(payment_value) /count(distinct order_id),2 )
as avg_order_value
from payments;

-- Cancelled Orders %
select
    round(
        count(case
            when order_status = 'canceled'
            then 1
        end)
        * 100.0
        / count(*),
        2
    ) as cancelled_order_pct
from orders;

-- ---------------------------Customers-------------------

-- Total Customers
select count(customer_id) as Total_customer
from customers;

-- New Customers per Month

-- select order_year, order_month, count(*), lag(count(*)) over (
-- 	order by order_year, order_month) as nxt, 
--     (count(*) - lag(count(*)) over (
-- 	order by order_year, order_month)) as new_customers
--     from customers c
-- join orders o
-- on c.customer_id = o.customer_id
-- group by order_year, order_month
-- order by order_year, order_month;

select
    year(first_order_date) as order_year,
    month(first_order_date) as order_month,
    count(*) as new_customers
from (
    select
        customer_id,
        min(order_purchase_timestamp) as first_order_date
    from orders
    group by customer_id
) t
group by
    year(first_order_date),
    month(first_order_date)
order by
    order_year,
    order_month;

-- Repeat Customers

select
    customer_id,
    count(order_id) as total_orders
from orders
group by customer_id
having count(order_id) > 1;

-- Repeat Customer Rate
select
    round(
        count(*) * 100.0 /
        (
            select count(distinct customer_id)
            from orders
        ),
        2
    ) as repeat_customer_rate
from (
    select customer_id
    from orders
    group by customer_id
    having count(order_id) > 1
) t;
