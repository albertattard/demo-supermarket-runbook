# Demo Supermarket

Demo Supermarket is a simple online supermarket application used as a baseline
project for a Java and AI workshop.

Customers can browse products, add items to a shopping bag, and place a guest
order for pickup or delivery. Logistics users can prepare orders and update
their status. Inventory users can manage the product catalog.

This project is intentionally incomplete. It is designed to be extended through
AI-assisted development workflows.

## Tech Stack

- Java 25
- Spring Boot
- Thymeleaf
- HTMX
- Spring Security
- Spring Data JPA
- H2 in-memory database
- Flyway
- Java Playwright
- Maven
- GitHub Actions

No React, Angular, Vue, or other JavaScript frontend framework is used.

No containers are required.

## Personas

### Customer

Customers do not need an account.

They can:

- browse active products
- search/filter the catalog
- add products to a shopping bag
- checkout as a guest
- choose pickup or delivery
- receive a human-friendly order code

### Logistics

Logistics users can:

- view orders
- search by order code
- update order status
- cancel orders when allowed

### Inventory

Inventory users can:

- manage products
- manage categories
- archive/unarchive catalog items

Inventory users do not manage orders or delivery postal codes.

## Fulfillment

Customers can choose one fulfillment method:

- pickup
- delivery

Pickup has no fee.

Delivery is available only for configured German postal codes.

Delivery costs `€4.99` when the goods subtotal is below `€50.00`.

Delivery is free when the goods subtotal is `€50.00` or more.

Payment is not handled by the website. Customers pay on pickup or delivery.

## Order Lifecycle

Orders start as `PLACED`.

Common transition:

```text
PLACED -> PREPARING
```

Pickup orders:

```text
PREPARING -> READY_FOR_PICKUP -> COMPLETED
```

Delivery orders:

```text
PREPARING -> OUT_FOR_DELIVERY -> COMPLETED
```

Orders may be cancelled from `PLACED` or `PREPARING`.

The backend must reject invalid transitions, even if the UI hides invalid
actions.

## Shopping Bag

Guest carts are persisted in the database and identified by an opaque cart token
in the URL.

Example:

```text
/cart/{cartToken}
```

Cart URLs should not expose database IDs.

When checkout completes, the cart becomes read-only and an order is created.

## Pricing

Products are sold by a fixed unit label and unit price.

Examples:

| Product | Unit | Unit Price | Quantity | Line Total |
| ------------ | ---: | ----: | -------: | ---------: |
| Milk         | 1L   | €1.49 |        3 |      €4.47 |
| Strawberries | 500g | €3.29 |        2 |      €6.58 |
| Bananas      | each | €0.35 |        6 |      €2.10 |

The baseline does not support decimal quantities or price-per-kg pricing.

Money should be stored using `BigDecimal`, not `double`.

When an order is created, product name, unit label, unit price, quantity, and
totals are copied into order item snapshots. Later product changes must not
affect existing orders.

## Demo Users

Demo users are seeded through Flyway.

| Username    | Password    | Role             |
| ----------- | ----------- | ---------------- |
| `logistics` | `logistics` | `ROLE_LOGISTICS` |
| `inventory` | `inventory` | `ROLE_INVENTORY` |

Passwords should be stored as BCrypt hashes, not plain text.

## Database

The application uses an H2 in-memory database.

Flyway is used for:

- schema creation
- seed data

Data is reset when the application restarts.

Seeded data includes:

- categories
- products
- delivery postal codes
- demo users

Seeded data should not include orders.

## Testing

The project uses Maven.

Unit and integration tests run with:

```bash
./mvnw test
```

The full verification build runs with:

```bash
./mvnw verify
```

Java Playwright E2E tests are tagged with:

```java
@Tag("e2e")
```

E2E tests should run during the Maven `verify` phase, not during normal unit
test execution.

Example E2E test names:

```text
CustomerCheckoutE2eTest
DeliveryCheckoutE2eTest
LogisticsOrderE2eTest
InventoryProductE2eTest
```

Playwright should run headless and work in GitHub Actions.

## GitHub Actions

The repository should include a GitHub Actions workflow that runs:

```bash
./mvnw verify
```

The workflow should run on:

- pull requests to `main`
- pushes to `main`

The workflow should use Oracle Java 25.

## Workshop Automation Flow

The intended workflow is:

1. Select a feature from the backlog.
2. Ask an AI agent to implement the feature on a branch.
3. The AI agent creates a pull request.
4. GitHub Actions runs the build and tests.
5. A second AI review step reviews the change.
6. If review feedback is raised, the implementation is reworked.
7. A human performs the final review before merge.

The exact AI review mechanism depends on the workshop harness and may evolve.

## Intentionally Missing Features

The project is intentionally incomplete. Possible future features include:

- stock tracking and availability
- pickup and delivery time slots
- customer accounts
- customer order history
- customer-side cancellation
- payment integration
- product images
- admin-managed delivery postal codes
- richer validation messages
- audit trail for order status changes
- delivery assignment or driver workflow
- GitHub Issues backlog automation

## License

[MIT](LICENSE)
