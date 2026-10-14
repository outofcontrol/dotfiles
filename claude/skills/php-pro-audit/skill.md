---
name: php-pro-audit
description: >
  Production-grade PHP 8.3+ coding standards synthesised from real project history
  and PHP The Right Way (phptherightway.com). Covers PSR-12/Spatie style, security-first
  patterns, exception handling, dependency injection, type safety, SOLID principles,
  UTF-8 handling, database safety, and commit discipline. Use whenever writing or
  reviewing PHP in any production or security-sensitive codebase. Supersedes and
  subsumes php-guidelines-from-spatie, php-security-patterns, phpunit-best-practices,
  and iso27001-annex-a-mapping for PHP-centric security tools.
license: MIT
metadata:
  author: Out of Control Inc.
  tags: php, security, psr-12, spatie, quality, audit, phptherightway
---

# PHP Pro Audit Skill

This skill encodes hard lessons learned building a production PHP security tool from
scratch, extended with guidance from PHP The Right Way (phptherightway.com). Every
rule below was validated by real regressions, refactors, static analysis failures, or
community best practice. Apply it fully from the first line of a new file.

---

## 1. File Preamble (Non-Negotiable)

Every PHP file must open with:

```php
<?php

// SPDX-FileCopyrightText: <year> <Vendor Name>
// SPDX-License-Identifier: MIT

declare(strict_types=1);

namespace Vendor\Package\SubNamespace;
```

- `declare(strict_types=1)` must appear before any code. No exceptions.
- SPDX header must be present. Use `#` for shell/YAML, HTML comment for Markdown,
  `.license` sidecar for JSON files.
- Imports follow the namespace line, sorted: stdlib, then third-party, then internal.
  Never use a fully-qualified name inline when it can be imported.

---

## 2. PSR-12 and Spatie Style

### Class structure order

1. Constants (`private` then `protected` then `public`)
2. Properties
3. Constructor
4. Abstract/interface-required methods
5. Public methods
6. Protected methods
7. Private methods

### Type declarations

- Use short nullable syntax: `?string` not `string|null`.
- Return `void` explicitly when a method returns nothing.
- Typed properties always. No `@var` docblock as a substitute.
- Constructor property promotion when all properties can be promoted at once.

```php
// Good
public function __construct(
    private readonly LoggerInterface $logger,
    private readonly Config $config,
) {}

// Bad — mixed promoted and non-promoted in same constructor is noise
```

### No else after early return or continue

```php
// Bad
if ($condition) {
    return $value;
} else {
    doOtherThing();
}

// Good
if ($condition) {
    return $value;
}
doOtherThing();
```

### Use match() for multi-branch dispatch

```php
// Bad
if ($severity === 'critical') {
    $level = 0;
} elseif ($severity === 'high') {
    $level = 1;
} else {
    $level = 2;
}

// Good
$level = match ($severity) {
    'critical' => 0,
    'high'     => 1,
    default    => 2,
};
```

### Split compound conditions

```php
// Bad — PHPStan/Psalm lose type narrowing across &&
if ($response !== null && $response->getStatusCode() === 200 && $body !== '') {

// Good
if ($response === null) {
    return;
}
if ($response->getStatusCode() !== 200) {
    return;
}
if ($body === '') {
    return;
}
```

### String interpolation over concatenation

```php
// Bad
$url = '/orgs/' . $org . '/repos?page=' . $page;

// Good
$url = "/orgs/{$org}/repos?page={$page}";
```

### Variable naming

- No single-letter variables except loop indices. Rename $e -> $exception,
  $r -> $result, $m -> $member, $l -> $login.
- Lambda parameters must be descriptive:

```php
// Bad
array_filter($results, fn($r) => $r->isPassed());

// Good
array_filter($results, fn(CheckResult $result) => $result->isPassed());
```

---

## 3. Docblocks

