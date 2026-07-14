-- =====================================================================
-- MOVIE TICKET BOOKING SYSTEM - SAMPLE DATA
-- Run after ddl.sql
-- =====================================================================

-- ---------- genres ----------
INSERT INTO genres (genre_name) VALUES
('Action'), ('Drama'), ('Comedy'), ('Thriller'), ('Sci-Fi'),
('Romance'), ('Horror'), ('Animation'), ('Crime'), ('Fantasy');

-- ---------- movies ----------
INSERT INTO movies (title, release_date, duration_minutes, language, certification, synopsis) VALUES
('Edge of Tomorrow City',   '2025-01-10', 142, 'English', 'UA', 'A soldier relives a battle against alien invaders.'),
('The Silent Ledger',       '2025-02-14', 128, 'English', 'A',  'A forensic accountant uncovers a banking conspiracy.'),
('Monsoon Melody',          '2025-03-01', 135, 'Hindi',   'U',  'A musician finds love during monsoon season.'),
('Quantum Heist',           '2025-03-20', 118, 'English', 'UA', 'A crew plans an impossible multiverse robbery.'),
('Laughing Stock',          '2025-04-05', 105, 'English', 'U',  'A stand-up comedian navigates fame and failure.'),
('Crimson Alley',           '2025-04-18', 122, 'English', 'A',  'A detective hunts a serial arsonist in the city.'),
('Starlight Odyssey',       '2025-05-02', 150, 'English', 'UA', 'Explorers search for a habitable planet.'),
('The Last Orchard',        '2025-05-16', 110, 'Hindi',   'U',  'A family fights to save their ancestral farmland.'),
('Nightshade Protocol',     '2025-06-01', 132, 'English', 'A',  'A spy uncovers a rogue intelligence operation.'),
('Paper Boats',             '2025-06-15', 98,  'Hindi',   'U',  'Childhood friends reunite after two decades.'),
('Iron Tempest',            '2025-07-04', 140, 'English', 'UA', 'A mech pilot defends a colony from invasion.'),
('Whispers in Neon',        '2025-07-19', 115, 'English', 'A',  'A hacker gets entangled in a corporate cover-up.'),
('The Cartographer',        '2025-08-08', 125, 'English', 'U',  'A mapmaker discovers a lost civilization.'),
('Beneath the Banyan',      '2025-08-22', 108, 'Hindi',   'U',  'A village elder recounts a forgotten legend.'),
('Velocity',                '2025-09-05', 120, 'English', 'UA', 'Street racers compete for a hidden fortune.');

-- ---------- movie_genres ----------
INSERT INTO movie_genres (movie_id, genre_id) VALUES
(1,1),(1,5),
(2,2),(2,9),
(3,3),(3,6),
(4,1),(4,5),(4,9),
(5,3),
(6,4),(6,9),
(7,5),(7,10),
(8,2),
(9,4),(9,1),
(10,2),(10,6),
(11,1),(11,5),
(12,4),(12,9),
(13,10),(13,2),
(14,2),(14,10),
(15,1),(15,4);

-- ---------- theatres ----------
INSERT INTO theatres (theatre_name, city, address, phone) VALUES
('Galaxy Cineplex',   'Hyderabad', 'Plot 12, Hitech City Road',       '9100011111'),
('Silver Screen Mall', 'Hyderabad', '4th Floor, Banjara Central',      '9100022222'),
('Urban Multiplex',    'Bengaluru', 'MG Road, Near Metro Station',     '9100033333'),
('Metro Cinemas',      'Mumbai',    'Andheri West, Link Road',         '9100044444'),
('Regal Picture House','Chennai',   'Anna Salai, T. Nagar',            '9100055555');

-- ---------- screens ----------
INSERT INTO screens (theatre_id, screen_name, total_seats, screen_type) VALUES
(1, 'Screen 1', 48, 'IMAX'),
(1, 'Screen 2', 48, 'Standard'),
(2, 'Screen 1', 48, '3D'),
(2, 'Screen 2', 48, 'Standard'),
(3, 'Screen 1', 48, '4DX'),
(3, 'Screen 2', 48, 'Standard'),
(4, 'Screen 1', 48, 'Standard'),
(4, 'Screen 2', 48, '3D'),
(5, 'Screen 1', 48, 'Standard'),
(5, 'Screen 2', 48, 'IMAX');

