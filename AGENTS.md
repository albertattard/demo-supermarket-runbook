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
- `workshop-task-runbook.sh` renders `RUNBOOK.md` into that provisioned clone,
  then creates and merges the facilitator publication PR.
- `fixtures/README.md` becomes the generated target repository README.
- `fixtures/LICENSE` becomes the generated target repository licence.
- `fixtures/issues/` contains GitHub issue bodies used during provisioning.
- `fixtures/pr/` contains facilitator pull-request bodies and generated URL
  outputs.
- `fixtures/repository-overlays/` contains staged application overlays used only
  during facilitator provisioning.
- `/tmp/demo-supermarket-starter`, when present, is generated output and
  should not be treated as source.

## Editing Guidance

Prefer editing the appropriate runbook source and files under `fixtures/`.

Do not manually patch generated files in `/tmp/demo-supermarket-starter` unless
the task is specifically to inspect or debug generated output. Instead, update
the runbook or fixtures and regenerate.

When changing generated application content, place the intended final files in
the appropriate `fixtures/repository-overlays/<step>/` directory.

When changing issue or pull request text, edit the matching Markdown file under
`fixtures/issues/` or `fixtures/pr/`.

## Validation

After runbook or fixture changes, run:

```shell
sw validate --input-file starter-project-runbook.yaml
sw validate --input-file workshop-task-runbook.yaml
```

Run `./starter-project-runbook.sh` only when recreating the disposable GitHub
starter repository is intended. Run `./workshop-task-runbook.sh` afterwards to
publish the generated attendee guide through its facilitator PR.

## Naming

Use `demo-supermarket-runbook` for this repository.

Use `demo-supermarket-starter` only for the generated target repository.
