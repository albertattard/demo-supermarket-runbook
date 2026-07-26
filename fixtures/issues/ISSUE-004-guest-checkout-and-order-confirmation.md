## Goal

Implement guest checkout for pickup and delivery and create immutable order snapshots.

Customers should be able to convert an active cart into an order and receive a human-friendly order code.

## Scope

- Add order and order item database tables.
- Add fulfillment types:
  - `PICKUP`
  - `DELIVERY`
- Add order statuses:
  - `PLACED`
  - `PREPARING`
  - `READY_FOR_PICKUP`
  - `OUT_FOR_DELIVERY`
  - `COMPLETED`
  - `CANCELLED`
- Add seeded allowed German delivery postal codes through Flyway.
- Seed the product-approved initial delivery postal-code list through Flyway and document that exact list in this issue before implementation.
- Add a `GET /cart/{cartToken}/checkout` route that renders the checkout form for an active cart.
- Add a `POST /cart/{cartToken}/checkout` route that validates the submitted form and creates the order.
- Add confirmation route `/orders/{orderCode}/confirmation`.
- Collect customer fields for both pickup and delivery:
  - full name
  - email
  - phone number
- Collect delivery-only fields:
  - street
  - house number
  - postal code
  - city
- Validate delivery postal code against seeded allowed postal codes.
- Require non-blank, trimmed full name, email, and phone number for both fulfillment types. Require a syntactically valid email address.
- For delivery, also require non-blank, trimmed street, house number, postal code, and city. Postal codes must be exactly five digits before checking whether they are allowed.
- Calculate delivery fee:
  - pickup: `0.00`
  - delivery under `50.00` goods subtotal: `4.99`
  - delivery with goods subtotal `50.00` or more: `0.00`
- Use goods subtotal before delivery fee for the threshold.
- Generate a human-friendly public order code.
- Generate a unique, case-insensitive public order code using a fixed, unambiguous uppercase alphabet that excludes `I`, `L`, `O`, and `U`. The code must contain at least 80 bits of cryptographically secure randomness and must not encode database IDs, cart tokens, customer data, or other business data. Retry generation on a uniqueness collision.
- Snapshot product name, unit label, unit price, quantity, and line total into order items.
- Snapshot the submitted customer name, email, phone number, fulfillment type, and, for delivery, the full delivery address on the order. Pickup orders must not retain delivery-address values.
- Store goods subtotal, delivery fee, and grand total on the order. Use the current persisted product prices when checkout is submitted; calculate and persist all monetary values using `BigDecimal`, rounded to two decimal places.
- Mark the cart as `CHECKED_OUT` after successful checkout.
- Reject checkout if the cart is empty.
- Reject checkout if a cart product is archived before checkout.
- Treat order creation and the cart state transition as one transaction. Re-check that the cart is active, non-empty, and contains no archived products inside that transaction.
- A successful checkout submission for a cart that has already been checked out must not create a second order; redirect to the confirmation page for the existing order instead.
- A checked-out cart cannot be viewed or changed through cart routes; preserve the existing cart-not-found behavior for non-active cart tokens.
- Confirmation pages are public because guests have no account; an unknown order code returns `404 Not Found` using a customer-facing page.

## Out of Scope

- Payment processing
- Customer accounts
- Customer-side cancellation
- Pickup or delivery time slots
- Email/SMS notifications
- Editing orders after checkout

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw verify` succeeds.
- Add or update an end-to-end or full-stack web test that completes both a pickup checkout and an allowed-postal-code delivery checkout from an active cart.
- Pickup checkout creates an order with status `PLACED`.
- Delivery checkout creates an order with status `PLACED` only for allowed postal codes.
- Checkout form validation redisplays the form with clear field errors for missing contact data, invalid email, incomplete delivery address, malformed postal code, and unsupported postal code.
- Delivery fee is `4.99` below `50.00` goods subtotal.
- Delivery fee is `0.00` at or above `50.00` goods subtotal.
- Confirmation page shows order code, fulfillment type, customer name, the delivery address when applicable, item snapshots, goods subtotal, delivery fee, grand total, and the pay-on-pickup/delivery message.
- Checked-out carts cannot be modified.
- Repeated checkout submission for the same cart produces no additional order and leads to the original confirmation page.
- Unknown order codes return `404 Not Found` with a customer-facing response.
- Existing order item snapshots do not change when product details change later.