-- ---------- seats ----------
-- 6 rows (A-F) x 8 seats per screen; rows A-B Recliner, C-D Premium, E-F Standard
INSERT INTO seats (screen_id, seat_row, seat_number, seat_type)
SELECT s.screen_id, r.row_letter, n.seat_no,
       CASE WHEN r.row_letter IN ('A','B') THEN 'Recliner'
            WHEN r.row_letter IN ('C','D') THEN 'Premium'
            ELSE 'Standard' END
FROM screens s
CROSS JOIN (VALUES ('A'),('B'),('C'),('D'),('E'),('F')) AS r(row_letter)
CROSS JOIN generate_series(1,8) AS n(seat_no);

-- ---------- customers ----------
INSERT INTO customers (full_name, email, phone, password_hash, date_of_birth) VALUES
('Aarav Sharma',    'aarav.sharma@example.com',    '9000000001', 'hash_a1b2c3', '1998-04-12'),
('Diya Patel',      'diya.patel@example.com',      '9000000002', 'hash_b2c3d4', '1995-09-23'),
('Rohan Verma',     'rohan.verma@example.com',     '9000000003', 'hash_c3d4e5', '2000-01-05'),
('Ananya Iyer',     'ananya.iyer@example.com',     '9000000004', 'hash_d4e5f6', '1997-11-30'),
('Kabir Singh',     'kabir.singh@example.com',     '9000000005', 'hash_e5f6a7', '1993-06-17'),
('Meera Nair',      'meera.nair@example.com',      '9000000006', 'hash_f6a7b8', '1999-02-14'),
('Vihaan Reddy',    'vihaan.reddy@example.com',    '9000000007', 'hash_a7b8c9', '1996-08-09'),
('Ishita Kapoor',   'ishita.kapoor@example.com',   '9000000008', 'hash_b8c9d0', '2001-03-22'),
('Aditya Rao',      'aditya.rao@example.com',      '9000000009', 'hash_c9d0e1', '1994-12-01'),
('Sara Khan',       'sara.khan@example.com',       '9000000010', 'hash_d0e1f2', '1998-07-19'),
('Devansh Gupta',   'devansh.gupta@example.com',   '9000000011', 'hash_e1f2a3', '1992-10-27'),
('Nisha Menon',     'nisha.menon@example.com',     '9000000012', 'hash_f2a3b4', '2000-05-08'),
('Arjun Malhotra',  'arjun.malhotra@example.com',  '9000000013', 'hash_a3b4c5', '1997-01-16'),
('Priya Desai',     'priya.desai@example.com',     '9000000014', 'hash_b4c5d6', '1999-09-04'),
('Karan Chatterjee', 'karan.chatterjee@example.com','9000000015', 'hash_c5d6e7', '1995-03-29');

-- ---------- shows ----------
INSERT INTO shows (movie_id, screen_id, show_date, start_time, end_time, base_price, premium_multiplier, recliner_multiplier) VALUES
(1, 1,  '2026-07-15', '10:00', '12:30', 220.00, 1.50, 2.00),
(1, 3,  '2026-07-15', '18:00', '20:30', 250.00, 1.50, 2.00),
(2, 2,  '2026-07-15', '14:00', '16:15', 180.00, 1.40, 1.80),
(3, 4,  '2026-07-16', '11:00', '13:20', 170.00, 1.40, 1.80),
(4, 5,  '2026-07-16', '19:00', '21:00', 260.00, 1.60, 2.20),
(5, 6,  '2026-07-16', '17:00', '18:50', 150.00, 1.30, 1.70),
(6, 7,  '2026-07-17', '20:00', '22:05', 200.00, 1.50, 2.00),
(7, 9,  '2026-07-17', '15:00', '17:30', 230.00, 1.50, 2.00),
(8, 8,  '2026-07-17', '12:00', '13:55', 160.00, 1.30, 1.70),
(9, 10, '2026-07-18', '21:00', '23:10', 240.00, 1.50, 2.10),
(10,1,  '2026-07-18', '13:00', '14:40', 190.00, 1.40, 1.80),
(11,3,  '2026-07-18', '18:30', '20:50', 250.00, 1.50, 2.00),
(12,5,  '2026-07-19', '16:00', '17:55', 210.00, 1.50, 2.00),
(13,7,  '2026-07-19', '11:30', '13:35', 180.00, 1.40, 1.80),
(14,9,  '2026-07-19', '19:30', '21:20', 170.00, 1.30, 1.70),
(15,2,  '2026-07-20', '20:00', '22:00', 220.00, 1.50, 2.00),
(1, 2,  '2026-07-20', '10:30', '13:00', 210.00, 1.50, 2.00),
(4, 6,  '2026-07-20', '17:30', '19:30', 240.00, 1.50, 2.00);

