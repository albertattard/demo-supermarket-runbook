## Goal

Make the pickup checkout introduced in story 4 handle invalid customer input and invalid cart states clearly, without changing its successful checkout or confirmation behaviour.

## Depends On

- Story 4: guest pickup checkout and order confirmation.

## Scope

- Keep pickup checkout as a normal full-document form submission, not an HTMX interaction.
- For an active but empty cart, `GET /cart/{cartToken}/checkout` renders the existing empty-cart page with `200 OK` and the message `Your cart is empty. Add items before checking out.`; it does not return `404`.
- An active, empty cart has no checkout entry point on its cart page.
- Before validation or persistence, trim leading and trailing whitespace from `fullName`, `email`, and `phoneNumber`. Empty-after-trimming values are invalid; whitespace-padded valid values are accepted, redisplayed trimmed, and persisted trimmed.
- Require each customer field to be non-blank after trimming. Validate email with Jakarta Bean Validation's `@Email`; `albert@example.com` is valid and `albert.example.com` is invalid.
- Validation failures render the checkout page directly with `422 Unprocessable Content`, do not redirect, preserve trimmed submitted values, and show programmatically associated inline errors.
- A direct empty-cart checkout submission renders the checkout page with `422 Unprocessable Content`, preserves trimmed submitted values, and shows a clear form-level error.
- Re-check that every cart product is active while creating an order. If a product was archived after the cart was populated, render the checkout page with `422 Unprocessable Content`, preserve trimmed submitted values, show a clear form-level error, and create no order.

## Out of Scope

- Changing successful pickup checkout, confirmation, order snapshots, cart locking, or repeated-submission behaviour from story 4.
- Delivery address validation and delivery postal-code eligibility (story 5).
- Collision, rollback, concurrency, and corrupted-data checkout hardening (story 6).
- HTMX checkout interactions, client-side validation, payments, accounts, cancellation, notifications, and order lifecycle changes.

## Acceptance Criteria

- `./mvnw test` and `./mvnw verify` succeed.
- An active, empty cart has no checkout entry point, and a direct `GET` to its checkout URL returns `200 OK` with the existing empty-cart state and `Your cart is empty. Add items before checking out.` rather than `404`.
- A whitespace-padded valid `fullName`, `email`, and `phoneNumber` submission succeeds; the confirmation shows the trimmed values and they are persisted trimmed.
- Missing contact fields and an invalid email return `422 Unprocessable Content` without redirecting, preserve the trimmed submitted values, and show associated inline errors.
- An empty-cart submission and an archived-product submission return `422 Unprocessable Content` without redirecting, preserve the trimmed submitted values, and show a clear form-level error. The archived-product test archives a cart product after the cart is populated and proves that no order is created.
