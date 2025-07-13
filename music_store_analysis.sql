
-- Q1. Who is the senior most employee based on job title?
SELECT first_name, last_name, title FROM employee ORDER BY title LIMIT 1;

-- Q2. Which countries have the most Invoices?
SELECT billing_country, COUNT(*) AS invoice_count FROM invoice GROUP BY billing_country ORDER BY invoice_count DESC;

-- Q3. What are top 3 values of total invoice?
SELECT total FROM invoice ORDER BY total DESC LIMIT 3;

-- Q4. Which city has the best customers?
SELECT billing_city, SUM(total) AS total_revenue FROM invoice GROUP BY billing_city ORDER BY total_revenue DESC LIMIT 1;

-- Q5. Who is the best customer?
SELECT c.customer_id, first_name, last_name, SUM(total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- Q6. Rock music listeners (emails and names)
SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
ORDER BY email;

-- Q7. Top 10 rock artists by track count
SELECT artist.name, COUNT(*) AS track_count
FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.name
ORDER BY track_count DESC
LIMIT 10;

-- Q8. Tracks longer than average
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

-- Q9. Amount spent by each customer on each artist
SELECT c.first_name, c.last_name, ar.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY c.customer_id, ar.artist_id
ORDER BY total_spent DESC;

-- Q10. Most popular music genre by country
WITH genre_country AS (
    SELECT c.country, g.name AS genre, COUNT(*) AS purchases
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.country, g.name
)
SELECT country, genre
FROM (
    SELECT country, genre, purchases,
           RANK() OVER (PARTITION BY country ORDER BY purchases DESC) AS genre_rank
    FROM genre_country
) ranked
WHERE genre_rank = 1;

-- Q11. Top spending customer per country
WITH customer_spend AS (
    SELECT c.customer_id, c.country, c.first_name, c.last_name, SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
ranked_customers AS (
    SELECT *, RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS rank
    FROM customer_spend
)
SELECT country, first_name, last_name, total_spent
FROM ranked_customers
WHERE rank = 1;

-- Q12. Most popular artists (by purchase count)
SELECT ar.name AS artist_name, COUNT(*) AS purchase_count
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY ar.artist_id
ORDER BY purchase_count DESC
LIMIT 5;

-- Q13. Most popular song
SELECT t.name, COUNT(*) AS times_purchased
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id
ORDER BY times_purchased DESC
LIMIT 1;

-- Q14. Average prices by genre
SELECT g.name AS genre, AVG(il.unit_price) AS avg_price
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.name;

-- Q15. Most popular countries by revenue
SELECT billing_country, SUM(total) AS revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;
