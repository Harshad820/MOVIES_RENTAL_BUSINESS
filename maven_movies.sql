USE MAVENMOVIES;

SELECT count(*)
FROM RENTAL;

SELECT count(*)
FROM INVENTORY;

SELECT count(*)
FROM ACTOR;

select count(*)
from film;

select count(*)
from customer;
-- PROVIDE MONTHLY REVENUE PER YEAR FOR INVESTORS

select x.month_name, x.year, sum(amount) as total
from(select *,extract(year from payment_date) as year,date_format(payment_date,"%b") as month_name
from payment) as x
group by x.month_name,x.year;


-- PROVIDE A LIST OF TOP 10 CUSTOMER BASED ON REVENUE TO PUSH OFFERES TO THEM 
select * from payment;
select * from customer;

select *
from customer
where customer_id in (
select x.customer_id
from(select customer_id,sum(amount) as revenue
from payment
group by customer_id
order by revenue desc
limit 10) as x);


-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.


-- You need to provide customer firstname, lastname and email id to the marketing team --

select first_name,last_name,email
from customer;

-- How many movies are with rental rate of $0.99? --

select count(*) as rental_reate_
from film 
where rental_rate=0.99;


-- We want to see rental rate and how many movies are in each rental category --

select rental_rate,count(*) 
from film
group by rental_rate;



-- Which rating has the most films? --

select rating,count(*) as no_of_movies
from film
group by rating
order by no_of_movies desc
limit 1;



-- Which rating is most prevalant in each store? --

select i.store_id,f.rating,count(inventory_id) as copies
from film as f left join inventory as i
on f.film_id=i.film_id
group by i.store_id,f.rating
order by store_id,copies desc;


-- List of films by Film Name, Category, Language --

select f.title,c.name,l.name
from film as f left join film_category as fc
on f.film_id=fc.film_id
left join category as c on fc.category_id=c.category_id
left join language as l on f.language_id=l.language_id;



-- How many times each movie has been rented out?

select f.title,count(rental_id) as total
from rental as r left join inventory as i
on r.inventory_id=i.inventory_id
left join film as f on i.film_id=f.film_id
group by f.title
order by total desc;



-- REVENUE PER FILM (TOP 10 GROSSERS)

SELECT 
    f.title, SUM(p.amount) AS revenue
FROM
    payment AS p
        LEFT JOIN
    rental AS r ON p.rental_id = r.rental_id
        LEFT JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
        LEFT JOIN
    film AS f ON f.film_id = i.film_id
GROUP BY f.title
ORDER BY revenue DESC
LIMIT 10;



-- Most Spending Customer so that we can send him/her rewards or debate points

select c.customer_id,sum(p.amount) as total
from customer as c left join payment as p
on c.customer_id=p.customer_id
group by c.customer_id
order by total desc;


-- Which Store has historically brought the most revenue?cross

select st.store_id,sum(p.amount) as revenue
from payment as p left join staff as s
on p.staff_id=s.staff_id 
left join store as st on st.store_id=s.store_id
group by st.store_id
order by revenue desc;



-- How many rentals we have for each month

select x.month,x.year,count(month) as total_rentals
from( select *,extract(month from rental_date) as month,extract(year from rental_date) as year
from rental) as x
group by x.month,x.year
order by total_rentals desc;


SELECT MONTHNAME(RENTAL_DATE) AS MONTH_NAME,EXTRACT(YEAR FROM RENTAL_DATE) AS YEAR_NUMBR, COUNT(rental.rental_id) AS NUMBER_RENTALS
FROM RENTAL
GROUP BY EXTRACT(YEAR FROM RENTAL_DATE),MONTHNAME(RENTAL_DATE)
ORDER BY NUMBER_RENTALS DESC;



-- Reward users who have rented at least 30 times (with details of customers)

select customer_id,count(rental_id) as rented_no_times
from rental
group by customer_id
having rented_no_times >=30
order by rented_no_times desc;




-- Could you pull all payments from our first 100 customers (based on customer ID)

select *
from payment as p
where customer_id <101 ;


SELECT CUSTOMER_ID,RENTAL_ID,AMOUNT,PAYMENT_DATE
FROM PAYMENT
WHERE CUSTOMER_ID<101;



-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006

select *
from payment
where amount > 5 and payment_date>'2006-01-01';



-- Now, could you please write a query to pull all payments from those specific customers, along
-- with payments over $5, from any customer?


select * 
from payment
where amount>5 and customer_id=1;



-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

select *
from film
where special_features like "%Behind the Scenes%";



-- unique movie ratings and number of movies

select rating,count(rating) as no_of_movies
from film
group by rating;


-- Could you please pull a count of titles sliced by rental duration?

select rental_duration,count(rental_duration)
from film
group by rental_duration;



-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION


select rating,count(film_id) as count_movies
,min(length) as shortest_film,
max(length) as longest_film,
avg(length) as average_film,
avg(rental_duration) as avg_rental_duration
from film
group by rating;




-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?



select replacement_cost,count(film_id) as count_movies
,min(rental_rate) as cheapest_rental,
max(rental_rate) as expensive_rental,
avg(rental_rate) as average_rental,
avg(rental_duration) as avg_rental_duration
from film
group by replacement_cost;



-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

select customer_id,count(rental_id) as rented_no_of_times
from rental
group by customer_id
having rented_no_of_times<=15;



-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

select title,length,rental_rate
from film
order by length desc;



-- CATEGORIZE MOVIES AS PER LENGTH

select *,
case
	when length <60 then "short movie"
    when length between 60 and 90 then "medium movie"
    when length >90 then "long movie"
    else "error"
end as length_catecary
from film;




-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

select film_id,title,
case 
	when rental_duration <=4 then "rental to short"
	when rental_rate>=3.99 then "too expensive"
    when rating IN ('NC-17','R') then "too adult"
    when length not between 60 and 90 then "too long or too short"
    else "great for children"
end as recomendation
from film;




-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”


select customer_id,first_name,last_name,
case 
	when store_id=1 and active=1 then "store 1 active"
	when store_id=1 and active=0 then "store 0 inactive"
	when store_id=2 and active=1 then "store 2 active"
	when store_id=2 and active=1 then "store 2 inactive"
else "inactive"
end as status
from customer;



-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

select f.title,f.description,i.store_id,i.inventory_id
from inventory as i inner join film as f
on f.film_id=i.film_id;



-- Actor first_name, last_name and number of movies

select a.actor_id,a.first_name,a.last_name,count(f.film_id) as no_of_film
from actor as a inner join film_actor as f
on a.actor_id=f.actor_id
group by a.actor_id;



-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

select f.film_id,f.title,count(fc.actor_id) 
from film  as f left join film_actor as fc
on f.film_id=fc.film_id
group by f.film_id;



-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
    
select a.first_name,a.last_name,f.title
from actor as a inner join film_actor as fc
on a.actor_id=fc.actor_id 
inner join film as f on fc.film_id=f.film_id;



-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”


select distinct f.title,f.description 
from film as f inner join inventory as i
on f.film_id=i.film_id
where i.store_id=2;



-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”


(select first_name,last_name,'advisors' as designation
from advisor
union
select first_name,last_name,'staff member' as designation
from staff);