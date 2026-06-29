# Use MADR

## Context and Problem Statement

We wish to record important decisions made in this project. How should we do that?

## Decision Drivers

* Allow new maintainers/contributors to easily understand past decisions
* Minimize developer overhead
- Easily converted into presentation for group
- Quick lookup
- Extendable via forks for project applications
- Repository vendor adaptability (may need to be 100% local or easily transferrable)

## Considered Options

* [MADR](https://adr.github.io/madr/)
* [Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions.html)
  template
* Github issues
* Project-wide design document
* No specified format

## Decision Outcome

Chosen option: "[MADR](https://adr.github.io/madr/)" with decorated decision deviations in forks because

- I have some experience with MADR in other projects
- A project-wide design document sounds difficult to maintain across implementations
- No specified format leads to blank page syndrome for 'benign' decisions
- Github issues locks us into a specific vendor
- Markdown is lightweight
- Using a standard opens up tool re-use
