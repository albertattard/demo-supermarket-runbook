# ADR 5: Persistence Baseline

## Status

Accepted.

## Context

The foundation needs persistence infrastructure before domain-specific data
modeling is implemented. Local development and tests need a database that can run
without external infrastructure, and schema changes need an explicit ownership
mechanism.

## Decision

We will configure Spring Data JPA, H2, and Flyway immediately. H2 will run in
memory for local development and tests. Flyway will own schema evolution through
`src/main/resources/db/migration`.

## Consequences

The project has a persistence stack available at the foundation stage. Local
development and tests can run against an in-memory H2 database. Schema changes
are expected to be represented as Flyway migrations under
`src/main/resources/db/migration`. Future persistence changes must account for
the JPA, H2, and Flyway baseline.
