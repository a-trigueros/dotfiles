# Test desiderata

Properties of valuable programmer tests, after Kent Beck and Jeff Langr
(testdesiderata.com), and how this skill honors them. When two properties
trade off, say the trade-off out loud instead of silently choosing.

- **Isolated** — each test owns its fixtures and its clock; no shared mutable
  state; any run order gives the same results.
- **Composable** — one dimension of variability per test; the suite is the
  composition.
- **Deterministic** — no wall clock, no randomness, no environment.
- **Fast** — in-process, milliseconds.
- **Writable** — fixtures are one helper away.
- **Readable** — the name states the business fact; the body tells the story.
- **Behavioral** — the data red proves the test is sensitive to the behavior;
  the stub that gets past the compile error is a non-action, never a staged
  failure.
- **Structure-insensitive** — assert public behavior (events, state), never
  internals.
- **Automated** — runs in the build, no human steps.
- **Specific** — one action per test, so a failure names its cause.
- **Predictive** — data red before green means green implies the rule holds;
  behind a mock, it holds only as far as integration or contract tests prove
  the real implementation honors the same contract.
- **Inspiring** — the crystallized domain rules make the suite the spec.

## Test builders

When several tests repeat the same arrangement, give the SUT one fluent
builder: a static entry point (`TestApp.Warehouse()`), `With`-style overrides
for exactly what the test varies, defaults for the shared context, and a
terminal method that builds and acts (`Run()`). The arrange section then reads
as the scenario; the knowledge stays in the assertions.

- **Fixture, not abstraction** — the builder holds no logic of the system under
  test; add an option only when a test demands it, no speculative
  configurability.
- **Defaults stated once** — the shared fixture lives in the builder with a
  comment naming it; a test needing a different world overrides explicitly
  rather than relying on a default it does not mention.
- **Timeline, not scattered calls** — time-dependent scenarios are ordered
  steps in the builder (act, advance the owned clock, act again), so expiry
  and deadlines stay deterministic and readable.
- **Nothing hidden from the assertion** — the terminal method returns the
  observation surface the test asserts on (captured output, returned state)
  and nothing more.
