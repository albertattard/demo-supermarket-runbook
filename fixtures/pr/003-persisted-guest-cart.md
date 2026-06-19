## Summary

Adds the issue 3 persisted guest cart for Demo Supermarket.

Closes #3.

- Creates Flyway-managed cart and cart item tables with opaque public cart tokens.
- Adds server-side cart persistence for active guest carts, line items, and cart states.
- Adds catalog add-to-cart actions and public cart routes at `/cart/start` and `/cart/{cartToken}`.
- Supports incrementing existing lines, quantity updates from 1 to 99, line removal, and subtotal calculation.
- Renders server-side cart and unavailable-cart pages with HTMX available for cart interactions.

## Verification

- ./mvnw test
- ./mvnw verify