Class-level and file-level docblocks are required on every file and class. Method
docblocks are required on every public method with:
- `@param` for every parameter (with generic type if array/iterable)
- `@return` (even if void)
- `@throws` for every exception that can propagate
- `@psalm-*` annotations where they add taint or type information beyond native types

```php
/**
 * @package Vendor\Package\SubNamespace
 *
 * One-line class summary. Second paragraph for non-obvious design decisions only.
 */
final class MyCheck implements CheckInterface
{
    /**
     * @param CheckContext $ctx  Audit run context.
     * @param string       $org  GitHub organisation slug.
     *
     * @return array<int, CheckResult>
     *
     * @throws RuntimeException When the API response cannot be decoded.
     */
    public function run(CheckContext $ctx, string $org): array
    {
```

- Do not repeat the method name in the docblock ("Gets the user" for getUser()).
- Do not document what the method does when it is self-evident from the signature.
- Inline comments are forbidden. If the WHY requires explanation, use a docblock
  on the method.

---

## 4. Exception Handling

### Never swallow exceptions silently

```php
// Bad — swallows the error, returns null, produces false-negative audit results
try {
    $data = $this->apiCall();
} catch (\Throwable $e) {
    return null;
}

// Good — log at warning level, return a typed Skip result
try {
    $data = $this->apiCall();
} catch (GithubRuntimeException $exception) {
    $this->logger->warning('API call failed.', [
        'context'   => $someContext,
        'exception' => $exception->getMessage(),
    ]);
    return [CheckResult::skip($this->id(), 'API unavailable.')];
}
```

### Always narrow catch types

Bare `catch (\Throwable)` is only acceptable when a class genuinely cannot predict
what a third-party library throws (e.g., GraphQL client over raw Guzzle). Even then,
log and return Skip — never rethrow as a generic error that hides the origin.

```php
// Acceptable for libraries with no typed exception hierarchy
try {
    $result = $ctx->graphql->query($gql);
} catch (\Throwable $exception) {
    $this->logger->warning('GraphQL query failed.', ['exception' => $exception->getMessage()]);
    return [CheckResult::skip($this->id(), 'GraphQL unavailable.')];
}
```

### GithubExceptionThrower pattern

The `knplabs/github-api` library converts 4xx/5xx responses to
`Github\Exception\RuntimeException` before the caller can inspect the status code.
Every `getHttpClient()->get()` call must be wrapped:

```php
use Github\Exception\RuntimeException as GithubRuntimeException;

try {
    $response = $ctx->client->getHttpClient()->get("/repos/{$org}/{$repo}/branches");
} catch (GithubRuntimeException $exception) {
    // In a per-repo loop: continue
    // In a top-level org call: return skip
    // In a pagination loop: break
    continue;
}
```

Callers that iterate a paginated endpoint must place the try/catch inside the do/while
and break on exception, not outside.

---

## 5. JSON Decoding

All `json_decode` calls must pass `JSON_THROW_ON_ERROR`. Guard every response body
for empty string before calling `json_decode`. Do not let a 404/empty response
trigger a JsonException.

```php
$body = (string) $response->getBody();
if ($body === '') {
    break; // or continue, or return skip — never silently proceed
}

/** @var array<string, mixed> $data */
$data = json_decode($body, true, 512, JSON_THROW_ON_ERROR);
```

---

## 6. Filesystem Operations

Guard `file_put_contents`, `getcwd`, and all functions that can return false:

```php
// Bad
file_put_contents($path, $content);

// Good
if (file_put_contents($path, $content) === false) {
    throw new RuntimeException("Failed to write report to {$path}.");
}
```

```php
// Bad
$cwd = getcwd();
$relative = $cwd . '/' . $filename;

// Good
$cwd = getcwd();
if ($cwd === false) {
    throw new RuntimeException('Cannot determine working directory.');
}
$relative = $cwd . '/' . $filename;
```

---

## 7. Dependency Injection

### Constructor injection everywhere

