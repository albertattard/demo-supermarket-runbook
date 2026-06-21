## Goal

Implement persisted guest carts using opaque URL tokens.

Customers should be able to add products to a shopping bag and return to it
through a private-ish cart URL.

## Scope

- Add cart and cart item database tables.
- Use numeric internal database IDs only internally.
- Generate an opaque public cart token for URLs.
- Add cart states:
  - `ACTIVE`
  - `CHECKED_OUT`
  - `ABANDONED`
- Add routes:
  - `/cart/start`
  - `/cart/{cartToken}`
- Add "add to cart" actions from the product catalog.
- If a product is already in the cart, increment its quantity.
- Support integer quantities only.
- Enforce minimum quantity `1`.
- Enforce maximum quantity `99` per cart line.
- Support updating cart line quantities.
- Support removing cart lines.
- Use HTMX where practical for cart quantity updates and cart summary refreshes.
- Show current line totals and cart subtotal.

## Out of Scope

- Checkout
- Order creation
- Session-backed carts
- Customer accounts
- Cart cleanup jobs
- Stock validation

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw verify` succeeds.
- Starting a cart creates an `ACTIVE` cart with an opaque token.
- Cart URLs use `/cart/{cartToken}` and do not expose database IDs.
- Adding the same product twice increments the existing cart line.
- Quantity updates reject values below `1` and above `99`.
- Removing a cart line works.
- Cart subtotal is calculated from current product prices.
- Opening an unknown cart token shows an appropriate not-found or unavailable
  response.
