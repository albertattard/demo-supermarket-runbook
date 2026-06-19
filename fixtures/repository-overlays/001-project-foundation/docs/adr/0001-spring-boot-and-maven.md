# ADR 1: Spring Boot and Maven

## Status

Accepted.

## Context

The project needs a conventional Java application foundation from the start. The
foundation must provide build structure, dependency management, and a plugin
lifecycle for development and automation.

## Decision

We will use Spring Boot with Maven for the application foundation.

## Consequences

The project starts with a standard Spring Boot structure and a Maven build.
Dependencies and build plugins can be managed through Maven conventions.
Future changes to the build system would need to account for the Spring Boot and
Maven lifecycle already established by this decision.
