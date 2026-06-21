## Summary

Adds the issue 2 customer-facing product catalog for Demo Supermarket.

Closes #2.

- Creates Flyway-managed category and product tables with seeded demo data.
- Adds schema constraints for core catalog invariants.
- Adds catalog repository, service, and controller code for active products in active categories.
- Renders responsive server-side catalog pages at `/` and `/products`.
- Supports category filtering and escaped, case-insensitive text search by product name or description.
- Displays euro prices and local placeholder images for products without image paths.
- Adds controller, service, security, and Playwright coverage for the catalog flow.

## Verification

- `./mvnw test`
- `./mvnw verify`
