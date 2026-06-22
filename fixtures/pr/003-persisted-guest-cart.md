## Summary

Adds the issue 3 persisted guest cart for Demo Supermarket.

Closes #3.

- Creates Flyway-managed cart and cart item tables with opaque public cart tokens.
- Adds server-side cart persistence for active guest carts, line items, and reserved cart states.
- Adds catalog add-to-cart actions and public guest-cart routes at `/cart/start`, `/cart/{cartToken}`, `/cart/{cartToken}/items`, and `/cart/{cartToken}/items/{productSlug}`.
- Adds a cart-scoped catalog route at `/cart/{cartToken}/products` so customers can continue shopping while preserving the active guest cart URL.
- Supports incrementing existing lines, quantity updates from 1 to 99, line removal, repeated remove handling, and subtotal calculation from current product prices.
- Uses stable product slugs for catalog and cart mutations instead of product database IDs.
- Renders server-side cart, cart-scoped catalog, and unavailable-cart pages with HTMX progressive enhancement for cart interactions.

## Verification

- `./mvnw test`
- `./mvnw verify`