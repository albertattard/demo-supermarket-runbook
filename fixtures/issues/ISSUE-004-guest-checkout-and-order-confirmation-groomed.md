## Goal

Implement guest checkout for pickup and delivery and create immutable order snapshots.

Customers should be able to convert an active cart into an order and receive a human-friendly order code.

## Initial Delivery Area

For this workshop demo, the initially approved delivery postal-code list is:

- `10115`
- `10116`

Seed exactly this list through Flyway. Delivery is available only when the submitted postal code is one of `10115` or `10116`. A syntactically valid five-digit postal code that is not in this list, such as `80331`, is unsupported.

## Scope

- Add order and order item database tables.
- Each order must reference its source cart using a non-null `cart_id` foreign key. Enforce a unique constraint on `orders.cart_id` so a cart can have at most one order.
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
- Add a `GET /cart/{cartToken}/checkout` route that renders the checkout form for an active cart.
- Add a `POST /cart/{cartToken}/checkout` route that validates the submitted form and creates the order.
- `GET /cart/{cartToken}/checkout` returns `200 OK` and an HTML form for an active, non-empty cart. A non-active or unknown cart token uses the existing customer-facing `404 Not Found` cart response.
- On a successful `POST /cart/{cartToken}/checkout`, return `303 See Other` with `Location: /orders/{canonicalOrderCode}/confirmation`. A repeated successful submission for an already checked-out cart returns the same `303 See Other` location.
- On a validation failure, return `422 Unprocessable Content` and redisplay the checkout form. Preserve the submitted fulfillment type and all submitted contact and delivery field values. Render a field-level error next to each invalid control; each message must explain how to correct the problem, distinguish malformed from unsupported postal codes, and be programmatically associated with its control. Do not rely on a generic error alone.
- If submission discovers an empty cart or an archived cart product, return `422 Unprocessable Content`, preserve the submitted fields, and render a clear form-level error explaining the problem and what the customer should do next.
- Add confirmation route `/orders/{orderCode}/confirmation`. For this application, the high-entropy order code is the sole access mechanism: anyone who knows it may view that order's confirmation page and the customer data it contains.
- Collect customer fields for both pickup and delivery:
  - full name
  - email
  - phone number
- Collect delivery-only fields:
  - street
  - house number
  - postal code
  - city
- For this issue, a full delivery address consists of exactly those four fields; do not collect or store a country field.
- Validate delivery postal code against seeded allowed postal codes.
- Require non-blank, trimmed full name, email, and phone number for both fulfillment types. After trimming, validate the email with Jakarta Bean Validation's `@Email` constraint; do not introduce a custom email regular expression. For example, `albert@example.com` is valid and `albert.example.com` is invalid.
- For delivery, also require non-blank, trimmed street, house number, postal code, and city. Trim leading and trailing whitespace from the postal code before validation; a value such as ` 10115 ` is therefore accepted. After trimming, postal codes must be exactly five digits before checking whether they are allowed.
- Calculate delivery fee:
  - pickup: `0.00`
  - delivery under `50.00` goods subtotal: `4.99`
  - delivery with goods subtotal `50.00` or more: `0.00`
