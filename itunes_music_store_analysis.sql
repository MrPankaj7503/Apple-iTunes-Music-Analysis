
-- iTunes Apple Music Store Analysis SQL Script

-- Drop tables if they already exist
DROP TABLE IF EXISTS artists, albums, tracks, genres, customers, purchases;

-- 1. Artists
CREATE TABLE artists (
    artist_id INTEGER PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL
);

-- 2. Albums
CREATE TABLE albums (
    album_id INTEGER PRIMARY KEY,
    album_name VARCHAR(100),
    artist_id INTEGER,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- 3. Genres
CREATE TABLE genres (
    genre_id INTEGER PRIMARY KEY,
    genre_name VARCHAR(50)
);

-- 4. Tracks
CREATE TABLE tracks (
    track_id INTEGER PRIMARY KEY,
    track_name VARCHAR(100),
    album_id INTEGER,
    genre_id INTEGER,
    duration_seconds INTEGER,
    price DECIMAL(5,2),
    FOREIGN KEY (album_id) REFERENCES albums(album_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- 5. Customers
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    country VARCHAR(50)
);

-- 6. Purchases
CREATE TABLE purchases (
    purchase_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    track_id INTEGER,
    purchase_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (track_id) REFERENCES tracks(track_id)
);

-- Sample Data Insertion
INSERT INTO artists VALUES (1, 'Taylor Swift'), (2, 'Ed Sheeran'), (3, 'Adele');

INSERT INTO albums VALUES 
    (1, '1989', 1),
    (2, 'Divide', 2),
    (3, '25', 3);

INSERT INTO genres VALUES 
    (1, 'Pop'),
    (2, 'Rock'),
    (3, 'R&B');

INSERT INTO tracks VALUES 
    (1, 'Blank Space', 1, 1, 231, 1.29),
    (2, 'Style', 1, 1, 245, 1.29),
    (3, 'Shape of You', 2, 1, 263, 1.29),
    (4, 'Photograph', 2, 2, 258, 1.29),
    (5, 'Hello', 3, 3, 295, 1.29);

INSERT INTO customers VALUES 
    (1, 'Alice', 'USA'),
    (2, 'Bob', 'Canada'),
    (3, 'Carlos', 'Brazil');

INSERT INTO purchases VALUES 
    (1, 1, 1, '2024-01-15'),
    (2, 1, 3, '2024-01-20'),
    (3, 2, 5, '2024-02-01'),
    (4, 3, 2, '2024-03-12'),
    (5, 3, 4, '2024-04-01');

-- Analysis Queries

-- 1. Top Selling Tracks
SELECT t.track_name, COUNT(p.purchase_id) AS sales
FROM tracks t
JOIN purchases p ON t.track_id = p.track_id
GROUP BY t.track_name
ORDER BY sales DESC;

-- 2. Revenue by Artist
SELECT a.artist_name, SUM(t.price) AS total_revenue
FROM artists a
JOIN albums al ON a.artist_id = al.artist_id
JOIN tracks t ON al.album_id = t.album_id
JOIN purchases p ON t.track_id = p.track_id
GROUP BY a.artist_name
ORDER BY total_revenue DESC;

-- 3. Most Popular Genre
SELECT g.genre_name, COUNT(p.purchase_id) AS total_sales
FROM genres g
JOIN tracks t ON g.genre_id = t.genre_id
JOIN purchases p ON t.track_id = p.track_id
GROUP BY g.genre_name
ORDER BY total_sales DESC;

-- 4. Top Customers by Purchase Count
SELECT c.customer_name, COUNT(p.purchase_id) AS total_purchases
FROM customers c
JOIN purchases p ON c.customer_id = p.customer_id
GROUP BY c.customer_name
ORDER BY total_purchases DESC;

-- 5. Monthly Sales
SELECT DATE_FORMAT(purchase_date, '%Y-%m') AS month, COUNT(*) AS total_sales
FROM purchases
GROUP BY month
ORDER BY month;
