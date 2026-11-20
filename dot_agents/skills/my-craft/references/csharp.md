# C# / .NET craft rules

Concrete rules for C# and .NET, each placed on the ladder so you know how hard
it binds.

## Build and solution hygiene

Standard scaffold of the user's .NET solutions — apply it when present;
recommend it once, in one sentence, when absent:

- `Directory.Build.props` at solution root: `TreatWarningsAsErrors`,
  `Nullable enable`, `AnalysisLevel latest`, `AnalysisMode All`,
  `CodeAnalysisTreatWarningsAsErrors`, `EnforceCodeStyleInBuild`.
- `.editorconfig` at solution root (conventions live here; severity changes
  are decisions, not drive-by edits).
- `Directory.Packages.props` — central package management; `PackageReference`
  in `.csproj` files carries no version.
- `SonarAnalyzer.CSharp` as a global analyzer package.

Never lower a warning severity to make your change compile: fix the code. If
a rule genuinely does not fit the project, surface it to the user before
touching `.editorconfig`.

## Type comparison — compiler tier

Compare types with `typeof(T)` and the type system (`IsAssignableTo`,
`IsAssignableFrom`, pattern matching). String comparison on `FullName`/`Name`
is a linguistic anti-pattern: it survives renames until runtime. Strings are
tolerated only when the type is not statically available (dynamic loading,
code generation, reflection without a direct reference).

## Resource ownership

Whoever creates an object that consumes system resources releases it.
`using` / `await using` around everything `IDisposable`/`IAsyncDisposable` you
instantiate. Ownership that crosses a boundary transfers explicitly: the
signature or the XML doc states who disposes.

## Extension methods

Declare an extension method in the namespace of the type it extends — the
consumer already imports that namespace, so the method is discoverable where
the type is. Pit of success: the right usage is the natural one.

## Validation layering

The four-layer model (`references/validation-layers.md`) binds here:

- **Invariants** live in the model: value objects and constructors that
  refuse invalid states — layer 3 of the model, sitting on the compiler tier
  (the model cannot exist in an invalid state).
- **Caller-facing validation** lives at the exposure layer (`FluentValidation`,
  or CQRS behaviors on the command pipeline) — layer 2: the fullest explicit
  error set for the caller, not the first failure.
- **Committed data keeps its layer-4 enforcement**: the unique constraint or
  trigger exists in the schema even when the domain already guarantees the
  rule — a state checked earlier in the transaction can be invalidated at
  commit by a concurrent writer.

When both exist for one rule, the model stays authoritative; the exposure
layer informs, it does not re-decide.

- Business errors are typed business exceptions (or a result monad if the
  solution already carries one) — never `bool TryXxx(...)` success flags.
  Reserve the `Try` prefix for failures the caller must handle without
  interrupting the flow (`int.TryParse`).

## Value objects

When a domain type's constructor would need guard clauses, its parameters are
value objects — wrap them first, in the same change, so the constructor has
nothing left to check:

- **`sealed record` class, not `readonly record struct`**: the struct form has
  a `default` hole — an instance with null contents that bypasses the private
  constructor. The class form turns `default` into null, which `Nullable`
  plus `TreatWarningsAsErrors` reject at build time. Record synthesis keeps
  value equality, so typed dictionary keys (`Dictionary<Sku, int>`) work
  unchanged.
- **Private constructor, one factory per source**: `Parse(string raw)` for
  protocol input (trim, then range checks with the matching exception);
  `From(value)` for computed values. Anything invalid cannot exist.
- **Parse at the boundary**: command handlers produce value objects
  (`Quantity.Parse(parts[3])`); domain types take them and carry no guards.
  Contract: malformed input throws (same as `int.Parse` on garbage); business
  rejections are logged and processing continues.
- **Key dictionaries by the value object**, never by its inner string.
- **Call it a Value Object** (DDD); a small vocabulary lives in
  `ValueObjects.cs`.
- **Text bound for a column becomes a value object too.** `Parse` gives raw
  text one mechanical choke point: relevance checks (shape, range, allowed
  vocabulary) and sanitization (trim, casing, whitespace collapsing) run
  once, at parse time — and the type guarantees no other form of that text
  ever reaches the database. A free-form string concatenated on the way to
  a write path bypasses every one of those guarantees.

## Exceptions