No `new Collaborator()` inside business logic. Every collaborator is injected through
the constructor. This makes unit testing possible without process-level fakes.

```php
// Bad — AuditCommand creates its own dependencies
public function execute(): int
{
    $runner = new CheckRunner(new CheckRegistry());
    ...
}

// Good — all dependencies injected; test can substitute fakes
public function __construct(
    private readonly CheckRunnerInterface $runner,
    private readonly ReporterInterface $reporter,
    private readonly LoggerInterface $logger,
) {}
```

### PSR-3 logger as default

Every class that does I/O or calls external services accepts `?LoggerInterface`
and defaults to `NullLogger`. This avoids coupling to a container in standalone or
test contexts:

```php
public function __construct(?LoggerInterface $logger = null)
{
    $this->logger = $logger ?? new NullLogger();
}
```

---

## 8. Value Objects over Nullable Returns

Nullable returns from methods that can fail in multiple ways hide information.
Use value objects with state enums instead:

```php
// Bad — null could mean "not found", "error", or "not applicable"
protected function getBranchProtection(string $repo): ?array

// Good — caller handles all three states explicitly
protected function getBranchProtection(string $repo): ProtectionResult
// ProtectionResult::protected(array $data)
// ProtectionResult::unprotected()
// ProtectionResult::error(string $reason)

// Callers:
$result = $this->getBranchProtection($repo);
if ($result->state === ProtectionState::Error) {
    $this->logger->warning($result->reason);
    return [CheckResult::skip(...)];
}
if ($result->state === ProtectionState::Unprotected) {
    return [CheckResult::fail(...)];
}
$data = $result->data;
```

---

## 9. Centralised Path Resolution

Never use `dirname(__DIR__)` chains inline. Create a single `Paths` class that
owns all filesystem paths for the application:

```php
final class Paths
{
    public static function root(): string
    {
        return dirname(__DIR__, 2);
    }

    public static function vendor(): string
    {
        return self::root() . '/vendor/autoload.php';
    }
}
```

---

## 10. Security Checklist (run before every commit)

- [ ] No token, secret, or credential written to any log line, exception message,
      report file, or error output.
- [ ] `json_decode` uses `JSON_THROW_ON_ERROR` everywhere.
- [ ] TLS verification is on for every HTTP client. No `verify => false`.
- [ ] No `exec`, `system`, `shell_exec`, `passthru`, or `proc_open` in new code.
      If unavoidable, flag for explicit review.
- [ ] No path constructed from user or API input without validation.
- [ ] Every exception catch logs context and returns a typed Skip/Error result.
      No silent swallowing.
- [ ] Output files never contain JWT fragments, webhook secrets, or OAuth tokens
      extracted from API responses.
- [ ] `file_put_contents` return value is checked.
- [ ] Environment variable access uses validated helpers, not raw `$_ENV` reads.
- [ ] Psalm taint analysis passes on changed files (`composer psalm`).

---

## 11. HTTP Client Rules

- Connect timeout: 10 s; total timeout: 30 s (both env-configurable).
- Retry budget: hard cap of 5 retries per request.
- Max redirects: 5.
- TLS always on. User-Agent set to `vendor/package/<version>`.
- Proxy only when `HTTPS_PROXY` env var is set.
- Concurrency clamped at 20.
- Never log or surface the raw token in error paths.

---

## 12. Testing Standards

### No live network in tests

All tests use mocks, recorded fixtures, or fakes. Never require a real `GITHUB_TOKEN`
or live API endpoint. Tests must pass offline.

### Mock sequencing for paginated APIs

When mocking the `knplabs/github-api` HTTP client, mocks are consumed in order.
For paginated endpoints, queue one response per expected page plus an empty-body
terminator:

```php
// Queue: repos list -> dir listing -> file content -> empty terminator
$this->mockClient->addResponse($this->repoListResponse());
$this->mockClient->addResponse($this->dirListResponse());
$this->mockClient->addResponse($this->fileContentResponse($yaml));
$this->mockClient->addResponse($this->emptyResponse()); // terminates pagination
```

