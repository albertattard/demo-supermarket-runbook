# ADR 7: Operational Baseline

## Status

Accepted.

## Context

The foundation needs a minimal operational endpoint for readiness checks. Broader
operational visibility may be useful later, but there is no concrete need for
additional actuator endpoints in the foundation issue.

## Decision

We will expose only the Spring Boot Actuator health endpoint. We will defer
broader operational endpoints until there is a concrete need.

## Consequences

Local and CI readiness checks have a health endpoint available. The operational
surface area remains narrow at the foundation stage. Additional actuator
endpoints can be enabled later when their use is justified by a concrete need.
