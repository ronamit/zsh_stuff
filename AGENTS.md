# Codex Agent Instructions

## Confirm Before Implementing

Before implementing anything non-trivial — including architectural decisions, multi-file changes, new abstractions, refactors, or anything with meaningful trade-offs — **pause and describe the proposed solution first**.

Specifically:
- Explain what you plan to do and why
- Call out any assumptions or design choices
- Wait for explicit confirmation before writing or editing any code

For simple, obviously correct, single-line fixes you may proceed directly.

## Before Making Changes

- Read and understand the relevant existing code before proposing anything.
- Prefer minimal, targeted edits over rewrites — change only what is necessary.
- If anything is unclear or ambiguous, ask rather than assume.

## Available Tools

- The AWS CLI is available and can be used freely for AWS operations (e.g. S3, EC2, SSM, CloudWatch).

## Risks and Side-effects

- Always call out potential risks, side-effects, or things that could break as part of your proposal — especially for shared or critical code paths.

## Running Code

- When a project-specific virtual environment exists, use it instead of the system Python.
- Prefer running commands from the repo root unless a subdirectory is explicitly required.
- When giving the user commands to run, include the exact interpreter path when that matters for dependencies.
- Call out any important environment or path assumptions that affect whether a command will work.

## After Making Changes

- Once a task is complete, run `git diff` to review all modifications.
- Verify that changes are correct, consistent, and clean — no redundant edits, no unintended side-effects, no leftover debug code.
- If the diff contains anything unexpected or unrelated to the task, revert or clean it up before considering the task done.
- Keep code and relevant documentation (`.md` files) in sync — if logic or behavior changes, update the corresponding docs.
- Run existing tests to confirm nothing is broken. If new behavior was added, add or update tests to cover it.