### GraphQL checks

`GraphQLClient` uses raw Guzzle internally, which the standard mock client cannot
intercept. For GraphQL-based checks, write exactly one test:

```php
public function testSkipsWhenGraphqlFails(): void
{
    // GraphQL always throws in integration test context
    $results = $this->check->run($this->ctx());
    $this->assertCount(1, $results);
    $this->assertSame(Status::Skip, $results[0]->status);
}
```

### PHPUnit conventions (from phpunit-best-practices skill)

- Test class names mirror production class names with `Test` suffix.
- One assertion concept per test method; multiple assertions for one scenario are fine.
- Use `@dataProvider` for input variation, not duplicated test methods.
- Never use `@covers` unless measuring coverage at method level; prefer class-level.
- `setUp()` builds the system under test; individual tests exercise one path.

---

## 13. Commit Discipline

- DCO sign-off (`git commit -s`) on every commit.
- Conventional commit prefix: `feat:`, `fix:`, `refactor:`, `chore:`, `build:`,
  `ci:`, `docs:`, `test:`, `perf:`. Scope matches namespace (`organization`,
  `member`, `actions`, `repository`).
- One logical change per commit. No "WIP" commits, no "fix typo" appended to a
  feature commit.
- The tree must be green (`composer test && composer stan && composer psalm &&
  composer cs-check && composer audit`) at every commit, not just at the end.
- Never write bogus intermediate code. If a feature requires five files, write all
  five in one commit with all tests passing. Do not commit "stub" classes that
  will fail static analysis or tests.

---

## 14. Static Analysis Gates

Run before every commit. All must pass:

| Tool | Command | Failure action |
|---|---|---|
| PHPUnit | `composer test` | Fix failing tests before committing |
| PHPStan | `composer stan` | Fix type errors; never use `@phpstan-ignore` without comment |
| Psalm | `composer psalm` | Fix taint and type errors; taint suppression requires justification |
| PHP-CS-Fixer | `composer cs-check` | Run `composer cs-fix` then review diff |
| Composer Audit | `composer audit` | Update or justify any vulnerable dependency |

PHPStan and Psalm must run at max level. Suppressions require an inline justification
comment (the one exception to the no-inline-comments rule).

---

## 15. ISO 27001 Alignment in Security Tools

When a check maps to an ISO 27001:2022 Annex A control, record the control reference
in the check ID and report output. Use the `iso27001-annex-a-mapping` skill to derive
the correct control number from a technical finding description. Example:

- Branch protection missing -> A.8.9 (Configuration management)
- 2FA not enforced -> A.5.17 (Authentication information)
- Stale admin accounts -> A.5.18 (Access rights)
- Webhook without TLS -> A.8.20 (Networks security)

Check IDs are stable across versions (e.g., `ORG-2FA-ENFORCED-001`). Renaming an ID
requires a `CHANGELOG.md` migration note and a `CHECKS.md` old-to-new mapping.

---

## 16. SOLID Principles (PHP The Right Way)

Apply all five principles. They are not optional architecture theory; violations cause
the concrete test-and-refactor pain this project experienced.

**Single Responsibility.** One class, one reason to change. A class that fetches data
from an API and formats a report will require two different kinds of edits. Split it.

**Open/Closed.** Type-hint against interfaces, not concrete classes. Extend by adding
new implementations, not by modifying existing ones.

```php
// Bad — forces modification every time a new adapter is needed
class Database {
    public function __construct() {
        $this->adapter = new MySqlAdapter();
    }
}

// Good — extend by providing a new AdapterInterface implementation
class Database {
    public function __construct(private readonly AdapterInterface $adapter) {}
}
```

**Liskov Substitution.** Any implementation of an interface must be substitutable for
any other implementation without callers caring. If a method signature in a subtype
narrows or widens a contract, it violates LSP.

