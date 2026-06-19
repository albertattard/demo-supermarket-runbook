## Goal

Create the initial customer-facing product catalog backed by Flyway-seeded demo
data.

This issue introduces the core catalog domain without inventory stock tracking.

## Scope

- Add category and product database tables.
- Seed 4-6 categories and 12-20 products through Flyway.
- Products must include:
  - name
  - description
  - category
  - unit label
  - unit price
  - active/archived flag
  - optional image path
- Implement catalog repository/service/controller code.
- Render a server-side catalog page at `/` and `/products`.
- Show only active products to customers.
- Support category filtering.
- Support text search by product name and description.
- Display name, description, category, unit label, unit price, and optional
  image/placeholder.
- Add basic responsive CSS for the catalog.

## Out of Scope

- Product detail pages
- Shopping cart behavior
- Inventory management screens
- Product image upload
- Stock tracking
- Public JSON API

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw verify` succeeds.
- Flyway creates and seeds categories/products.
- `/` shows the product catalog.
- `/products` shows the product catalog.
- Category filtering works.
- Text search works.
- Archived products are not shown in the customer catalog.
- Prices are displayed in euros.
- Product prices are represented with `BigDecimal` in Java and decimal columns
  in the database.
