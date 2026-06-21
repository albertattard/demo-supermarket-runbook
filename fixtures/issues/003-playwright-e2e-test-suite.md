## Goal

Add the Java Playwright end-to-end test foundation and initial catalog browser
coverage.

This issue moves E2E coverage early in the project so later UI stories can add
or update browser tests as they introduce new user-facing flows.

## Context

This issue runs third, after the project foundation and the seeded catalog
listing. At this point, the application has a public server-rendered catalog at
`/` and `/products`, but it does not yet have cart, checkout, login, logistics,
or inventory screens.

The goal is to make E2E testing part of the normal Maven verification lifecycle
now, while keeping the initial browser coverage aligned with the UI that already
exists.

## Assumptions

- The catalog issue has already created seeded products and categories.
- `/actuator/health` is available for readiness checks.
- The application can run locally without Node, npm, Docker, or an external
  database.
- Later UI stories are responsible for extending E2E coverage for their own
  flows.

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
- Add initial catalog E2E tests that verify:
  - `/` renders the product catalog
  - `/products` renders the product catalog
  - seeded active products are visible
  - category filtering works in the browser
  - text search works in the browser
  - category filtering and text search work together
  - an empty search/filter result shows the catalog empty state
- Keep E2E selectors stable enough that later UI polish does not require
  rewriting tests for cosmetic changes.
- Document the convention that future UI stories must add or update E2E tests
  for the workflows they introduce.
- Ensure GitHub Actions can run the E2E tests without containers.

## Out of Scope

- Cart E2E coverage
- Checkout E2E coverage
- Login/security E2E coverage
- Logistics E2E coverage
- Inventory E2E coverage
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
- The E2E Maven lifecycle starts the Spring Boot application before browser
  tests and stops it after the tests complete.
- E2E tests wait for `/actuator/health` before opening browser pages.
- Catalog E2E coverage verifies that `/` and `/products` render successfully.
- Catalog E2E coverage verifies visible seeded products.
- Catalog E2E coverage verifies category filtering.
- Catalog E2E coverage verifies text search.
- Catalog E2E coverage verifies combined category filtering and text search.
- Catalog E2E coverage verifies the empty state for unmatched filters.
- Documentation explains how to run E2E tests and how later stories should
  extend the suite.
