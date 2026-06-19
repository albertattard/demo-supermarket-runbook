# ADR 4: Server-Rendered Web Baseline

## Status

Accepted.

## Context

The foundation issue establishes the web application baseline but does not
implement business screens. The project needs dependencies for a server-rendered
web application before specific screens are built.

## Decision

We will include Spring Web MVC, Thymeleaf, and the HTMX WebJar for the
server-rendered web baseline. We will not implement business screens as part of
the foundation issue.

## Consequences

The project is prepared for server-rendered web flows using Spring MVC,
Thymeleaf templates, and HTMX. Business screens can be added later on top of this
baseline. The project does not yet commit to client-side application structure
or screen-level behavior beyond these dependencies.
