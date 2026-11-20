namespace Acme.Orders.Api;

public sealed record CustomerApiModel(
    Guid Id,
    string DisplayName,
    string Notes);
