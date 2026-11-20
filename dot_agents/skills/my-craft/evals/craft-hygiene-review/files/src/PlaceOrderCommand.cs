namespace Acme.Orders.Pipeline;

public sealed record PlaceOrderCommand(
    string ExternalRef,
    string RecipientName,
    string DeliveryAddress,
    int Quantity);

public sealed record PlaceOrderResult(Guid OrderId, DateTime EstimatedDelivery);
