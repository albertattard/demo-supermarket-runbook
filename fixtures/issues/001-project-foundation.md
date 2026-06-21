## Goal

Create the baseline Spring Boot project for the Demo Supermarket application so future feature work can be built, tested, and reviewed consistently.

This issue establishes the build, application skeleton, configuration, database migration setup, CI workflow, and basic documentation. It should not implement supermarket business features yet.

## Context

Demo Supermarket is a server-rendered Spring Boot application for a workshop scenario. This first issue should leave the repository in a clean, runnable state with the framework, test lifecycle, and documentation conventions in place.

Engineers working on later issues should be able to clone the repository, run the application, run the test suite, and understand the intended stack without needing any additional setup notes.

## Assumptions

- This is the first application implementation issue.
- No product, cart, checkout, logistics, or inventory behavior exists yet.
- The application uses server-rendered pages with Thymeleaf and HTMX, not a JavaScript frontend framework.
- H2 is used as an in-memory development and test database.
- Flyway owns schema creation from the beginning, even if the initial migration only establishes the migration baseline.
- Browser-based E2E testing is introduced in this issue with a minimal smoke test. Later UI stories should extend the E2E suite for the workflows they add.

## Scope

- Create a Maven-based Spring Boot application.
- Use Java 25.
- Use package `demo.supermarket`.
- Use application class `SupermarketApplication`.
- Add dependencies for:
  - Spring Web MVC
  - Thymeleaf
  - HTMX static resource support
  - Spring Security
  - Spring Data JPA
  - H2
  - Flyway
  - Spring Boot Actuator
  - Bean Validation
  - Java Playwright for E2E tests
- Add HTMX as a local/static resource or dependency-managed web asset so future Thymeleaf pages can use it without relying on an external CDN.
- Configure H2 as an in-memory database for local development and tests.
- Configure Flyway to load migrations from the standard `src/main/resources/db/migration` location.
- Add an initial Flyway migration file so Flyway runs successfully on startup. The migration may be intentionally minimal, but it must be valid SQL and must not create supermarket business tables.
- Add application configuration for the default local profile.
- Expose `/actuator/health` through Actuator for local readiness checks and CI.
- Add a minimal server-rendered home page at `/` with the application name and a short placeholder message.
- Keep the home page deliberately small; it exists as an initial smoke-test target until the catalog issue replaces `/` with the product catalog.
- Configure Java Playwright, not Node Playwright.
- Install Playwright browser binaries as part of the build/test setup.
- Run Playwright browsers headless.
- Tag all E2E tests with `@Tag("e2e")`.
- Configure Surefire to exclude `e2e` tests from `./mvnw test`.
- Configure Failsafe or equivalent Maven lifecycle wiring to run only `e2e` tests during `./mvnw verify`.
- Start the Spring Boot application before E2E tests on a predictable port.
- Use an `e2e` Spring profile for E2E runs.
- Use `/actuator/health` as the E2E readiness check.
- Add a minimal Playwright smoke test that opens `/` and verifies the initial home page renders.
- Add Maven Wrapper.
- Add `.gitignore` and `.editorconfig`.
- Add GitHub Actions workflow running `./mvnw verify`.
- Use Oracle Java 25 in GitHub Actions.
- Add initial `README.md` with setup, run, and test instructions.
- Add `docs/README.md` with the architectural decisions made in this issue.

## Out of Scope

- Product catalog
- Shopping bag/cart
- Checkout
- Orders
- Logistics dashboard
- Inventory management screens
- Seeded business data
- Authentication screens beyond default/security placeholder behavior
- E2E browser flows beyond the initial home page smoke test
- Marketing landing page content
- Catalog-specific E2E assertions
- Cart, checkout, logistics, or inventory E2E coverage
- Visual regression testing
- Cross-browser test matrix
- Mobile viewport test matrix
- Screenshots or videos as required test artifacts
- Node-based Playwright tooling
- Production database configuration
- Deployment configuration
- Docker or container setup
- Frontend build tooling

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw test` does not run E2E tests.
- `./mvnw verify` succeeds.
- `./mvnw verify` runs E2E tests.
- E2E tests are selected by `@Tag("e2e")`, not only by class name.
- GitHub Actions runs `./mvnw verify` on pull requests and pushes to `main`.
- Application starts locally with `./mvnw spring-boot:run`.
- `/actuator/health` returns HTTP 200 when the app is running.
- `/` returns HTTP 200 and renders a minimal server-side home page.
- The home page makes clear that catalog functionality is not implemented yet.
- The E2E Maven lifecycle starts the Spring Boot application before browser tests and stops it after the tests complete.
- E2E tests wait for `/actuator/health` before opening browser pages.
- Playwright runs headless locally and in GitHub Actions.
- The initial E2E smoke test opens `/` and verifies the home page renders.
- Flyway runs during application startup using `src/main/resources/db/migration`.
- The initial Flyway migration is present, valid, and does not create business tables.
- H2 in-memory configuration is present for local development and tests.
- Maven Wrapper files are committed and documented.
- `.gitignore` excludes build outputs, IDE metadata, and local runtime files that should not be committed.
- `.editorconfig` defines consistent formatting basics for the repository.
- README explains the project purpose, stack, and how to run/test it.
- `docs/README.md` records the key architectural decisions made so far.
- The application does not require Node, npm, Docker, or an external database to run locally.
