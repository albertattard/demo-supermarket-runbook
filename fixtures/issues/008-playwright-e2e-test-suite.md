## Goal

Add Java Playwright end-to-end tests that run headless during Maven `verify`.

The E2E suite should exercise the main customer, logistics, and inventory flows.

## Scope

- Use Java Playwright, not Node Playwright.
- Install Playwright browser binaries as part of the build/test setup.
- Run browsers headless.
- Tag all E2E tests with `@Tag("e2e")`.
- Configure Surefire to exclude `e2e` tests from `mvn test`.
- Configure Failsafe or equivalent Maven lifecycle wiring to run only `e2e`
  tests during `mvn verify`.
- Start the Spring Boot app before E2E tests on a predictable port.
- Use the `e2e` Spring profile for E2E runs.
- Use `/actuator/health` as the readiness check.
- Add E2E tests named:
  - `CustomerCheckoutE2eTest`
  - `DeliveryCheckoutE2eTest`
  - `LogisticsOrderE2eTest`
  - `InventoryProductE2eTest`
- Ensure GitHub Actions can run the E2E tests without containers.

## Out of Scope

- Visual regression testing
- Cross-browser matrix
- Mobile viewport matrix
- Screenshots/videos as required artifacts
- Node-based Playwright tooling

## Acceptance Criteria

- `./mvnw test` does not run E2E tests.
- `./mvnw verify` runs E2E tests.
- E2E tests are selected by `@Tag("e2e")`, not only by class name.
- Playwright runs headless locally and in GitHub Actions.
- Customer checkout E2E creates a pickup order and sees an order code.
- Delivery checkout E2E verifies allowed postal code and delivery fee behavior.
- Logistics E2E logs in and moves an order through valid statuses.
- Inventory E2E logs in and creates or edits a product visible in the catalog.