- Use goods subtotal before delivery fee for the threshold.
- Generate a human-friendly public order code.
- Generate a unique, case-insensitive public order code using the fixed uppercase alphabet `ABCDEFGHJKMNPQRSTVWXYZ` (excluding `I`, `L`, `O`, and `U`). The canonical stored and URL form is exactly 18 characters with no separators; it provides more than 80 bits of cryptographically secure randomness. Present the code to customers in three six-character groups separated by hyphens (for example, `ABCDEF-GHJKMN-PQRSTV`). The code must not encode database IDs, cart tokens, customer data, or other business data. Retry generation on a uniqueness collision.
- Snapshot product name, unit label, unit price, quantity, and line total into order items.
- Snapshot the submitted customer name, email, phone number, fulfillment type, and, for delivery, the full delivery address on the order. Pickup orders must not retain delivery-address values.
- Store goods subtotal, delivery fee, and grand total on the order. Use the current persisted product prices when checkout is submitted; calculate and persist all monetary values using `BigDecimal`, rounded to two decimal places.
- Mark the cart as `CHECKED_OUT` after successful checkout.
- Reject checkout if the cart is empty.
- Reject checkout if a cart product is archived before checkout.
- Treat order creation and the cart state transition as one transaction. Re-check that the cart is active, non-empty, and contains no archived products inside that transaction.
- Use the configured database's default transaction isolation; this demo must not set a custom isolation level. Concurrency and rollback tests run against the configured H2 database and verify the stated order and cart invariants rather than database-specific locking behavior.
- Provide a test-only failure-injection seam that throws an unchecked exception after the order and its items have been persisted and the cart has been marked `CHECKED_OUT`, but before the transaction commits. It must be disabled outside automated tests.
- A successful checkout submission for a cart that has already been checked out must not create a second order; redirect to the confirmation page for the existing order instead.
- When checkout finds a `CHECKED_OUT` cart, it must load the order by its unique `cart_id`. If no linked order exists, treat this as corrupted data: fail with the application's generic internal-error response and never create another order.
- A checked-out cart cannot be viewed or changed through cart routes; preserve the existing cart-not-found behavior for non-active cart tokens.
- Confirmation pages are public because guests have no account; an unknown order code returns `404 Not Found` using a customer-facing page.
- The confirmation page displays `Pay when you collect your order.` for pickup orders and `Pay when your order is delivered.` for delivery orders.
- This issue creates orders only in status `PLACED`. The other listed statuses are reserved for a later order-operations issue, which will define authorized roles, allowed transitions, and operational audit requirements.

## Out of Scope

- Payment processing
- Customer accounts
- Customer-side cancellation
- Pickup or delivery time slots
- Email/SMS notifications
- Editing orders after checkout
- Order lifecycle transitions after `PLACED`
- Rate limiting, proxy-aware client-IP handling, and other production anti-enumeration controls

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw verify` succeeds.
- Add or update an end-to-end or full-stack web test that completes both a pickup checkout and a delivery checkout using postal code `10115` from an active cart.
- Pickup checkout creates an order with status `PLACED`.
- Delivery checkout creates an order with status `PLACED` when the postal code is `10115`.
- Delivery checkout accepts ` 10115 ` after trimming the surrounding whitespace.
- Delivery checkout rejects a syntactically valid but unsupported postal code such as `80331`.
- Checkout form validation redisplays the form with clear field errors for missing contact data, invalid email, incomplete delivery address, malformed postal code, and unsupported postal code.
- Checkout accepts `albert@example.com` and rejects `albert.example.com` as an invalid email address.
- A valid checkout submission returns `303 See Other` to the canonical confirmation URL. Validation failure returns `422 Unprocessable Content`, preserves submitted field values, and renders the specified inline field errors.
- Empty-cart and archived-product checkout submissions return `422 Unprocessable Content`, preserve submitted fields, and render their specified form-level error messages.
- Delivery fee is `4.99` below `50.00` goods subtotal.
- Delivery fee is `0.00` at or above `50.00` goods subtotal.
- Confirmation page shows order code, fulfillment type, customer name, the delivery address when applicable, item snapshots, goods subtotal, delivery fee, grand total, and the pay-on-pickup/delivery message.
- Order codes use exactly 18 characters from `ABCDEFGHJKMNPQRSTVWXYZ`; their customer-facing presentation is three six-character hyphen-separated groups, while confirmation URLs use the canonical ungrouped form.
- An automated test forces an order-code uniqueness collision and proves that checkout retries generation and persists a different unique code.
- Automated tests inject the specified pre-commit checkout failure and verify that the transaction rolls back both order creation and the cart state transition: no order or order items remain and the cart stays `ACTIVE`.
- Checked-out carts cannot be modified.
- Repeated checkout submission for the same cart produces no additional order and leads to the original confirmation page.
- Automated tests submit checkout concurrently for the same cart and prove that exactly one order is created and both submissions resolve to that order's confirmation page.
- Concurrency and rollback tests run against the configured H2 database without a custom transaction-isolation setting.
- Automated tests prove the unique cart-to-order relationship and that a checked-out cart without a linked order fails without creating a replacement order.
- Unknown order codes return `404 Not Found` with a customer-facing response.
- Existing order item snapshots do not change when product details change later.
- Confirmation pages display `Pay when you collect your order.` for pickup and `Pay when your order is delivered.` for delivery.