**Interface Segregation.** Prefer small, concept-specific interfaces over monolithic
ones. A `CheckInterface` with `run()` is better than a `CheckAndReportInterface` with
`run()`, `format()`, and `persist()`.

**Dependency Inversion.** Depend on abstractions (interfaces), not concretions
(classes). This is the formal grounding for section 7 (constructor DI). High-level
policy should never import low-level detail.

---

## 17. UTF-8 Handling

All three layers must be explicit. Defaults vary by platform and will silently corrupt
data if not locked down.

**PHP layer:**

```php
mb_internal_encoding('UTF-8');
ini_set('default_charset', 'utf-8');
mb_http_output('UTF-8');

// Use mb_* equivalents everywhere
$len   = mb_strlen($string);           // not strlen()
$sub   = mb_substr($string, 0, 15);    // not substr()
$pos   = mb_strpos($string, $needle);  // not strpos()

// Explicit encoding on functions that accept it
$safe = htmlentities($output, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
```

**Database layer:** Use `utf8mb4`, not `utf8` (MySQL's `utf8` is a 3-byte subset that
cannot store emoji or supplementary Unicode characters):

```php
$pdo = new PDO('mysql:host=...;dbname=...;charset=utf8mb4', $user, $pass);
```

**HTTP layer:**

```php
header('Content-Type: text/html; charset=UTF-8');
// And in HTML: <meta charset="UTF-8">
```

---

## 18. Database Safety

### Use PDO with prepared statements always

Never concatenate user input into a query string. There are no exceptions.

```php
// Never — SQL injection
$pdo->query("SELECT name FROM users WHERE id = " . $_GET['id']);

// Always — parameterised query
$stmt = $pdo->prepare('SELECT name FROM users WHERE id = :id');
$id   = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_NUMBER_INT);
$stmt->bindParam(':id', $id, PDO::PARAM_INT);
$stmt->execute();
$row = $stmt->fetch(PDO::FETCH_ASSOC);
```

### Separate model from view

Database queries belong in model/repository classes, not in template files.

```php
// Model
final class UserRepository {
    public function __construct(private readonly PDO $db) {}

    /** @return array<int, array{name: string, email: string}> */
    public function findAll(): array
    {
        return $this->db->query('SELECT name, email FROM users')->fetchAll(PDO::FETCH_ASSOC);
    }
}

// View receives plain data — no PDO object in scope
<?php foreach ($users as $user): ?>
    <li><?= htmlspecialchars($user['name'], ENT_QUOTES, 'UTF-8') ?></li>
<?php endforeach ?>
```

### Never use the old mysql_* extension

It was removed in PHP 7.0. If found in a codebase, it is a critical finding.

---

## 19. Date and Time

- Use `DateTimeImmutable` over `DateTime`. Immutable objects cannot be accidentally
  mutated by a callee.
- Parse from user input with `DateTimeImmutable::createFromFormat()` and validate the
  result — it returns `false` on failure.
- Use `DateInterval` and `diff()` for arithmetic; never subtract Unix timestamps and
  assume 86400 seconds per day (daylight saving time breaks this).
- For recurring events, use `DatePeriod`.
- Import `DateTimeImmutable` at the top of the file; never use it inline as
  `\DateTimeImmutable`.

```php
use DateTimeImmutable;
use DateInterval;

$date = DateTimeImmutable::createFromFormat('Y-m-d', $raw);
if ($date === false) {
    throw new \InvalidArgumentException("Invalid date: {$raw}");
}

$interval = new DateInterval('P30D');
$later    = $date->add($interval);
```

---

## 20. Internationalisation (i18n) and Localisation (l10n)

Design for i18n from the start; retrofitting is expensive.

- Keep all user-facing strings out of logic classes. Use message keys or Gettext.
- Use `gettext()` / `_()` for simple strings and `ngettext()` for plural-aware strings.
  Plural rules vary per language; never hardcode English logic.
