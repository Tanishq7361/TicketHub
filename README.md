# 🎬 CineBook — Movie Ticket Booking System (PostgreSQL Database Design)

A production-inspired relational database for a multi-theatre movie ticket booking platform, designed as a DBMS course project. Focuses purely on schema design, normalization, and SQL — no application layer.

## Overview

CineBook models the full data lifecycle of a ticketing platform: theatres and screens, seat inventory, show scheduling, customer bookings, seat-level ticketing, payments, and reviews. The schema is normalized to **BCNF** and enforces referential integrity through primary/foreign keys, composite uniqueness constraints, and check constraints — with zero business logic pushed into the database (no procedures, triggers, or views).

## Tech Stack

- **Database:** PostgreSQL 14+
- **Scope:** DDL, DML (sample data), and analytical SQL only

## Schema (12 Tables)

| Table | Purpose |
|---|---|
| `genres` | Master list of movie genres |
| `movies` | Movie metadata |
| `movie_genres` | M:N junction — movies ↔ genres |
| `theatres` | Theatre branches |
| `screens` | Auditoriums within a theatre |
| `seats` | Seat layout per screen (Standard / Premium / Recliner) |
| `customers` | Registered users |
| `shows` | Movie-to-screen scheduling with pricing |
| `bookings` | Customer reservation header |
| `tickets` | Seat-level line items per booking |
| `payments` | 1:1 transaction record per booking |
| `reviews` | M:N junction with attributes — customers ↔ movies |

**Relationship mix:** 1:1 (`bookings`↔`payments`), 1:N (`theatres`→`screens`→`seats`, `movies`→`shows`, `customers`→`bookings`→`tickets`), M:N (`movie_genres`, `reviews`).

## Key Design Decisions

- **Every table verified to BCNF** — see [`er_diagram_and_normalization.md`](./er_diagram_and_normalization.md) for the full determinant-by-determinant proof.
- **Composite uniqueness for data integrity**: `UNIQUE(show_id, seat_id)` on `tickets` makes double-selling a seat for the same show structurally impossible; `UNIQUE(customer_id, movie_id)` on `reviews` caps one review per customer per movie; `UNIQUE(screen_id, show_date, start_time)` on `shows` prevents scheduling conflicts on a screen.
- **Historical price integrity**: `tickets.price_paid` and `bookings.total_amount` are stored at transaction time rather than derived from `shows.base_price`, so later price changes never corrupt past records.
- **Strict CHECK constraints** enforce domain rules at the database layer (rating 1–5, seat/screen/certification enums, `end_time > start_time`, positive amounts).

## Repository Structure

```
.
├── ddl.sql                            # Schema: tables, keys, constraints
├── insert_data.sql                    # Realistic sample data (10-20+ rows/table)
├── queries.sql                        # 20 queries: 10 easy / 5 medium / 5 hard
├── schema.dbml                        # dbdiagram.io-ready ER schema
└── er_diagram_and_normalization.md    # ER diagram (Mermaid) + BCNF proof + design rationale
```

## Setup

```bash
psql -U postgres -d cinebook -f ddl.sql
psql -U postgres -d cinebook -f insert_data.sql
psql -U postgres -d cinebook -f queries.sql
```

## Query Highlights

- Correlated subqueries identifying above-average-activity customers
- `EXISTS` / `NOT EXISTS` for scheduled-but-unreviewed movies and never-booked customers
- Multi-table joins reconstructing a full booking → payment → theatre trail


## ER Diagram

See [`er_diagram_and_normalization.md`](./er_diagram_and_normalization.md) for the Mermaid diagram, or import [`schema.dbml`](./schema.dbml) directly into [dbdiagram.io](https://dbdiagram.io).

## Author

Tanishq