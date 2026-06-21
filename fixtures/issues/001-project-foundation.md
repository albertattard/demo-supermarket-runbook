## Goal

Create the baseline Spring Boot project for the Demo Supermarket application so
future feature work can be built, tested, and reviewed consistently.

This issue establishes the build, application skeleton, configuration, database
migration setup, CI workflow, and basic documentation. It should not implement
supermarket business features yet.

## Context

Demo Supermarket is a server-rendered Spring Boot application for a workshop
scenario. This first issue should leave the repository in a clean, runnable
state with the framework, test lifecycle, and documentation conventions in
place.

Engineers working on later issues should be able to clone the repository, run
the application, run the test suite, and understand the intended stack without
needing any additional setup notes.

## Assumptions

- This is the first application implementation issue.
- No product, cart, checkout, logistics, or inventory behavior exists yet.
- The application uses server-rendered pages with Thymeleaf and HTMX, not a
  JavaScript frontend framework.
- H2 is used as an in-memory development and test database.
- Flyway owns schema creation from the beginning, even if the initial migration
  only establishes the migration baseline.

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
- Add HTMX as a local/static resource or dependency-managed web asset so future
  Thymeleaf pages can use it without relying on an external CDN.
- Configure H2 as an in-memory database for local development and tests.
- Configure Flyway to load migrations from the standard
  `src/main/resources/db/migration` location.
- Add an initial Flyway migration file so Flyway runs successfully on startup.
  The migration may be intentionally minimal, but it must be valid SQL and must
  not create supermarket business tables.
- Add application configuration for the default local profile.
- Expose `/actuator/health` through Actuator for local readiness checks and CI.
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
- E2E browser flows beyond build wiring
- Production database configuration
- Deployment configuration
- Docker or container setup
- Frontend build tooling

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw verify` succeeds.
- GitHub Actions runs `./mvnw verify` on pull requests and pushes to `main`.
- Application starts locally with `./mvnw spring-boot:run`.
- `/actuator/health` returns HTTP 200 when the app is running.
- Flyway runs during application startup using
  `src/main/resources/db/migration`.
- The initial Flyway migration is present, valid, and does not create business
  tables.
- H2 in-memory configuration is present for local development and tests.
- Maven Wrapper files are committed and documented.
- `.gitignore` excludes build outputs, IDE metadata, and local runtime files
  that should not be committed.
- `.editorconfig` defines consistent formatting basics for the repository.
- README explains the project purpose, stack, and how to run/test it.
- `docs/README.md` records the key architectural decisions made so far.
- The application does not require Node, npm, Docker, or an external database to
  run locally.
