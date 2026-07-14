DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS shows CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS seats CASCADE;
DROP TABLE IF EXISTS screens CASCADE;
DROP TABLE IF EXISTS theatres CASCADE;
DROP TABLE IF EXISTS movie_genres CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS genres CASCADE;

-- ---------- 1. genres ----------
CREATE TABLE genres (
    genre_id    SERIAL PRIMARY KEY,
    genre_name  VARCHAR(50) NOT NULL UNIQUE
);

-- ---------- 2. movies ----------
CREATE TABLE movies (
    movie_id          SERIAL PRIMARY KEY,
    title             VARCHAR(150) NOT NULL,
    release_date      DATE NOT NULL,
    duration_minutes  SMALLINT NOT NULL CHECK (duration_minutes > 0),
    language          VARCHAR(30) NOT NULL,
    certification     VARCHAR(10) NOT NULL CHECK (certification IN ('U','UA','A','S')),
    synopsis          TEXT,
    UNIQUE (title, release_date)
);

-- ---------- 3. movie_genres (M:N junction) ----------
CREATE TABLE movie_genres (
    movie_id  INT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
    genre_id  INT NOT NULL REFERENCES genres(genre_id) ON DELETE RESTRICT,
    PRIMARY KEY (movie_id, genre_id)
);

-- ---------- 4. theatres ----------
CREATE TABLE theatres (
    theatre_id    SERIAL PRIMARY KEY,
    theatre_name  VARCHAR(100) NOT NULL,
    city          VARCHAR(50) NOT NULL,
    address       VARCHAR(200) NOT NULL,
    phone         VARCHAR(15) NOT NULL UNIQUE,
    UNIQUE (theatre_name, city)
);

-- ---------- 5. screens (1:N with theatres) ----------
CREATE TABLE screens (
    screen_id    SERIAL PRIMARY KEY,
    theatre_id   INT NOT NULL REFERENCES theatres(theatre_id) ON DELETE CASCADE,
    screen_name  VARCHAR(20) NOT NULL,
    total_seats  SMALLINT NOT NULL CHECK (total_seats > 0),
    screen_type  VARCHAR(15) NOT NULL DEFAULT 'Standard'
                 CHECK (screen_type IN ('Standard','IMAX','3D','4DX')),
    UNIQUE (theatre_id, screen_name)
);

-- ---------- 6. seats (1:N with screens) ----------
CREATE TABLE seats (
    seat_id      SERIAL PRIMARY KEY,
    screen_id    INT NOT NULL REFERENCES screens(screen_id) ON DELETE CASCADE,
    seat_row     CHAR(1) NOT NULL,
    seat_number  SMALLINT NOT NULL CHECK (seat_number > 0),
    seat_type    VARCHAR(10) NOT NULL DEFAULT 'Standard'
                 CHECK (seat_type IN ('Standard','Premium','Recliner')),
    UNIQUE (screen_id, seat_row, seat_number)
);

-- ---------- 7. customers ----------
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    date_of_birth   DATE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------- 8. shows (1:N with movies and screens) ----------
CREATE TABLE shows (
    show_id              SERIAL PRIMARY KEY,
    movie_id             INT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
    screen_id            INT NOT NULL REFERENCES screens(screen_id) ON DELETE CASCADE,
    show_date            DATE NOT NULL,
    start_time           TIME NOT NULL,
    end_time             TIME NOT NULL,
    base_price           NUMERIC(8,2) NOT NULL CHECK (base_price > 0),
    premium_multiplier   NUMERIC(3,2) NOT NULL DEFAULT 1.50 CHECK (premium_multiplier >= 1),
    recliner_multiplier  NUMERIC(3,2) NOT NULL DEFAULT 2.00 CHECK (recliner_multiplier >= 1),
    UNIQUE (screen_id, show_date, start_time),
    CHECK (end_time > start_time)
);

-- ---------- 9. bookings (1:N with customers and shows) ----------
CREATE TABLE bookings (
    booking_id      SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    show_id         INT NOT NULL REFERENCES shows(show_id) ON DELETE CASCADE,
    booking_time    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    booking_status  VARCHAR(10) NOT NULL DEFAULT 'CONFIRMED'
                    CHECK (booking_status IN ('CONFIRMED','CANCELLED')),
    total_amount    NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

-- ---------- 10. tickets (seat-level detail; prevents double-selling a seat for a show) ----------
CREATE TABLE tickets (
    ticket_id    SERIAL PRIMARY KEY,
    booking_id   INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    seat_id      INT NOT NULL REFERENCES seats(seat_id) ON DELETE RESTRICT,
    show_id      INT NOT NULL REFERENCES shows(show_id) ON DELETE CASCADE,
    price_paid   NUMERIC(8,2) NOT NULL CHECK (price_paid > 0),
    UNIQUE (show_id, seat_id)   -- composite constraint: one seat sold once per show
);

-- ---------- 11. payments (1:1 with bookings) ----------
CREATE TABLE payments (
    payment_id       SERIAL PRIMARY KEY,
    booking_id       INT NOT NULL UNIQUE REFERENCES bookings(booking_id) ON DELETE CASCADE,
    amount           NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method   VARCHAR(15) NOT NULL CHECK (payment_method IN ('CARD','UPI','NETBANKING','WALLET')),
    payment_status   VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                     CHECK (payment_status IN ('PENDING','SUCCESS','FAILED','REFUNDED')),
    transaction_ref  VARCHAR(50) NOT NULL UNIQUE,
    payment_time     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------- 12. reviews (M:N junction with attributes, customers <-> movies) ----------
CREATE TABLE reviews (
    review_id     SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    movie_id      INT NOT NULL REFERENCES movies(movie_id) ON DELETE CASCADE,
    rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text   TEXT,
    review_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (customer_id, movie_id)  -- one review per customer per movie
);
