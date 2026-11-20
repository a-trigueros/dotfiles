# .NET reference (ASP.NET Core)

Load this file for any C#/.NET API work. It assumes the solution was
initialized with centralized package versions and static analysis enabled.
Paradigm rules live in SKILL.md; this file is the mechanical translation
into ASP.NET Core.

## Choosing the exposure model

Three first-class options; pick by context, not fashion:

| Model             | Fit                                                               | Validation                      | Notes                                            |
| ----------------- | ----------------------------------------------------------------- | ------------------------------- | ------------------------------------------------ |
| **Controllers**   | Existing MVC codebase, larger APIs, teams familiar with the model | Automatic via `[ApiController]` | Convention-rich, most ceremony                   |
| **Minimal API**   | Microservices, limited endpoint counts, .NET 6+                   | Manual (`IValidator<T>` filter) | Least ceremony; extract before Program.cs bloats |
| **FastEndpoints** | Structured endpoints without Controller ceremony                  | Automatic via `Validator<T>`    | REPR pattern; **secure by default**              |

All three must honor the same contract rules: dedicated DTOs (never domain
or EF entities on the wire), Problem Details errors, OpenAPI docs, tests
through HTTP.

## Lean response metadata (all three models)

No `[Produces("application/json")]`, no `[ProducesResponseType]`, no
`ProducesProblem()` / `ProducesValidationProblem()`, no FastEndpoints
`Produces(...)` / `Description(...)` restatements. The produced type lives
in the signature (`ActionResult<T>`, `Results<Ok<T>, NotFound>`); the media
type is content negotiation's job; error _statuses_ belong to the HTTP RFCs
and error _bodies_ follow one convention — Problem Details on validation
errors only, bare statuses everywhere else. Annotating a contract twice
means the duplicate drifts first. The same for comments: no XML-doc blocks
restating routes, verbs or status codes — expressive names and typed
results carry that. Keep only what a signature cannot show: the why.
OpenAPI enrichment (`WithName`, tags, summaries) is reserved for what the
signature genuinely cannot express (link targets for `Location`, grouping).

## Boundary idioms

- **Force verification at the edge.** Prefer a throwing `Parse` (its failure
  becomes 400/422 through the normal error path) or a typed result that
  carries the failure over `bool TryXxx` — a returned bool can be ignored,
  and an ignored bool is an unvalidated path into the domain. `Try` stays
  for genuine misses the flow must branch on (a store lookup returning
  `Country?`), not for payload validation.
- **`AsNoTracking` is redundant on projections.** A `Select` into a
  non-entity type is never tracked; add `AsNoTracking` only when
  materializing entities for read-only use. Redundant calls hide the
  meaningful ones.
- **Minimal API validation is not automatic** — wire it through a named
  filter or an explicit, well-named call so the structure says it; never a
  comment explaining the gap.
- **Paginate by default with Gridify.** Any collection endpoint binds
  `[FromQuery] GridifyQuery` (filter, page, pageSize, orderBy) and applies it
  through a whitelisted `IGridifyMapper<T>`: `queryable.Gridify(query, mapper)`
  returns `Paging<T>` — items plus total count. The mapper whitelists the
  client-addressable fields, so query strings cannot reach arbitrary
  properties. Register `services.AddGridify()`. Minimalism, "temporary"
  scope, or avoiding a new dependency does not override this default — it
  exists precisely for code that outlives its "temporary" label.

## Controllers

**One route, one controller.** A controller owns exactly one route
(`api/products`). A sub-route is a **new controller** —
`OrderCancellationsController` for `api/orders/{id}/cancellations`, not a
new action family bolted onto `OrdersController`. Splitting early keeps
controllers thin; a controller that grows past its resource's operations is
a smell.

Conventions:

- Default prefix `/api` (e.g. `api/products`), version segment by default
  (`api/v1/products`) — see the routing conventions in SKILL.md.
- PATCH only for pure CRUD partial updates (reference data, settings);
  business actions are intention-revealing routes, never field writes —
  see SKILL.md.
- Route names are **plural** (`api/products`); the `[controller]` token
  inherits the name, so name the controller plural too (`ProductsController`).
- Singleton access goes through a **route parameter** (`{id:int}`) — one
  identifier, unique per resource.
