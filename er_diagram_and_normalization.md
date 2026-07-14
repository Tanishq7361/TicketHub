# Movie Ticket Booking System — ER Diagram & Normalization

## ER Diagram (Mermaid — paste into mermaid.live, GitHub, or draw.io's Mermaid import)

```mermaid
erDiagram
    GENRES ||--o{ MOVIE_GENRES : "categorizes"
    MOVIES ||--o{ MOVIE_GENRES : "belongs to"
    MOVIES ||--o{ SHOWS : "screened as"
    MOVIES ||--o{ REVIEWS : "receives"
    THEATRES ||--o{ SCREENS : "contains"
    SCREENS ||--o{ SEATS : "has"
    SCREENS ||--o{ SHOWS : "hosts"
    CUSTOMERS ||--o{ BOOKINGS : "makes"
    CUSTOMERS ||--o{ REVIEWS : "writes"
    SHOWS ||--o{ BOOKINGS : "booked for"
    SHOWS ||--o{ TICKETS : "sold for"
    SEATS ||--o{ TICKETS : "assigned to"
    BOOKINGS ||--o{ TICKETS : "contains"
    BOOKINGS ||--|| PAYMENTS : "settled by"

    GENRES {
        int genre_id PK
        varchar genre_name UK
    }
    MOVIES {
        int movie_id PK
        varchar title
        date release_date
        smallint duration_minutes
        varchar language
        varchar certification
        text synopsis
    }
    MOVIE_GENRES {
        int movie_id PK,FK
        int genre_id PK,FK
    }
    THEATRES {
        int theatre_id PK
        varchar theatre_name
        varchar city
        varchar address
        varchar phone UK
    }
    SCREENS {
        int screen_id PK
        int theatre_id FK
        varchar screen_name
        smallint total_seats
        varchar screen_type
    }
    SEATS {
        int seat_id PK
        int screen_id FK
        char seat_row
        smallint seat_number
        varchar seat_type
    }
    CUSTOMERS {
        int customer_id PK
        varchar full_name
        varchar email UK
        varchar phone UK
        varchar password_hash
        date date_of_birth
        timestamp created_at
    }
    SHOWS {
        int show_id PK
        int movie_id FK
        int screen_id FK
        date show_date
        time start_time
        time end_time
        numeric base_price
        numeric premium_multiplier
        numeric recliner_multiplier
    }
    BOOKINGS {
        int booking_id PK
        int customer_id FK
        int show_id FK
        timestamp booking_time
        varchar booking_status
        numeric total_amount
    }
    TICKETS {
        int ticket_id PK
        int booking_id FK
        int seat_id FK
        int show_id FK
        numeric price_paid
    }
    PAYMENTS {
        int payment_id PK
        int booking_id FK,UK
        numeric amount
        varchar payment_method
        varchar payment_status
        varchar transaction_ref UK
        timestamp payment_time
    }
    REVIEWS {
        int review_id PK
        int customer_id FK
        int movie_id FK
        smallint rating
        text review_text
        timestamp review_date
    }
```

## Relationship Cardinality Summary

| Relationship | Type | Enforced by |
|---|---|---|
| theatres → screens | 1:N | `screens.theatre_id` FK |
| screens → seats | 1:N | `seats.screen_id` FK |
| screens → shows | 1:N | `shows.screen_id` FK |
| movies → shows | 1:N | `shows.movie_id` FK |
| movies ↔ genres | M:N | `movie_genres` junction table |
| customers → bookings | 1:N | `bookings.customer_id` FK |
| shows → bookings | 1:N | `bookings.show_id` FK |
| bookings → tickets | 1:N | `tickets.booking_id` FK |
| seats → tickets | 1:N (unique per show) | `tickets.seat_id` FK + `UNIQUE(show_id, seat_id)` |
| bookings → payments | **1:1** | `payments.booking_id` FK + `UNIQUE` |
| customers ↔ movies | M:N (with attributes) | `reviews` junction table + `UNIQUE(customer_id, movie_id)` |

## Normalization Walkthrough

**1NF** — Every table stores atomic, single-valued attributes only (e.g., a customer's phone is one value, not a list; no repeating groups). Multi-valued associations — a movie having several genres, a customer reviewing several movies — are factored out into `movie_genres` and `reviews` rather than stored as comma-separated columns.

**2NF** — Every non-key attribute depends on the *whole* primary key, not part of it. This matters only for composite-key tables:
- `movie_genres (movie_id, genre_id)` has no non-key attributes at all, so partial dependency is impossible.
- All other tables use a single-column surrogate key (`SERIAL`), so 2NF is automatically satisfied.

**3NF** — No non-key attribute depends transitively on another non-key attribute.
- `shows` stores `base_price` directly against the show rather than deriving it through `screens` or `movies`, avoiding a transitive path.
- `tickets.price_paid` is stored as a historical fact (the price actually charged), not derived at query time from `shows.base_price`, since prices can change after a ticket is sold — this is intentional denormalization for auditability, not a normalization violation, because `price_paid` depends only on `ticket_id`.
- `bookings.total_amount` similarly records the amount agreed at booking time and depends only on `booking_id`.

**BCNF** — For every non-trivial functional dependency `X → Y`, `X` must be a superkey.
- `genres`, `movies`, `theatres`, `customers`: single candidate key (surrogate PK) plus one or two UNIQUE attributes (`genre_name`, `title+release_date`, `phone`, `email+phone`) that each independently determine the whole row — no attribute determines another non-key attribute, so BCNF holds trivially.
- `screens`: `screen_id` is the PK; `(theatre_id, screen_name)` is a candidate key (UNIQUE constraint) that also determines every other attribute. No other determinant exists → BCNF.
- `seats`: `seat_id` is the PK; `(screen_id, seat_row, seat_number)` is a candidate key. All FDs originate from a superkey → BCNF.
- `shows`: `show_id` is the PK; `(screen_id, show_date, start_time)` is a candidate key (a screen can't run two shows at once). All other attributes depend on this key → BCNF.
- `bookings`, `tickets`, `payments`, `reviews`: PK is the surrogate key; the additional UNIQUE constraints (`(show_id, seat_id)` on tickets, `booking_id` on payments, `(customer_id, movie_id)` on reviews) are themselves candidate keys, and no non-candidate-key attribute determines another attribute → BCNF.
- `movie_genres`: the composite PK `(movie_id, genre_id)` is the only key and there are no other attributes, so BCNF holds vacuously.

No table exhibits a determinant that is not a candidate key, so **every table in this schema is in BCNF**.

## Design Rationale (for viva / interview discussion)

- **Separation of `seats` from `tickets`**: `seats` is static inventory (the physical layout of a screen); `tickets` is a transactional fact (a seat sold for one specific show). Merging them would force re-inserting seat rows per show and violate 3NF by duplicating row/number/type data.
- **`tickets` vs `bookings`**: a `booking` is the customer-facing transaction (one row per checkout); `tickets` breaks it down per seat, enabling group bookings and clean seat-level uniqueness (`UNIQUE(show_id, seat_id)`) without polluting `bookings` with a variable number of seat columns.
- **`payments` as a separate 1:1 table** (rather than columns on `bookings`) isolates transactional/financial state (status, gateway reference) from booking state, mirroring how real payment gateways reconcile asynchronously.
- **`movie_genres` and `reviews` as junction tables** correctly model the two independent M:N relationships in the domain without redundant repetition of movie or customer data.
