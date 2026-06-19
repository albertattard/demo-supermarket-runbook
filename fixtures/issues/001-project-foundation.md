## Goal

Create the baseline Spring Boot project structure for the Demo Supermarket
application.

This issue establishes the build, application skeleton, configuration, database
migration setup, CI workflow, and basic documentation. It should not implement
supermarket business features yet.

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
- Configure H2 in-memory database.
- Configure Flyway migrations folder.
- Add an empty first migration or placeholder migration strategy.
- Add basic application configuration.
- Add `/actuator/health` readiness endpoint through Actuator.
- Add Maven Wrapper.
- Add `.gitignore` and `.editorconfig`.
- Add GitHub Actions workflow running `./mvnw verify`.
- Use Oracle Java 25 in GitHub Actions.
- Add initial `README.md`.
- Add `docs/README.md`.

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

## Acceptance Criteria

- `./mvnw test` succeeds.
- `./mvnw verify` succeeds.
- GitHub Actions runs `./mvnw verify` on pull requests and pushes to `main`.
- Application starts locally with `./mvnw spring-boot:run`.
- `/actuator/health` returns HTTP 200 when the app is running.
- Flyway is enabled and ready for migrations.
- H2 in-memory configuration is present.
- README explains the project purpose, stack, and how to run/test it.
- `docs/README.md` records the key architectural decisions made so far.
- No `AGENTS.md` file is added.
