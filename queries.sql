-- =====================================================================
-- MOVIE TICKET BOOKING SYSTEM - QUERIES
-- 10 Easy | 5 Medium | 5 Hard
-- =====================================================================

-- ===================== EASY (10) =====================

-- 1. List all movies released in 2025, newest first.
SELECT title, release_date, certification
FROM movies
WHERE EXTRACT(YEAR FROM release_date) = 2025
ORDER BY release_date DESC;

-- 2. Find customers whose email domain is example.com.
SELECT full_name, email
FROM customers
WHERE email LIKE '%@example.com';

-- 3. Get all shows scheduled on 2026-07-16.
SELECT show_id, movie_id, screen_id, start_time
FROM shows
WHERE show_date = '2026-07-16';

-- 4. List all theatres located in Hyderabad.
SELECT theatre_name, address, phone
FROM theatres
WHERE city = 'Hyderabad';

-- 5. Count the number of movies per certification category.
SELECT certification, COUNT(*) AS movie_count
FROM movies
GROUP BY certification
ORDER BY movie_count DESC;

-- 6. Top 5 highest base-priced shows.
SELECT show_id, movie_id, base_price
FROM shows
ORDER BY base_price DESC
LIMIT 5;

-- 7. Compute the overall average review rating across all movies.
SELECT ROUND(AVG(rating), 2) AS overall_avg_rating
FROM reviews;

-- 8. Count seats available per seat type across the entire system.
SELECT seat_type, COUNT(*) AS total_seats
FROM seats
GROUP BY seat_type
ORDER BY total_seats DESC;

-- 9. List the 10 most recently registered customers.
SELECT full_name, email, created_at
FROM customers
ORDER BY created_at DESC
LIMIT 10;

-- 10. List all cancelled bookings.
SELECT booking_id, customer_id, show_id, total_amount
FROM bookings
WHERE booking_status = 'CANCELLED';

-- ===================== MEDIUM (5) =====================

-- 11. INNER JOIN: list every movie with its associated genre names.
SELECT m.title, g.genre_name
FROM movies m
INNER JOIN movie_genres mg ON m.movie_id = mg.movie_id
INNER JOIN genres g ON mg.genre_id = g.genre_id
ORDER BY m.title;

-- 12. LEFT JOIN: find movies that have not received any review.
SELECT m.title
FROM movies m
LEFT JOIN reviews r ON m.movie_id = r.movie_id
WHERE r.review_id IS NULL;

-- 13. Multiple JOINs: full booking summary with customer, movie, screen and theatre.
SELECT b.booking_id, c.full_name, m.title, s.show_date, s.start_time,
       sc.screen_name, t.theatre_name, b.total_amount
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN shows s ON b.show_id = s.show_id
JOIN movies m ON s.movie_id = m.movie_id
JOIN screens sc ON s.screen_id = sc.screen_id
JOIN theatres t ON sc.theatre_id = t.theatre_id
ORDER BY b.booking_id;

-- 14. HAVING: theatres that operate more than 1 screen.
SELECT t.theatre_name, COUNT(sc.screen_id) AS screen_count
FROM theatres t
JOIN screens sc ON t.theatre_id = sc.theatre_id
GROUP BY t.theatre_name
HAVING COUNT(sc.screen_id) > 1;

-- 15. Subquery: movies rated above the system-wide average rating.
SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM movies m
JOIN reviews r ON m.movie_id = r.movie_id
GROUP BY m.title
HAVING AVG(r.rating) > (SELECT AVG(rating) FROM reviews);

-- ===================== HARD (5) =====================

-- 16. Correlated subquery: customers whose booking count exceeds the average booking count per customer.
SELECT c.full_name,
       (SELECT COUNT(*) FROM bookings b WHERE b.customer_id = c.customer_id) AS booking_count
FROM customers c
WHERE (SELECT COUNT(*) FROM bookings b WHERE b.customer_id = c.customer_id)
      > (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM bookings GROUP BY customer_id) sub);

-- 17. EXISTS: movies that currently have at least one scheduled show but no reviews yet.
SELECT m.title
FROM movies m
WHERE EXISTS (SELECT 1 FROM shows s WHERE s.movie_id = m.movie_id)
  AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.movie_id = m.movie_id);

-- 18. NOT EXISTS: customers who have never made a booking.
SELECT c.full_name, c.email
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM bookings b WHERE b.customer_id = c.customer_id);

-- 19. Complex analytical: total confirmed revenue per theatre, per calendar month.
SELECT t.theatre_name,
       DATE_TRUNC('month', s.show_date) AS month,
       SUM(p.amount) AS total_revenue
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id
JOIN shows s ON b.show_id = s.show_id
JOIN screens sc ON s.screen_id = sc.screen_id
JOIN theatres t ON sc.theatre_id = t.theatre_id
WHERE b.booking_status = 'CONFIRMED' AND p.payment_status = 'SUCCESS'
GROUP BY t.theatre_name, DATE_TRUNC('month', s.show_date)
ORDER BY t.theatre_name, month;

-- 20. Window function: rank each movie's shows by revenue to find the top-grossing show per movie.
SELECT movie_title, show_id, show_revenue, revenue_rank
FROM (
    SELECT m.title AS movie_title, s.show_id,
           SUM(tk.price_paid) AS show_revenue,
           RANK() OVER (PARTITION BY m.movie_id ORDER BY SUM(tk.price_paid) DESC) AS revenue_rank
    FROM movies m
    JOIN shows s ON m.movie_id = s.movie_id
    JOIN tickets tk ON s.show_id = tk.show_id
    GROUP BY m.title, m.movie_id, s.show_id
) ranked
WHERE revenue_rank = 1
ORDER BY show_revenue DESC;