-- ---------- bookings ----------
INSERT INTO bookings (customer_id, show_id, booking_time, booking_status, total_amount) VALUES
(1,  1, '2026-07-10 09:15', 'CONFIRMED', 440.00),
(2,  1, '2026-07-10 10:02', 'CONFIRMED', 330.00),
(3,  2, '2026-07-10 11:45', 'CONFIRMED', 500.00),
(4,  3, '2026-07-11 08:30', 'CONFIRMED', 360.00),
(5,  4, '2026-07-11 12:10', 'CONFIRMED', 255.00),
(6,  5, '2026-07-11 14:22', 'CANCELLED', 416.00),
(7,  6, '2026-07-12 09:05', 'CONFIRMED', 195.00),
(8,  7, '2026-07-12 16:40', 'CONFIRMED', 300.00),
(9,  8, '2026-07-12 18:12', 'CONFIRMED', 391.00),
(10, 9, '2026-07-13 10:55', 'CONFIRMED', 208.00),
(11,10, '2026-07-13 13:30', 'CONFIRMED', 480.00),
(12,11, '2026-07-13 17:15', 'CONFIRMED', 247.00),
(13,12, '2026-07-14 09:50', 'CONFIRMED', 500.00),
(14,13, '2026-07-14 11:20', 'CANCELLED', 315.00),
(15,14, '2026-07-14 15:45', 'CONFIRMED', 234.00),
(1, 15, '2026-07-14 19:00', 'CONFIRMED', 221.00),
(2, 16, '2026-07-15 08:40', 'CONFIRMED', 330.00),
(3, 17, '2026-07-15 10:10', 'CONFIRMED', 315.00),
(4, 18, '2026-07-15 12:25', 'CONFIRMED', 360.00),
(5, 1,  '2026-07-15 13:00', 'CONFIRMED', 220.00);

-- ---------- tickets ----------
-- seat_ids are dependent on generated seats; ranges below map to screen_id 1 (seats 1-48) and screen_id 3 (seats 97-144)
INSERT INTO tickets (booking_id, seat_id, show_id, price_paid) VALUES
(1, 1,  1, 220.00), (1, 2,  1, 220.00),
(2, 3,  1, 220.00), (2, 4,  1, 220.00), (2, 5,  1, 220.00),
(3, 97, 2, 250.00), (3, 98, 2, 250.00),
(4, 49, 3, 180.00), (4, 50, 3, 180.00),
(5, 193,4, 170.00), (5, 194,4, 170.00),
(6, 241,5, 208.00), (6, 242,5, 208.00),
(7, 289,6, 195.00),
(8, 337,7, 300.00),
(9, 433,8, 208.00), (9, 434,8, 208.00), (9, 435,8, 208.00),
(10, 481,9, 208.00),
(11, 1, 10,240.00), (11, 2, 10, 240.00),
(12, 97,11, 247.00),
(13, 241,12,250.00), (13,242,12,250.00),
(14, 337,13,315.00),
(15, 433,14,234.00),
(16, 49,15, 221.00),
(17, 3, 16, 165.00), (17, 4, 16, 165.00),
(18, 97,17, 315.00),
(19, 241,18,240.00), (19,242,18,120.00),
(20, 5, 1, 220.00);

