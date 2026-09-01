# demo-supermarket-runbook

This repository is the reproducible source for the disposable, attendee-facing
`demo-supermarket-starter` GitHub repository. It is not the supermarket
application repository itself.

## Repository Structure

- `starter-project-runbook.yaml` is the facilitator-only provisioning source.
- `workshop-task-runbook.yaml` generates the attendee-facing `RUNBOOK.md`.
- `starter-project-runbook.sh` provisions the starter repository from its
  matching runbook. It deletes and recreates `/tmp/demo-supermarket-starter`
  and has GitHub side effects.
- `workshop-task-runbook.sh` renders the attendee-facing runbook locally.
- `fixtures/repository-overlays/000-starter/README.md` becomes the generated target repository README.
- `fixtures/repository-overlays/000-starter/LICENSE` becomes the generated target repository licence.
- `fixtures/repository-overlays/` contains staged application overlays used only
  during facilitator provisioning. The initial overlay's `docs/tasks/` directory
  contains the attendee-facing task briefs.
- `/tmp/demo-supermarket-starter`, when present, is generated output and
  should not be treated as source.

## Editing Guidance

Prefer editing the appropriate runbook source and files under `fixtures/`.

When creating or deliberately reformatting an attendee-facing workshop runbook,
follow [docs/workshop-runbook-format.md](docs/workshop-runbook-format.md). It is
an authoring standard, not an instruction to reformat unrelated runbooks.

Do not manually patch generated files in `/tmp/demo-supermarket-starter` unless
the task is specifically to inspect or debug generated output. Instead, update
the runbook or fixtures and regenerate.

When changing generated application content, place the intended final files in
the appropriate `fixtures/repository-overlays/<step>/` directory.

When changing task text, edit the matching Markdown file under
`fixtures/repository-overlays/001-project-foundation/docs/tasks/`.

## Validation

After runbook or fixture changes, run:

```shell
sw validate --input-file starter-project-runbook.yaml
sw validate --input-file workshop-task-runbook.yaml
```

Run `./starter-project-runbook.sh` only when recreating the disposable GitHub
starter repository is intended. Run `./workshop-task-runbook.sh` to render the
attendee guide locally.

## Naming

Use `demo-supermarket-runbook` for this repository.

Use `demo-supermarket-starter` only for the generated target repository.
