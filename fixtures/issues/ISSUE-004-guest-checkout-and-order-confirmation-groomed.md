## Goal

Implement the first usable guest checkout: customers with an active cart can place a pickup order and view its confirmation.

## Resolved product decisions

- The canonical stored and URL order code is exactly 18 uppercase characters from `ABCDEFGHJKMNPQRSTVWXYZ`; it contains more than 80 bits of cryptographically secure randomness and encodes no business data.
- Display the code in three groups of six characters separated by hyphens.
- The database enforces case-insensitive uniqueness for the canonical code. A collision is retried; the forced-collision and concurrency proofs belong to story 6.
- Confirmation is public: the high-entropy code is the sole access mechanism. Unknown codes return the existing customer-facing `404 Not Found` page.

## Scope

- Add order and order-item tables. Each order has a non-null, unique `cart_id` foreign key.
- Add the `PICKUP` fulfillment type and `PLACED` order status.
- Add a checkout form at `GET /cart/{cartToken}/checkout` for active, non-empty carts; unknown or non-active carts retain the existing customer-facing `404` response.
- Add `POST /cart/{cartToken}/checkout` for pickup orders.
- Require trimmed, non-blank full name, email, and phone number. Validate email with Jakarta Bean Validation's `@Email`; `albert@example.com` is valid and `albert.example.com` is invalid.
- Persist immutable snapshots of product name, unit label, unit price, quantity, line total, customer fields, fulfillment type, goods subtotal, delivery fee, and grand total. Use current persisted prices and two-decimal `BigDecimal` monetary values.
- Pickup delivery fee is `0.00`.
- Re-check active, non-empty, non-archived cart state while creating the order. Order creation and marking the cart `CHECKED_OUT` are one transaction.
- Repeated submission for a checked-out cart loads the order by its unique `cart_id` and returns its original confirmation URL; do not create another order.
- Checked-out carts retain the existing cart-not-found behaviour on cart routes.
- Add public `GET /orders/{orderCode}/confirmation` displaying the grouped order code, pickup fulfillment type, customer name, item snapshots, goods subtotal, delivery fee, grand total, and `Pay when you collect your order.`

## Out of Scope

- Delivery checkout (story 5).
- Forced collision, rollback injection, concurrent checkout, and corrupted checked-out-cart tests (story 6).
- Payments, accounts, cancellation, time slots, notifications, editing orders, and transitions beyond `PLACED`.

## Acceptance Criteria

- `./mvnw test` and `./mvnw verify` succeed.
- A full-stack or end-to-end test completes pickup checkout from an active cart.
- Pickup checkout creates one `PLACED` order with immutable snapshots and a `0.00` delivery fee.
- Validation failures return `422 Unprocessable Content`, preserve values, and provide associated inline errors for missing contact data and invalid email.
- Empty-cart and archived-product checkout failures return `422 Unprocessable Content`, preserve values, and show a clear form-level error.
- Valid checkout returns `303 See Other` to the 18-character canonical confirmation URL; the confirmation page shows the grouped code and all specified pickup information.
- Repeated checkout creates no additional order and redirects to the original confirmation page.
- Checked-out carts cannot be modified.
- Unknown order codes return customer-facing `404 Not Found`.