- GET filters, options, and read context travel in **query parameters**
  (`?page=2&status=active`). Mutations carry the representation in the body,
  while write-time behavior flags (`?draft=true`, `?hideOnly=true`) also
  travel in the query — bind them with `[FromQuery]`, never as body fields
  (see the query-parameter rules in SKILL.md). Query parameters are
  camelCase: the published name is the declared parameter name, with no
  `[FromQuery(Name = ...)]` renaming; keys owned by a third-party tool keep
  that tool's specification (Gridify: `pageSize`, `orderBy`, `filter`). A
  valueless key (`?hideOnly` alone) fails binding with 400 — booleans need
  the explicit `=true|false`, and an invalid value must surface as 400,
  never a silent default.
- `ControllerBase`, `[ApiController]`, `[Route("api/[controller]")]`.

Rules (why: consistency and predictable contracts):

- Always return `ActionResult<T>` — no naked types, no bare `IActionResult`.
- One exception to "no metadata": a bare `NoContentResult` return publishes
  as `200` in the OpenAPI document (ApiExplorer cannot infer 204 from it —
  verified empirically), so a single
  `[ProducesResponseType(StatusCodes.Status204NoContent)]` is required there.
  It carries contract information, it is not restatement.
- Use the helper methods: `Ok`, `NotFound`, `CreatedAtAction`, `NoContent`,
  `BadRequest` — they set status codes and `Location` correctly.
- Constructor injection; no `[FromServices]` on actions.
- One DTO per operation when fields differ (`ProductCreateDto` ≠
  `ProductUpdateDto` ≠ `ProductResponse`).
- Name actions after the HTTP verb: `Get`, `Create`, `Update`, `Delete`,
  `Patch`.
- `[ApiController]` auto-validates model state before the action and returns
  400; keep FluentValidation for business rules:

  ```csharp
  builder.Services.AddValidatorsFromAssemblyContaining<ProductCreateValidator>();
  ```

  ```csharp
  public class ProductCreateValidator : AbstractValidator<ProductCreateDto>
  {
      public ProductCreateValidator()
      {
          RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
          RuleFor(x => x.Price).GreaterThan(0);
      }
  }
  ```

- Creation returns `CreatedAtAction(nameof(GetById), new { id = product.Id },
product)` — this produces `201` + `Location`.

```bash
dotnet new webapi -n MyApi --use-controllers
```

## Minimal API

```bash
dotnet new webapi -n MyApi --use-minimal-apis
```

- Group per resource with `MapGroup("/api/products")` to factor the route
  prefix.
- Return `Results.Ok / NotFound / Created / NoContent / ValidationProblem`.
- **Validation is not automatic** — unlike Controllers. Every endpoint that
  receives a body must call the validator explicitly or through a shared
  filter/extension; on failure return `Results.ValidationProblem(...)`.
  Forgetting this is the classic Minimal API hole — wire it once, reuse.

  ```csharp
  products.MapPost("/", async (ProductCreateDto dto, IValidator<ProductCreateDto> v, IProductService s) =>
  {
      var result = await v.ValidateAsync(dto);
      if (!result.IsValid) return Results.ValidationProblem(result.ToDictionary());
      var product = await s.CreateAsync(dto);
      return Results.Created($"/api/products/{product.Id}", product);
  });
  ```

- Name routes with `.WithName(...)` (link targets for `Location`); add
  OpenAPI enrichment only for what the signature cannot express.
- **When to extract from Program.cs**: as soon as it exceeds ~100 lines or
  the resource count exceeds 3. Use static extension classes
  (`MapProductsEndpoints(this RouteGroupBuilder group)`); the pattern
  preserves simplicity without ceremony.
- **Modern .NET API breaks** (verified on .NET 10/11): typed result types
  (`Ok<T>`, `Results<...>`, `NotFound`) live in
  `Microsoft.AspNetCore.Http.HttpResults`; `TypedResults.CreatedAtAction`
  was removed — use `TypedResults.CreatedAtRoute` with a route name
  (`.WithName(...)` provides the target).

## FastEndpoints

Pattern: **REPR** (Request – Endpoint – Response), one class per operation.

```xml
<PackageReference Include="FastEndpoints" />
<PackageReference Include="FastEndpoints.Swagger" />
```

