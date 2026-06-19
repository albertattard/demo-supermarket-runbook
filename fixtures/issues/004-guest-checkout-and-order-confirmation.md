## Goal

Implement guest checkout for pickup and delivery and create immutable order
snapshots.

Customers should be able to convert an active cart into an order and receive a
human-friendly order code.

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
- Add checkout route `/cart/{cartToken}/checkout`.
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
- Calculate delivery fee:
  - pickup: `0.00`
  - delivery under `50.00` goods subtotal: `4.99`
  - delivery with goods subtotal `50.00` or more: `0.00`
- Use goods subtotal before delivery fee for the threshold.
- Generate a human-friendly public order code.
- Avoid confusing characters in order codes where practical.
- Snapshot product name, unit label, unit price, quantity, and line total into
  order items.
- Store goods subtotal, delivery fee, and grand total on the order.
- Mark the cart as `CHECKED_OUT` after successful checkout.
- Reject checkout if the cart is empty.
- Reject checkout if a cart product is archived before checkout.

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
- Pickup checkout creates an order with status `PLACED`.
- Delivery checkout creates an order with status `PLACED` only for allowed
  postal codes.
- Delivery fee is `4.99` below `50.00` goods subtotal.
- Delivery fee is `0.00` at or above `50.00` goods subtotal.
- Confirmation page shows order code, fulfillment type, totals, and
  pay-on-pickup/delivery message.
- Checked-out carts cannot be modified.
- Existing order item snapshots do not change when product details change later.
