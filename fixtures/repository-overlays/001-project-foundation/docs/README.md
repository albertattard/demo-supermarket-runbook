# Architecture Decision Records

This directory contains architecture decision records for the project foundation
overlay.

The ADRs follow Michael Nygard's lightweight format: title, status, context,
decision, and consequences.

## Foundation Defaults

For local monitoring, the application exposes both `/actuator/health` and
`/actuator/info` without authentication. Unauthenticated requests to application
routes are redirected to the standard form-login page.

## Decisions

1. [Spring Boot and Maven](adr/ADR-001-spring-boot-and-maven.md)
2. [Java 25](adr/ADR-002-java-25.md)
3. [Server-Rendered Web Baseline](adr/ADR-003-server-rendered-web-baseline.md)
4. [Persistence Baseline](adr/ADR-004-persistence-baseline.md)
5. [Security Baseline](adr/ADR-005-security-baseline.md)
6. [Operational Baseline](adr/ADR-006-operational-baseline.md)