```csharp
public class CreateProductEndpoint : Endpoint<CreateProductRequest, CreateProductResponse>
{
    private readonly IProductService _service;
    public CreateProductEndpoint(IProductService service) => _service = service;

    public override void Configure()
    {
        Post("/api/products");
    }

    public override async Task HandleAsync(CreateProductRequest req, CancellationToken ct)
    {
        var product = await _service.CreateAsync(req.Name, req.Price, ct);
        await SendCreatedAtAsync<GetProductEndpoint>(new { id = product.Id },
            new CreateProductResponse { Id = product.Id, Name = product.Name, Price = product.Price },
            cancellation: ct);
    }
}
```

Rules:

- `Endpoint<TRequest, TResponse>` for body endpoints;
  `EndpointWithoutRequest<TResponse>` for GET without body.
- Response helpers: `SendAsync`, `SendCreatedAtAsync<TEndpoint>` (201 +
  Location), `SendNotFoundAsync`, `SendNoContentAsync`, `SendErrorsAsync`.
- Validation: a `Validator<TRequest>` class (FluentValidation) is invoked
  automatically before `HandleAsync`.
- **Secure by default**: every endpoint rejects unauthenticated requests
  unless explicitly opened with `AllowAnonymous()`. Do not open endpoints
  reflexively.
- Factor route prefixes with a `Group` class instead of repeating paths.
- Discovery is automatic — no registration.

## Cross-cutting: errors, docs, versioning, auth

**Error handling — centralized, one place.** Business failures become
status codes in a single location: a global handler, or one
`IExceptionHandler` per business-exception family, all registered once.
Actions never try/catch business exceptions — an inline mapping is a second
place for error semantics to drift. Result-monad pipelines (`FluentResults` /
`OneOf`) flow through the same single mapping helper at the edge; keep the
wire format identical either way.

Body policy: **Problem Details bodies only on validation errors** (400/422
naming the offending fields). Conflicts, missing resources, auth failures
and server faults return the bare status code — 409, 404, 401, 500 say
what happened; details go to logs, never to the wire:

```csharp
app.UseExceptionHandler(handlerApp => handlerApp.Run(async context =>
{
    // 500 says nothing: the status code is the message. Details go to logs.
    context.Response.StatusCode = StatusCodes.Status500InternalServerError;
}));
```

**OpenAPI** — the documentation is part of the contract: Swashbuckle
(Controllers, Minimal API) or `FastEndpoints.Swagger`. Typed signatures
generate the response shapes; enrich only what they cannot express (route
names for `Location` links, tags, summaries). No XML-doc pavés restating
status codes. An endpoint missing from the docs is a contract bug.

**Versioning — by default.** New APIs carry a version segment
(`/api/v1/...`) wired through `Asp.Versioning.Mvc` (Controllers) or
`Asp.Versioning.Http` (Minimal API). Opt out only when the user says so, or
the codebase already exposes a large unversioned route surface — matching
the existing style then wins. Whatever the strategy: version the payload
schemas, not just routes (see SKILL.md).

**Authentication — closed by default.** Register a fallback authorization
policy (or `RequireAuthorization()` on the app/group) so every endpoint
requires authentication the moment it is discovered; `AllowAnonymous` is
the only way to open one, deliberate and visible at the endpoint it opens.
Per-endpoint `[Authorize]` as the default mechanism is forbidden — one
forgotten attribute is an open endpoint. JWT bearer is the default scheme:
wire it once in the host and let the fallback policy do the closing.
`401` unauthenticated, `403` authenticated-but-forbidden — do not conflate
them.

## Testing the contract

Tests go through the real HTTP pipeline — `WebApplicationFactory` hosts the
app in memory and `HttpClient` sends real requests:

```csharp
public class ProductsApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    public ProductsApiTests(WebApplicationFactory<Program> factory)
        => _client = factory.CreateClient();

    [Fact]
    public async Task GetAll_ReturnsOk()
    {
        var response = await _client.GetAsync("/api/products");
        response.EnsureSuccessStatusCode();
    }
}
```

- Replace external dependencies (databases, downstream clients) via the
  factory; assert on status codes **and** JSON payload shapes — the payload
  is where contract changes concentrate.
- For expressive scenarios, use **Alba** (fluent HTTP scenario API);
  **TUnit.AspNetCore** for TUnit-native integration.
- A test that instantiates the controller/service directly bypasses routing,
  model binding, validation, and serialization — it proves nothing about the
  contract.
- External consumers: add consumer-driven contract tests pinned to the
  schemas actually consumed.