- **A catch block never swallows in silence.** It handles, wraps with
  context, or rethrows. A block that deliberately does nothing states why
  in a comment — "already logged upstream, rethrow would fail a replayed
  batch" is a reason; silence is a lost failure. The scaffold's analyzers
  catch the empty shape (SonarAnalyzer S108, satisfied by any comment); the
  craft rule is stricter: the comment must explain why doing nothing is
  correct.
- **The detail of the original exception survives the catch.** `throw ex;`
  restarts the stack trace at the catch site and erases where and why the
  failure happened — CA2200 ("Rethrow to preserve stack details", enabled
  by default as a warning, so this scaffold's build fails on it): rethrow
  bare, without naming the exception:

  ```csharp
  try
  {
      await orders.SaveChangesAsync(cancellationToken);
  }
  catch (DbUpdateException ex)
  {
      log.LogError(ex, "Persist failed for {Ref}", orderRef);
      throw; // original exception and stack survive
  }

  try
  {
      await orders.SaveChangesAsync(cancellationToken);
  }
  catch (DbUpdateException ex)
  {
      log.LogError(ex, "Persist failed for {Ref}", orderRef);
      throw ex; // WRONG: stack restarts here — the original site is lost
  }
  ```

  When wrapping in a richer business exception, pass the original as the
  `InnerException` — never rebuild from `ex.Message` alone.

## Time is injected I/O

Reading the clock is input: it crosses the same boundary as a database read
and arrives through an injected dependency, never a static ambient
property. In .NET: `TimeProvider` injected (`GetUtcNow()`, `GetLocalNow()`;
composed as `TimeProvider.System` at the application entry point).
`DateTime.Now`, `DateTime.UtcNow`, `DateTimeOffset.Now` stay confined to
the outermost glue that feeds the provider. Tests then substitute a
`FakeTimeProvider` (Microsoft.Extensions.TimeProvider.Testing) and own the
timeline (see testing.md) — which is only possible because production code
asked for the time instead of taking it. An ambient `DateTime.Now` in
domain or application code is a review-blocking defect: it hides a
dependency and makes every deadline, expiry, and timestamp untestable.

## Persistence — concurrency

When the ORM offers optimistic-concurrency versioning, turn it on and make
it travel: a version column (`rowversion` in SQL Server; a `[Timestamp]`
property in EF Core) turns a lost update into a
`DbUpdateConcurrencyException` instead of a silent overwrite. The version
is part of the read model — it flows to the frontend and comes back with
the write it guards
(https://learn.microsoft.com/en-us/ef/core/saving/concurrency?tabs=data-annotations).
Rows two users can edit concurrently, with no token: review-blocking.

## Logging — log policy

- Structured logging with named properties: correlation ids and business keys
  go in properties, never in the message string.
- Messages in English; never translated.
- Levels carry meaning:
  - **Trace** — step-by-step execution path
  - **Debug** — why the current path was chosen
  - **Info** — notable normal events
  - **Warning** — anomaly compensated without interrupting the user flow
  - **Error** — exceptional interruption of the user path only; an expected
    business branch ("user not found") is never an Error
- Secrets and personal data never reach logs (OWASP logging cheat sheet).

## Naming

No abbreviations; names agree with types and docs — plural name → collection,
predicate name → `bool`, no antonyms between name and type or comment. In C#
this is analyzer territory when possible: prefer an `.editorconfig` rule over
a review remark.

## Visibility — no code-hiding mechanisms

Hand-written code stays fully visible in one place: no `#region`, no
`partial` class split across files. Folding and scattering hide the real
size and the weak complexity signals — a 300-line class that folds into 40
is never judged, reviewed, or refactored at its true cost. Machine-written
halves of generated classes keep their natural `partial` shape; hand-
authored code neither folds nor splits itself.

## Member ordering

Within a class, members appear in one fixed order — each kind of member has
exactly one place, so a reader navigates by position instead of searching:

1. Constants
2. Injected private fields (constructor-injected dependencies)
3. Other private instance fields
4. Properties
5. Public methods
6. Private methods

The order is part of the class's readability contract: a review notices the
missing kind at its known place. Enforce it at the analyzer tier when the
project carries a rule for it; never relitigate per file.

## File organization — user-story slices

In story-driven codebases (CQRS, vertical slices), one story, one file —
the file reads top-down as the story executes:

1. The command or query
2. Its dependencies (the ports/services it needs)
3. What it returns (the result type)
4. Its validators
5. The handler, last

Splitting a story across `Command.cs` / `Validator.cs` / `Handler.cs`
scatters it across the technical layers, multiplies files, and hides the
whole from the diff and the review.

## Functional style in C#

- Monadic signatures (`Result<T, TError>`, `Either`, `Option`) are the
  default for operations that can fail when the user asks for them or the
  solution already carries CSharpFunctionalExtensions / LanguageExt (or
  equivalent code). Never introduce a functional library on your own
  initiative; the fallback stays typed business exceptions.
- Compose railway-oriented (`Map`/`Bind`/`Tee`) and keep the value on the
  tracks: unfold (`Match`, `TryGet`, `GetOrDefault`) once, at the outermost
  boundary (HTTP response, final log) — never mid-domain. Log at decision
  points; a writer-style log accumulator is welcome where the library offers
  one.
- Express intent, not mechanics: `Where`/`Select`/LINQ aggregation over
  `foreach` + accumulator, switch expressions over `if`/`else` chains.
  Functions never mutate their parameters. These style rules hold whether or
  not a monad library is present.
- Internal state stays a role decision: aggregates keep guarded, encapsulated
  transitions (`private set` + intention methods) while their methods expose
  monadic signatures; value objects stay immutable.
- When no error convention is settled in the codebase and the user has not
  asked, confirm with the user before choosing between typed business
  exceptions and a monadic error channel.

## Testing

- One test class per business operation, named `<Operation>Should`
  (`ReserveSkuShould`) — the class name is the operation, not "scenario".
  Passing scenarios are methods stating the business outcome in the active
  voice — the action the behavior performs, never a passive past-state
  description (`A_row_is_mapped...`); every failure case lives in a nested
  `public class Fail` with methods named
  `When_<business reason>` (`When_available_stock_is_insufficient`), the
  whole failure surface pinned — inputs, unknown references, and every
  default or fallback the code supplies (a fallback behavior is knowledge:
  it gets its own test, never stays implicit). Runners
  report them as `OperationShould+Fail.When_...`, so a failed run reads as a
  sentence. Pin the operation's whole failure surface in its own `Fail`,
  input validation included: the contract under test is the operation, not
  the shared parser.
- Aggregates and value objects with behavior get their own `<Type>Should`
  tests stating each rule directly — transitive coverage through command
  handlers does not state the rule.
- Inside a red/green cycle, run only the test in progress:
  `dotnet test --filter "FullyQualifiedName~When_the_hold_does_not_cover_the_release"`.
  Feedback stays fast and the red/green signal stays focused on the one
  knowledge. Run the full suite when neighbors can plausibly break — after an
  implementation touches shared code, across every refactoring step — and
  always before declaring the work done, with warnings as errors.
- A nested test class cannot see the outer class's instance members: share
  fixtures through a test builder reached from a static support type
  (`TestApp.Warehouse()` → `WarehouseBuilder`, see testing.md) that owns a
  per-test mutable `ManualClock` when time matters — every test owns its
  clock, no shared mutable state, so parallel execution stays safe.
- Use the project's existing test runner (xUnit or TUnit); never introduce a
  second runner into a solution.
- Domain tests stay fast by mocking external calls — the mocked boundary is an
  interface the domain owns (port and adapter). Each real implementation of
  that boundary carries its own tests, at its own tier: shared infrastructure
  (database, broker) → integration tests through Testcontainers against the
  real thing in a container — never a shared environment, never an in-memory
  pretender at that tier; HTTP perimeters → provider/consumer contract tests
  (e.g. Pact), so the fake the domain trusted is proven to match the real
  service. The mock and the adapter must agree, or one of them is lying.
- Unit and integration tests live in separate projects, named for the tier
  (`Warehouse-Desktop.UnitTests`, `Warehouse-Desktop.IntegrationTests`). The
  tier is decided by what the test needs to run, not by what it tests:
  in-process and deterministic → the unit project; containers or real
  dependencies → the integration project; an HTTP counterpart → the contract
  tier. The unit project runs everywhere and on every change; the integration
  project runs where the infrastructure exists — Docker locally, the CI
  pipeline — so its slowness never taxes the fast tier's loop. The
  integration project appears with the first real adapter, not before.
- In CQRS-style codebases, read and write paths land in different tiers:
  queries fetch data — their risk lives in the real access, so keep little
  abstraction on them and test them through integration tests against the
  real store; commands modify application state and perform the business
  actions — that logic belongs to the domain and gets unit tests.
- Layering and naming rules become ArchUnitNET tests, not conventions —
  extending an architecture rule means adding an architecture test.
- Mutation testing (Stryker.NET) is a periodic health check, not a per-diff
  gate.
