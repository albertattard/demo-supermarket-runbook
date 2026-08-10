# TASK-004 readiness decisions

Attach this file when running a non-interactive readiness review for TASK-004. The decisions below are settled; do not ask these questions again or replace them with implementation assumptions.

## Question and answer record

### Does TASK-004 include validation and invalid-cart failure handling, or does TASK-007 own it?

TASK-007 owns it. TASK-004 covers the successful pickup-checkout and confirmation path only. Validation failures, empty-cart failures, and archived-product failures are out of scope for TASK-004.

### What order reference should TASK-004 use?

Use an eight-character uppercase reference drawn from `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`. This excludes easily confused characters and provides 32^8 possible references. It is an order reference, not an order-confirmation access credential.

### What happens if an order-reference collision occurs?

The database enforces uniqueness. A collision fails checkout using the existing generic error response. Retry behaviour is deferred to TASK-006.

### Who can view an order confirmation?

Only the browser session that placed the order can view it. Durable cross-session confirmation access is deferred to a follow-up task.

### What happens for an unknown order reference or a confirmation request without the required session association?

Return `404 Not Found` with a generic `Order not found` page. Use the same response in both cases.

### What happens when a checked-out cart is requested or modified?

`GET /cart/{cartToken}` and cart-modification routes retain the established cart-not-found behaviour. The only exception is a repeated `POST /cart/{cartToken}/checkout`, which redirects to the existing confirmation without creating another order.

### Which information must the confirmation page display?

Display the complete immutable order snapshot:

- Order reference, placed time, and pickup fulfilment.
- Customer full name, email, and phone number.
- Every purchased line's product name, unit label, unit price, quantity, and line total.
- Goods subtotal, delivery fee, and grand total.

## Remaining delivery boundary

These decisions do not change TASK-004's existing exclusions: delivery, checkout-integrity hardening, payments, accounts, cancellation, notifications, and lifecycle work beyond `PLACED` remain out of scope.
