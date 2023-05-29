create database Project;
Use project;
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(50),
    reports_to INT,
    levels VARCHAR(20),
    birthdate VARCHAR(50),
    hire_date VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(20),
    state VARCHAR(20),
    country VARCHAR(20),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    fax VARCHAR(20),
    email VARCHAR(50)
);
alter table employee
add constraint emp_fk
foreign key (reports_to)
references Employee(employee_id);
SELECT 
    *
FROM
    Employee;
desc employee;
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    company VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(20),
    country VARCHAR(20),
    postal_code VARCHAR(50),
    phone VARCHAR(20),
    fax VARCHAR(20),
    email VARCHAR(50),
    support_rep_id INT,
    CONSTRAINT emp_cust_fk FOREIGN KEY (support_rep_id)
        REFERENCES employee (employee_id)
);
SELECT 
    *
FROM
    customer;
CREATE TABLE Invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date DATETIME,
    billing_address VARCHAR(100),
    billing_city VARCHAR(30),
    billing_state VARCHAR(20),
    billing_country VARCHAR(20),
    billing_postal_code VARCHAR(50),
    total DECIMAL(5 , 2 ),
    CONSTRAINT cust_invo_fk FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id)
);
SELECT 
    *
FROM
    invoice;
desc invoice;

CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100)
);
SELECT 
    *
FROM
    artist;
desc artist;
CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title VARCHAR(100),
    artist_id INT,
    CONSTRAINT album_artist_fk FOREIGN KEY (artist_id)
        REFERENCES artist (artist_id)
);


-- • Who is the senior most employee based on job title?
SELECT 
    *
FROM
    employee
WHERE
    reports_to IS NULL;
    
-- • Which countries have the most Invoices?
SELECT 
    billing_country AS country,
    COUNT(invoice_id) AS total_invoices
FROM
    invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

-- • What are top 3 values of total invoice?
SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;


/*

• Which city has the best customers? We would like to throw a promotional
Music Festival in the city we made the most money. Write a query that
returns one city that has the highest sum of invoice totals. Return both the
city name & sum of all invoice totals

*/

-- METHOD-1

WITH cte1 AS (SELECT billing_city,SUM(total) AS total
 FROM invoice
GROUP BY billing_city)
SELECT billing_city AS city,total 
FROM cte1
WHERE total=(SELECT max(total) FROM cte1);

-- METHOD-2

SELECT 
    billing_city, SUM(total) AS total
FROM
    invoice
GROUP BY billing_city
ORDER BY total DESC
LIMIT 1;

/*

• Who is the best customer? The customer who has spent the most money will
be declared the best customer. Write a query that returns the person who
has spent the most money


*/

-- METHOD-1

WITH cte1 AS(SELECT customer_id,SUM(total) AS money_spent
FROM invoice
GROUP BY customer_id)
SELECT * FROM customer
LEFT JOIN cte1
USING(customer_id)
WHERE money_spent=(SELECT MAX(money_spent) FROM cte1);

-- METHOD-2

SELECT 
    CONCAT(first_name, ' ', last_name) AS name,
    SUM(total) AS money_spent
FROM
    customer
        JOIN
    invoice USING (customer_id)
GROUP BY name
ORDER BY money_spent DESC
LIMIT 1;


/*

• Write query to return the email, first name, last name, & Genre of all Rock
Music listeners. Return your list ordered alphabetically by email starting with
A


*/

WITH cte1 AS 
		(SELECT g.name,track_id 
        FROM track t 
        JOIN genre g 
        USING(genre_id) 
        WHERE g.name="rock"),
cte2 AS
		(SELECT invoice_id,name 
        FROM invoice_line
		JOIN cte1
		USING(track_id)),
cte3 AS
		(SELECT email,first_name,last_name,invoice_id
		FROM customer
		JOIN invoice
		USING(customer_id))

SELECT email,first_name,last_name,name as genre_name
FROM cte3
JOIN cte2 
USING(invoice_id)
ORDER BY email
;

/*

• Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the Artist name and total track count of the top 10
rock bands

*/

WITH cte1 AS 
		(SELECT track_id,album_id 
        FROM track t 
        JOIN genre g 
        USING(genre_id) 
        WHERE g.name="rock"),
cte2 AS 
		(SELECT name,album_id 
        FROM artist 
        JOIN album 
        USING(artist_id))
        
SELECT 
		name,count(track_id) AS total_track_count 
FROM cte2
JOIN cte1 
USING(album_id)
GROUP BY name
ORDER BY total_track_count DESC
LIMIT 10;


/*

• Return all the track names that have a song length longer than the average
song length. Return the Name and Milliseconds for each track. Order by the
song length with the longest songs listed first

*/


SELECT name,milliseconds 
FROM track
WHERE milliseconds>(SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;


/*

• Find how much amount spent by each customer on artists? Write a query to
return customer name, artist name and total spent

*/

WITH cte1 AS 
		(SELECT name,album_id 
        FROM artist 
        JOIN album 
        USING(artist_id)),
cte2 AS
		(SELECT invoice_id,album_id 
        FROM invoice_line
		JOIN track
		USING(track_id)),
cte3 AS 
		(SELECT invoice_id,c1.name 
        FROM cte1 c1
		JOIN cte2 c2
		USING(album_id)),
cte4 AS 	
		(SELECT CONCAT(first_name, ' ', last_name) AS cust_name,invoice_id,total
        FROM customer
		JOIN invoice
		USING(customer_id))
SELECT 
	cust_name,name AS artist_name,SUM(total) AS total_money_spent
FROM cte4 
JOIN cte3
USING(invoice_id)
GROUP BY cust_name,name;

/*

• We want to find out the most popular music Genre for each country. We
determine the most popular genre as the genre with the highest amount of
purchases. Write a query that returns each country along with the top Genre.
For countries where the maximum number of purchases is shared return all
Genres


*/

WITH cte1 AS 
		(SELECT g.name,track_id 
        FROM track t 
        JOIN genre g 
        USING(genre_id)),
cte2 AS
		(SELECT billing_country,invoice_id,track_id
        FROM invoice_line
		JOIN invoice
		USING(invoice_id)),
cte3 AS
		(SELECT billing_country,name,count(invoice_id) AS total_sales 
        FROM cte1
		JOIN cte2
		USING(track_id)
		GROUP BY name,billing_country),
cte4 AS (SELECT billing_country,MAX(total_sales) AS most_sales 
		FROM cte3
		GROUP BY billing_country)
SELECT c1.billing_country AS country,name AS genre,most_sales 
FROM cte4 c1
JOIN cte3 c2
ON c2.total_sales=c1.most_sales

UNION

SELECT billing_country AS country,name AS genre,total_sales AS most_sales 
FROM cte3
WHERE billing_country = "USA"
;

/*

• Write a query that determines the customer that has spent the most on
music for each country. Write a query that returns the country along with the
top customer and how much they spent. For countries where the top amount
spent is shared, provide all customers who spent this amount

*/

WITH cte1 AS
		(SELECT customer_id,billing_country,sum(total) AS money_spent
		FROM invoice
		GROUP BY billing_country,customer_id),
cte2 AS
		(SELECT billing_country,MAX(money_spent) AS most_spent 
        FROM cte1
		GROUP BY billing_country)
        
SELECT c1.billing_country,CONCAT(first_name, ' ', last_name) AS cust_name,most_spent 
FROM cte1 c1
JOIN cte2 c2
ON c1.money_spent=c2.most_spent AND c1.billing_country=c2.billing_country
JOIN customer
USING(customer_id)
ORDER BY most_spent DESC
;

