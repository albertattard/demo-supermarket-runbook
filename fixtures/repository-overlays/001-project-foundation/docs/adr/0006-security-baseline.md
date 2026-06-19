# ADR 6: Security Baseline

## Status

Accepted.

## Context

The foundation needs security enabled early enough that later features are built
with authentication in mind. At the same time, local and CI readiness checks need
a way to verify the application without credentials.

## Decision

We will enable Spring Security with default login behavior. We will keep the
health endpoint public so local and CI readiness checks can verify the
application without credentials.

## Consequences

Application routes are protected by the Spring Security baseline unless
configured otherwise. The default login behavior is available before custom
authentication flows are implemented. Health checks remain usable by local and
CI automation without credential handling. Future security changes must preserve
or intentionally replace the public health-check behavior.