- Compile `.po` files to `.mo` binary files for runtime.
- Use `utf8mb4` in the database and `UTF-8` in all Gettext domain codeset calls.
- For this project: Canadian English (`en-CA`) is the only supported locale in v1.
  The `--locale` flag is reserved for future use.

```php
bindtextdomain('domain', '../locales');
bind_textdomain_codeset('domain', 'UTF-8');
textdomain('domain');

echo _('Branch protection is not enabled.');
echo ngettext('%d finding', '%d findings', $count);
```

---

## 21. Security Input Handling (PHP The Right Way)

All external input is untrusted: `$_GET`, `$_POST`, `$_COOKIE`, `$_SERVER`,
file uploads, environment variables, API responses, and deserialized data.

### Validate at boundaries, trust internally

Validate and normalise at the point of entry. Once inside the application boundary,
trust the typed value.

```php
$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if ($id === false || $id === null) {
    throw new \InvalidArgumentException('id must be a positive integer.');
}
```

### Output escaping

Always escape for the correct context:

```php
// HTML context
echo htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');

// URL context
echo urlencode($value);

// JSON context — json_encode escapes by default, but be explicit
echo json_encode($value, JSON_HEX_TAG | JSON_HEX_AMP | JSON_THROW_ON_ERROR);
```

### Password hashing

Use `password_hash()` with `PASSWORD_BCRYPT` or `PASSWORD_ARGON2ID`. Never MD5,
SHA-1, or any raw hash function. Never store plaintext.

```php
$hash = password_hash($plaintext, PASSWORD_ARGON2ID);
if (!password_verify($input, $hash)) {
    throw new AuthenticationException();
}
```

### Configuration files

Keep `.env`, credentials, and config files outside the web document root. The web
server must never be able to serve them directly.

### Error reporting in production

Never expose stack traces, variable dumps, or detailed error messages to end users.
Log them server-side at `error` level; show a generic message to the user.

```php
// Development
ini_set('display_errors', '1');
error_reporting(E_ALL);

// Production — errors go to logs, not to the browser
ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);
```

---

## 22. Namespaces and Autoloading (PHP The Right Way)

- Every class lives in a namespace matching its file path per PSR-4.
- Register via Composer's `autoload` key in `composer.json`; never write manual
  `require` or `include` calls for project classes.
- Never use global namespace classes without an `use` import statement.

```json
{
    "autoload": {
        "psr-4": {
            "Vendor\\Package\\": "src/"
        }
    }
}
```

---

## 23. Opcode and Object Caching

- Enable OPcache in production (`opcache.enable=1`). It caches compiled bytecode and
  is the single highest-impact performance change for any PHP application.
- For object/result caching, use PSR-6 (`CacheItemPoolInterface`) or PSR-16
  (`CacheInterface`) so the cache backend is swappable without code changes.
- Never cache values that contain secrets, tokens, or PII without explicit justification
  and TTL that matches the secret rotation policy.

---

## 24. CLI Script Rules (PHP The Right Way)

- CLI scripts must never be placed in the public web root.
- Exit non-zero to signal failure; exit zero only on genuine success.
- Use `$argc` / `$argv` or a console framework (Symfony Console) for argument parsing.
  Never parse `$argv` manually in production code.
- This project's exit code contract is defined in CLAUDE.md and must be followed
  exactly (0 = clean, 1 = findings, 2 = degraded, 64/69/70/77 = errors).

---

## 25. Project Directory Structure (PHP The Right Way)

Follow the Standard PHP Package Skeleton (`php-pds/skeleton`):

```
project/
├─ src/          Application source code
├─ tests/        Test suites
├─ docs/         Documentation
├─ vendor/       Composer-managed dependencies (committed for applications)
└─ public/       Web document root only — nothing sensitive here
```

Configuration, `.env`, and credential files live outside `public/`. Scripts that
must not be web-accessible live in `src/` or `bin/`, not in `public/`.
