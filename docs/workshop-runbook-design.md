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
stories and its prepared task backlog in `docs/tasks/`. Attendees receive the repository
link and clone it as part of the workshop.

This is intentionally not a fork-based workflow. Attendees do not need to merge
changes back into a shared upstream repository.

## Attendee entry point

The starter repository contains a generated `RUNBOOK.md`, prominently linked
from the application `README.md`. Attendees follow `RUNBOOK.md`; they do not
need a checkout of `demo-supermarket-runbook` or a local Sociable Weaver
installation.

The generated task guide may rely only on:

- the attendee's cloned starter repository;
- its canonical task files in `docs/tasks/`; and
- explicitly linked, stable public web resources when needed.

It must not use relative paths into this repository such as `../fixtures` or
`../tools`, nor hard-code the former `albertattard/demo-supermarket` repository
name.

## Task briefs and permissions

The task files remain the canonical source of truth for the workshop briefs.
They are read-only context for attendees.

Task 4 begins intentionally under-specified. During the workshop, the
facilitator resolves its open questions as a live grooming step. Attendees
record those decisions in their readiness assessment before repeating it.

Attendees must not be instructed to edit the canonical task files, open pull
requests, or merge pull requests. Later workshop work is local: branches,
commits, skills, candidate implementations, review evidence, and selection.

## Intended split

### `starter-project-runbook.yaml`

Facilitator-only provisioning documentation with light explanations of the
major steps. It creates and prepares `demo-supermarket-starter`, including the
baseline application, task briefs, and required repository configuration.

### `workshop-task-runbook.yaml`

Authoring source for the generated attendee `RUNBOOK.md`. It describes the
actual workshop task, including the instructor-led grooming of task 4 and the
local-only implementation workflow.

## Implementation follow-up

1. Extract the existing bootstrap and first-three-story steps
   into `starter-project-runbook.yaml` and rename the generated target to
   `demo-supermarket-starter`.
2. Create `workshop-task-runbook.yaml` from the remaining workshop material.
   Replace GitHub write operations with local equivalents and add the explicit
   instructor-led grooming pause.
3. Generate `RUNBOOK.md` from the workshop task runbook and arrange for it to
   be included in the provisioned starter repository, with a link from its
   application `README.md`.
4. Replace `run.sh` with `starter-project-runbook.sh` and
   `workshop-task-runbook.sh`, update source fixtures, links, repository names,
   and validation commands to use explicit runbook input files.
5. Validate both runbooks. Do not run the full provisioning workflow against
   GitHub unless recreating the disposable starter repository is intended.
