# ADR 3: Package and Application Entry Point

## Status

Accepted.

## Context

The application needs a root package and a Spring Boot entry point so source code
has a defined starting location and component scanning has a stable base.

## Decision

We will place application code under the `demo.supermarket` package and use
`SupermarketApplication` as the Spring Boot entry point.

## Consequences

Application code has a clear package root. Spring Boot component scanning starts
from the `demo.supermarket` package by default. Future package layout changes
need to preserve or deliberately revise that scanning boundary.
