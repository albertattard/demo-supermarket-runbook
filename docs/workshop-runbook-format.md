# Workshop runbook format

This document defines the presentation format for attendee-facing workshop
runbooks. It applies to new runbooks and to deliberately scoped format
migrations; it does not require unrelated runbooks to be reformatted.

The format is designed for agent-assisted software delivery. A runbook should
teach attendees to turn a task into evidence and then make a human decision; it
must not be a disconnected tour of commands, prompts, or agent features.

## Required structure

Use these sections in this order unless a short introduction is needed before
the disclaimer.

1. **Title and overview**

   State the workshop outcome, the repository or task in scope, and the role
   of the coding agent. Do not overstate what automation can establish.

2. **Disclaimer and workshop scope**

   State that the material is educational. Make clear which systems a command
   can change, including local files, Git branches, GitHub repositories, pull
   requests, and accounts. Distinguish facilitator-only operations from
   attendee operations.

3. **Learning objectives**

   Give three to five observable outcomes. Prefer verbs such as *establish*,
   *inspect*, *assess*, *verify*, *compare*, and *review* over *understand*.

4. **Prerequisites and environment**

   Record the required Java version, shell and operating-system assumptions,
   Git, GitHub CLI, coding-agent tooling, authentication, and any required
   repository permissions. State whether an operation is safe on an attendee's
   local machine and fork.

5. **Repository and workflow design**

   Explain only the repository context needed to perform the exercise. Name:

   - the task or decision being addressed;
   - the agent inputs, such as task briefs, repository instructions, and
     skills;
   - the evidence expected from the workflow, such as a diff, test result,
     review, or agent summary;
   - the human decision that evidence informs; and
   - the scope and limits of the workflow.

6. **Guided walkthrough**

   Present a numbered sequence of steps. Before every command, explain its
   purpose, the evidence it should produce, and the condition under which an
   attendee should stop or seek help. Include a baseline before an agent makes
   changes, and include cleanup for artefacts created by the walkthrough.

   Group longer walkthroughs into short H2 sections that follow the lifecycle:
   prepare the repository, establish a baseline, inspect the codebase, assess
   the task, make or review a change, and evaluate the evidence.

7. **Interpretation and caveats**

   Explain what the evidence supports, what it cannot prove, and the next human
   action. A passing automated check or plausible agent response is evidence,
   not approval.

8. **References**

   Link to the authoritative documentation for required tools and any task
   briefs or external resources used by the exercise.

Do not add an empty section merely to match this template. A short workshop may
combine the repository explanation and workflow design; a longer workshop may
use one H2 subsection for each major phase of the guided walkthrough.

## Authoring rules

- Write around **task -> agent instruction -> evidence -> human decision**, not
  around a product or tool feature tour.
- Use Sociable Weaver `Heading`, `Markdown`, `Prerequisite`, `Command`, and
  `DisplayFile` entries to express the guide. Use `DisplayFile` only for files
  needed to understand or assess the current step.
- Make each command safe to rerun where practical. Clearly label commands that
  delete local content, change the active GitHub account, create a remote
  repository, open a pull request, merge a pull request, or otherwise have
  external side effects.
- Put optional reset or repeat-workshop procedures in an explicitly labelled
  appendix; do not make destructive cleanup part of the normal attendee path.
- Keep claims and commands consistent. In particular, a local-only workshop
  must not instruct attendees to create or merge pull requests.
- Describe expected output precisely. Never leave `TODO` text in generated,
  attendee-facing material.
- Keep reusable prompt catalogues, advanced variants, and conceptual diagrams
  in an appendix unless attendees actively use them in the core walkthrough.

## Sociable Weaver skeleton

```yaml
entries:
  - type: Heading
    level: H1
    title: <Workshop title>

  - type: Markdown
    contents: |
      <Workshop outcome and task in scope.>


  - type: Markdown
    contents: |
      ---

  - type: Heading
    level: H2
    title: Disclaimer

  - type: Markdown
    contents: |
      The examples provided in this repository are for **educational purposes only**
      and are intended to be used **exclusively within this workshop**. While every
      effort has been made to ensure accuracy and reliability, these examples are
      provided **“as is”**, without any warranties, express or implied.

      By using these examples, you acknowledge that you do so **at your own risk**.
      The authors and contributors shall **not be held liable** for any direct,
      indirect, incidental, or consequential damages resulting from the use, misuse,
      or inability to use these examples.

      It is the responsibility of the user to **review, test, and validate** any code
      before applying it in a production or commercial environment.

  - type: Heading
    level: H3
    title: Performance Disclaimer

  - type: Markdown
    contents: |
      The performance values shown in this workshop are for reference only and should
      not be treated as absolute. Results can vary depending on hardware, system
      configuration, runtime environment, and other factors. Readers are encouraged to
      conduct their own tests under controlled conditions to obtain accurate
      measurements relevant to their specific use case.

  - type: Markdown
    contents: |
      ---

  - type: Heading
    level: H2
    title: Learning objectives

  - type: Markdown
    contents: |
      By the end of this workshop, attendees can:

      - <observable outcome>;
      - <observable outcome>; and
      - <observable outcome>.

  - type: Heading
    level: H2
    title: Prerequisites and environment

  - type: Prerequisite
    checks:
      - kind: java
        name: Java 25+
        version: 25+
        contents: |
          <Environment guidance>
        help: <Actionable remediation>

  - type: Heading
    level: H2
    title: Repository and workflow design

  - type: Markdown
    contents: |
      **Task:** <task or decision>

      **Agent inputs:** <instructions, briefs, and skills>

      **Evidence:** <diff, verification, review, and agent output>

      **Human decision:** <decision informed by the evidence>

      **Limits:** <what this workflow cannot prove>

  - type: Heading
    level: H2
    title: Guided walkthrough

  - type: Markdown
    contents: |
      1. Establish a baseline. This confirms the repository is healthy before
         an agent changes it. Stop and resolve pre-existing failures first.

  - type: Command
    commands: |
      <baseline verification command>
    indent: 3

  - type: Heading
    level: H2
    title: Interpretation and caveats

  - type: Markdown
    contents: |
      <What the evidence supports, does not prove, and the next human action.>

  - type: Heading
    level: H2
    title: References

  - type: Markdown
    contents: |
      - <authoritative reference>
```
