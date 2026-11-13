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

Two validations, two layers:

- **Invariants** live in the model: value objects and constructors that refuse
  invalid states (compiler tier — the model cannot exist in an invalid state).
- **Caller-facing validation** lives at the exposure layer (`FluentValidation`)
  and returns the fullest explicit error set for the caller, not the first
  failure.

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

## Testing

- One test class per business operation, named `<Operation>Should`
  (`ReserveSkuShould`) — the class name is the operation, not "scenario".
  Passing scenarios are methods stating the business outcome; every failure
  case lives in a nested `public class Fail` with methods named
  `When_<business reason>` (`When_available_stock_is_insufficient`). Runners
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
