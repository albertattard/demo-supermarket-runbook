## Summary

Adds the issue 2 customer-facing product catalog for Demo Supermarket.

Closes #2.

- Creates Flyway-managed category and product tables with seeded demo data.
- Adds catalog repository, service, and controller code for active products.
- Renders responsive server-side catalog pages at `/` and `/products`.
- Supports category filtering and text search by product name or description.

## Verification

- ./mvnw test
- ./mvnw verify
