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

- Use the project's existing test runner (xUnit or TUnit); never introduce a
  second runner into a solution.
- Integration tests hit real dependencies in containers (Testcontainers), not
  shared environments or partial mocks.
- Layering and naming rules become ArchUnitNET tests, not conventions —
  extending an architecture rule means adding an architecture test.
- Mutation testing (Stryker.NET) is a periodic health check, not a per-diff
  gate.
