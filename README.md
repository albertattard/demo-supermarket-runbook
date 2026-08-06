# Demo Supermarket workshop

Demo Supermarket is a hands-on workshop for practising AI-assisted software
delivery in a realistic, deliberately incomplete application.

The workshop uses an online grocery store built with Spring Boot. Its starting
point lets customers browse a catalogue and maintain a persisted guest cart. The
remaining backlog introduces checkout, fulfilment, operational workflows,
security, inventory management, and further quality improvements.

## What participants practise

Participants use the canonical task backlog as product context, assess whether
a task is ready to implement, clarify ambiguity through live grooming, and
develop evidence-backed implementation candidates. The exercise emphasises
small, reviewable changes, tests, verification, and explicit assumptions rather
than treating generated code as automatically trustworthy.

Work is intentionally local to each participant's clone. The shared starter
repository provides common context and task briefs; it is not a destination for
attendee pull requests or merged workshop changes.

## The application scenario

Customers can browse and search grocery products, add products to a shopping
bag, and progressively gain pickup and delivery checkout journeys. Logistics
staff will manage orders, while inventory staff will maintain the catalogue. The
domain is compact enough for a workshop, but includes the constraints and
trade-offs that make product work worth discussing.

## Starter repository

Workshop participants receive a link to the disposable
`demo-supermarket-starter` repository. Its `RUNBOOK.md` is the participant entry
point.

This repository maintains the workshop source material and should not be used
as the application working copy.
