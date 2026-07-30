# Workshop runbook design

## Purpose

Split the current workflow into a provisioning runbook and a workshop task
runbook, while keeping all runbook sources in this repository.

## Repositories

- `demo-supermarket-runbook` is the authoring and provisioning repository. It
  contains both Sociable Weaver runbooks and their source fixtures.
- `demo-supermarket-starter` is the disposable, attendee-facing application
  starter repository. It may be recreated on demand and is not a destination
  for attendees' work to be merged back into.

`demo-supermarket-starter` must not contain Sociable Weaver runbooks. It may
contain generated Markdown documentation, application source, and the normal
application tooling.

## Provisioning model

The facilitator provisions the canonical `demo-supermarket-starter` repository
before the workshop. It contains the application after the first three project
stories and its prepared GitHub issue backlog. Attendees receive the repository
link and clone it as part of the workshop.

This is intentionally not a fork-based workflow. Forks do not copy GitHub
issues or most repository settings, and attendees do not need to merge changes
back into a shared upstream repository.

## Attendee entry point

The starter repository contains a generated `RUNBOOK.md`, prominently linked
from the application `README.md`. Attendees follow `RUNBOOK.md`; they do not
need a checkout of `demo-supermarket-runbook` or a local Sociable Weaver
installation.

The generated task guide may rely only on:

- the attendee's cloned starter repository;
- its canonical GitHub repository and public GitHub data; and
- explicitly linked, stable public web resources when needed.

It must not use relative paths into this repository such as `../fixtures` or
`../tools`, nor hard-code the former `albertattard/demo-supermarket` repository
name.

## GitHub realism and permissions

GitHub issues remain the canonical source of truth for the workshop briefs.
They are read-only context for attendees.

Issue 4 begins intentionally under-specified. During the workshop, the
facilitator updates issue 4 in the canonical starter repository as a live
grooming step. Attendees then refresh it and repeat the readiness assessment.

Attendees must not be instructed to create or edit GitHub issues, open pull
requests, or merge pull requests. Later workshop work is local: branches,
commits, skills, candidate implementations, review evidence, and selection.

## Intended split

### `starter-project-runbook.yaml`

Facilitator-only provisioning documentation with light explanations of the
major steps. It creates and prepares `demo-supermarket-starter`, including the
baseline application, initial issues, and required repository configuration.

### `workshop-task-runbook.yaml`

Authoring source for the generated attendee `RUNBOOK.md`. It describes the
actual workshop task, including the instructor-led update to issue 4 and the
local-only implementation workflow.

## Implementation follow-up

1. Extract the existing bootstrap, issue creation, and first-three-story steps
   into `starter-project-runbook.yaml` and rename the generated target to
   `demo-supermarket-starter`.
2. Create `workshop-task-runbook.yaml` from the remaining workshop material.
   Replace GitHub write operations with local equivalents and add the explicit
   instructor-led grooming pause.
3. Generate `RUNBOOK.md` from the workshop task runbook and arrange for it to
   be included in the provisioned starter repository, with a link from its
   application `README.md`.
4. Update `run.sh`, source fixtures, links, repository names, and validation
   commands to use explicit runbook input files.
5. Validate both runbooks. Do not run the full provisioning workflow against
   GitHub unless recreating the disposable starter repository is intended.
