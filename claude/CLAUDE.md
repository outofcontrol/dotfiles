## How to work with me

Do not tell me I am right all the time. Be critical. We're equals.

Answer succinctly. Skip preamble, recaps, and narration of what you're about to
do. Give the answer, and expand only when I ask for detail.

Don't overuse emoji.

## Filesystem scope (absolute)

Scope searches to the project working directory or a subdirectory of it. Do not
widen a search to other directories without permission.

Never leave a long-running search in the background.

## Writing

Never use dashes (— or -) as punctuation in documentation or README files.
Rephrase sentences using periods, commas, or parentheses instead.

### Infrastructure

For hosting, server, DNS or migration requests involving DigitalOcean (DO),
Forge, Laravel Cloud or Openprovider, read ~/.agents/skills/spatie-ops/SKILL.md
first. It locates private authentication and the appropriate provider or
migration skill. This includes ordinary requests such as moving a site to Cloud,
checking a droplet, changing DNS or inspecting Cloud performance.

## No filler text

Technical writing carries facts only. Cut any clause that advises, reassures, or
restates a consequence the reader can infer. Examples of what to remove: "so run
it deliberately", "is useful as a pre-flight check", "for a safe first run", "so
validation passes as soon as the token matches", "be careful when", "make sure
to", "it is worth noting", "simply", "just", "exactly", "of course".

Write instructions as imperatives. "Run `lint:all` after editing any config
file", not "`lint:all` is useful after editing a config file".

State the fact and stop. A sentence ending in ", so <consequence>" is usually
two facts where one will do.

This applies to documentation, comments, commit messages, and chat responses.
Grep alone misses these. Re-read the prose end to end before calling a doc
finished.

## Coding Standards

When working with Laravel/PHP projects, always use the
php-guidelines-from-spatie skill

## Using GitHub

For questions about GitHub, use the gh tool. Never mention Claude Code in PR
descriptions, PR comments, or issue comments Do not include a "Test plan"
section in PR descriptions

## Using phpunit or pest

If phpunit or pest is setup in a project, always run tests before git add

## Autonomy

Proceed without asking clarifying questions. Make reasonable decisions and
document them in commit messages. Only stop for hard blockers that genuinely
cannot be resolved without input (missing credentials, ambiguous destructive
actions with no safe default).
