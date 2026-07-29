## Goal

Implement the first usable guest checkout: customers with an active cart can place a pickup order and view its confirmation.

## Resolved product decisions

- The canonical stored and URL order code is exactly 18 uppercase characters from `ABCDEFGHJKMNPQRSTVWXYZ`; it contains more than 80 bits of cryptographically secure randomness and encodes no business data.
- Display the code in three groups of six characters separated by hyphens.
- The database enforces case-insensitive uniqueness for the canonical code. Collision retry and its proof belong to story 6.
- Confirmation is public: the high-entropy code is the sole access mechanism. Unknown codes return the existing customer-facing `404 Not Found` page.
- The checkout request fields are `fullName`, `email`, and `phoneNumber`. This story proves the valid submission path; trimming, validation, and error handling belong to story 7.
- Checkout is a normal full-document form submission, not an HTMX interaction.

## Scope

- Add order and order-item tables. Each order has a non-null, unique `cart_id` foreign key. The migration must enforce all snapshot fields, fulfillment type, status, and monetary totals as non-null; monetary columns use scale two. Order items must contain non-null snapshots of product name, unit label, unit price, quantity, and line total.
- The migration must enforce an 18-character canonical order code and case-insensitive uniqueness, so an insert of a lowercase-equivalent code is rejected. It must also enforce that a cart can belong to at most one order.
- Add the `PICKUP` fulfillment type and `PLACED` order status.
- Add a checkout form at `GET /cart/{cartToken}/checkout` for active, non-empty carts. Unknown or non-active carts retain the existing customer-facing `404` response.
- Add `POST /cart/{cartToken}/checkout` for valid pickup orders from an active, non-empty cart.
- On the existing cart page, display a Checkout link or button for an active, non-empty cart. It navigates to `GET /cart/{cartToken}/checkout`.
- Bind `fullName`, `email`, and `phoneNumber` from the checkout form and persist their immutable snapshots for a valid submission.
- Persist immutable snapshots of product name, unit label, unit price, quantity, line total, customer fields, fulfillment type, goods subtotal, delivery fee, and grand total. Use current persisted prices and two-decimal `BigDecimal` monetary values.
- Pickup delivery fee is `0.00`.
- Re-check active, non-empty cart state while creating the order. Order creation and marking the cart `CHECKED_OUT` are one transaction.
- Repeated submission for a checked-out cart loads the order by its unique `cart_id` and returns its original confirmation URL; do not create another order.
- Checked-out carts retain the existing cart-not-found behaviour on cart routes.
- Add public `GET /orders/{orderCode}/confirmation` displaying the grouped order code, pickup fulfillment type, customer name, item snapshots, goods subtotal, delivery fee, grand total, and `Pay when you collect your order.`

## Out of Scope

- Delivery checkout (story 5).
- Pickup checkout validation, empty-cart and archived-product failure handling, and their customer-facing error responses (story 7).
- Collision retry, rollback injection, concurrent checkout, and corrupted checked-out-cart tests (story 6).
- Payments, accounts, cancellation, time slots, notifications, editing orders, and transitions beyond `PLACED`.

## Acceptance Criteria

- `./mvnw test` and `./mvnw verify` succeed.
- A full-stack or end-to-end test completes pickup checkout from an active cart.
- The cart page for an active, non-empty cart contains a Checkout link or button to `GET /cart/{cartToken}/checkout`.
- The full-stack or end-to-end test submits valid `fullName`, `email`, and `phoneNumber` values as a normal form post.
- Pickup checkout creates one `PLACED` order with immutable snapshots and a `0.00` delivery fee. The migration rejects a duplicate `cart_id`, a lowercase-equivalent duplicate order code, and null snapshot or total values.
- Valid checkout returns `303 See Other` to the 18-character canonical confirmation URL; the confirmation page shows the grouped code and all specified pickup information.
- Repeated checkout creates no additional order and redirects to the original confirmation page.
- Checked-out carts cannot be modified.
- Unknown order codes return customer-facing `404 Not Found`.