-- ---------- payments ----------
INSERT INTO payments (booking_id, amount, payment_method, payment_status, transaction_ref, payment_time) VALUES
(1,  440.00, 'UPI',        'SUCCESS', 'TXN100001', '2026-07-10 09:16'),
(2,  330.00, 'CARD',       'SUCCESS', 'TXN100002', '2026-07-10 10:03'),
(3,  500.00, 'CARD',       'SUCCESS', 'TXN100003', '2026-07-10 11:46'),
(4,  360.00, 'UPI',        'SUCCESS', 'TXN100004', '2026-07-11 08:31'),
(5,  255.00, 'NETBANKING', 'SUCCESS', 'TXN100005', '2026-07-11 12:11'),
(6,  416.00, 'CARD',       'REFUNDED','TXN100006', '2026-07-11 14:23'),
(7,  195.00, 'UPI',        'SUCCESS', 'TXN100007', '2026-07-12 09:06'),
(8,  300.00, 'WALLET',     'SUCCESS', 'TXN100008', '2026-07-12 16:41'),
(9,  391.00, 'CARD',       'SUCCESS', 'TXN100009', '2026-07-12 18:13'),
(10, 208.00, 'UPI',        'SUCCESS', 'TXN100010', '2026-07-13 10:56'),
(11, 480.00, 'CARD',       'SUCCESS', 'TXN100011', '2026-07-13 13:31'),
(12, 247.00, 'UPI',        'SUCCESS', 'TXN100012', '2026-07-13 17:16'),
(13, 500.00, 'NETBANKING', 'SUCCESS', 'TXN100013', '2026-07-14 09:51'),
(14, 315.00, 'CARD',       'REFUNDED','TXN100014', '2026-07-14 11:21'),
(15, 234.00, 'WALLET',     'SUCCESS', 'TXN100015', '2026-07-14 15:46'),
(16, 221.00, 'UPI',        'SUCCESS', 'TXN100016', '2026-07-14 19:01'),
(17, 330.00, 'CARD',       'SUCCESS', 'TXN100017', '2026-07-15 08:41'),
(18, 315.00, 'UPI',        'SUCCESS', 'TXN100018', '2026-07-15 10:11'),
(19, 360.00, 'CARD',       'PENDING', 'TXN100019', '2026-07-15 12:26'),
(20, 220.00, 'UPI',        'SUCCESS', 'TXN100020', '2026-07-15 13:01');

-- ---------- reviews ----------
INSERT INTO reviews (customer_id, movie_id, rating, review_text, review_date) VALUES
(1,  1, 5, 'Stunning visuals and a gripping storyline.',       '2026-07-16 08:00'),
(2,  1, 4, 'Great action but slightly long.',                  '2026-07-16 09:15'),
(3,  2, 5, 'A masterclass in suspense.',                        '2026-07-16 10:30'),
(4,  3, 4, 'Beautiful music, heartfelt performances.',          '2026-07-17 11:00'),
(5,  4, 3, 'Interesting concept, uneven execution.',            '2026-07-17 12:45'),
(6,  5, 4, 'Genuinely funny from start to finish.',             '2026-07-17 14:20'),
(7,  6, 5, 'Kept me on the edge of my seat.',                   '2026-07-18 09:10'),
(8,  7, 4, 'Ambitious sci-fi with great world-building.',       '2026-07-18 10:40'),
(9,  8, 3, 'Solid drama, predictable ending.',                  '2026-07-18 13:05'),
(10, 9, 5, 'Tense and well-directed spy thriller.',             '2026-07-19 08:50'),
(11,10, 4, 'A nostalgic and touching story.',                   '2026-07-19 11:25'),
(12,11, 4, 'Great mech action sequences.',                      '2026-07-19 15:00'),
(13,12, 3, 'Decent hacker plot, weak pacing.',                  '2026-07-20 09:30'),
(14,13, 5, 'Visually rich and adventurous.',                    '2026-07-20 12:10'),
(15,14, 4, 'A charming folk tale well told.',                   '2026-07-20 16:40'),
(1,  2, 4, 'Rewatched it, still excellent.',                    '2026-07-21 09:00'),
(2,  4, 3, 'Fun but forgettable.',                               '2026-07-21 10:15'),
(3,  6, 5, 'One of the best thrillers this year.',              '2026-07-21 12:30');
