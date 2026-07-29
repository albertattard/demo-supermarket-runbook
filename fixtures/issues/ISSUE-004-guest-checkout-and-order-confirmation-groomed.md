## Goal

Implement the first usable guest checkout: customers with an active cart can place a pickup order and view its confirmation.

## Resolved product decisions

- The canonical stored and URL order code is exactly 18 uppercase characters from `ABCDEFGHJKMNPQRSTVWXYZ`; it contains more than 80 bits of cryptographically secure randomness and encodes no business data.
- Display the code in three groups of six characters separated by hyphens.
- The database enforces case-insensitive uniqueness for the canonical code. Collision retry and its proof belong to story 6.
- Confirmation is public: the high-entropy code is the sole access mechanism. Unknown codes return `404 Not Found` using a dedicated customer-facing order-not-found page. Its heading is `Order not found`, it explains that the confirmation link may be incorrect or unavailable, and it includes a link back to the product catalog.
- The checkout request fields are `fullName`, `email`, and `phoneNumber`. Before snapshotting a successful checkout, trim leading and trailing whitespace from each value. This story proves the valid submission path; validation and error handling belong to story 7.
- Checkout is a normal full-document form submission, not an HTMX interaction.

## Scope

- Add order and order-item tables. Each order has a non-null, unique `cart_id` foreign key. The migration must enforce all snapshot fields, fulfillment type, status, and monetary totals as non-null; monetary columns use scale two. Order items must contain non-null snapshots of product name, unit label, unit price, quantity, and line total.
- The migration must enforce an 18-character canonical order code and case-insensitive uniqueness, so an insert of a lowercase-equivalent code is rejected. It must also enforce that a cart can belong to at most one order.
- Add the `PICKUP` fulfillment type and `PLACED` order status.
- Add a checkout form at `GET /cart/{cartToken}/checkout` for active, non-empty carts. Unknown or non-active carts retain the existing customer-facing `404` response.
- For an active, empty cart, `GET /cart/{cartToken}/checkout` returns `200 OK` with the existing empty-cart page and `Your cart is empty. Add items before checking out.` It does not render a checkout form.
- Add `POST /cart/{cartToken}/checkout` for valid pickup orders from an active, non-empty cart.
- On the existing cart page, display a Checkout link or button for an active, non-empty cart. It navigates to `GET /cart/{cartToken}/checkout`.
- Bind `fullName`, `email`, and `phoneNumber` from the checkout form. Before persistence, trim each value and persist the trimmed immutable snapshots for a valid submission.
- Persist immutable snapshots of product name, unit label, unit price, quantity, line total, customer fields, fulfillment type, goods subtotal, delivery fee, and grand total. Use current persisted prices and two-decimal `BigDecimal` monetary values.
- Pickup delivery fee is `0.00`.
- Re-check active, non-empty cart state while creating the order. Order creation and marking the cart `CHECKED_OUT` are one transaction.
- Repeated submission for a checked-out cart loads the order by its unique `cart_id` and returns its original confirmation URL; do not create another order.
- Checked-out carts retain the existing cart-not-found behaviour on cart routes.
- Add public `GET /orders/{orderCode}/confirmation`, accessible without authentication, displaying the grouped order code, pickup fulfillment type, customer name, item snapshots, goods subtotal, delivery fee, grand total, and `Pay when you collect your order.` Unknown codes return the dedicated order-not-found page.

## Out of Scope

- Delivery checkout (story 5).
- Pickup checkout validation, empty-cart `POST` and archived-product failure handling, and their customer-facing error responses (story 7).
- Collision retry, rollback injection, concurrent checkout, and corrupted checked-out-cart tests (story 6).
- Payments, accounts, cancellation, time slots, notifications, editing orders, and transitions beyond `PLACED`.

## Acceptance Criteria

- `./mvnw test` and `./mvnw verify` succeed.
- A full-stack or end-to-end test completes pickup checkout from an active cart.
- The cart page for an active, non-empty cart contains a Checkout link or button to `GET /cart/{cartToken}/checkout`.
- An active, empty cart has no Checkout entry point. A direct `GET` to its checkout URL returns `200 OK` with `Your cart is empty. Add items before checking out.` and no checkout form.
- The full-stack or end-to-end test submits whitespace-padded valid `fullName`, `email`, and `phoneNumber` values as a normal form post; the confirmation shows the trimmed values and they are persisted trimmed.
- Pickup checkout creates one `PLACED` order with immutable snapshots and a `0.00` delivery fee. The migration rejects a duplicate `cart_id`, a lowercase-equivalent duplicate order code, and null snapshot or total values.
- Valid checkout returns `303 See Other` to the 18-character canonical confirmation URL; the confirmation page shows the grouped code and all specified pickup information.
- Repeated checkout creates no additional order and redirects to the original confirmation page.
- Checked-out carts cannot be modified.
- The confirmation route is accessible without authentication. Unknown order codes return the dedicated customer-facing `404 Not Found` page with the heading `Order not found` and a link back to the product catalog.
