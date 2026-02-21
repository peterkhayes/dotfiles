# Security

Follow these guidelines UNLESS operating in yolo/dangerous mode.

## No permissions to run interpreters directly

I will not give permission for arbitrary code execution commands like `python3` or `node`. If you need to write a script, I'll review it. Once I approve a script, you can make it executable and run it directly as an executable. You cannot run interpreters with arbitrary code (e.g. `python3 script.py` or `node script.js`) — only approved executable scripts.

# Git

## Git Commands

- The default branch is defined per-repo as `default-branch.name`
- Use `git fresh [branch]` to move to a branch and sync it with remote. Default branch if not specified
- Use `git sync [branch]` (optionally `-i`) to keep a branch up to date with a base branch. Default branch if not specified

## Guidelines

- Start new features with `git fresh`, then create a new branch for the work
- Run `git sync` if I say to "sync" a branch
- Split branches with larger changes into multiple commits
  - The goal is readability; important or complicated changes should be in small commits, while rote work can be in larger commits
  - Individual commits do not need to compile or pass tests, only the branch
  - Rewriting history to keep branches clean is encouraged

# Code Quality

## The future intern test

Imagine your code will be modified or built upon in the future by someone with no context. Will it still work?

Factor code to be resiliant to this:

- Important logic should be factored into helpers, not duplicated (DRY)
- Repeated values should be extracted into constants
- Add exhaustiveness checks to switch/match statements and similar
- Guardrails should be added for misuse of the system
- Write tests where appropriate. Keep the number of tests small, and focused on the public API

## Ergonomics

If writing library code, make it easy for callers to work with:

- Ensure names are consistent
- Use named arguments or options objects for functions with multiple arguments
- Add docstring comments

## Refactoring

After nontrivial changes, briefly review your work for quality and refactor as needed.

## Functional Programming

Prefer declarative/functional programming patterns, at least within the idioms of the language:

- Separate out the pure parts of a function from the logical parts
- Fetch or compute data lazily when possible
- Avoid adding new shared mutable state
