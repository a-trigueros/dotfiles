using Acme.Orders.Persistence;
using MediatR;

namespace Acme.Orders.Pipeline;

public sealed class PlaceOrderHandler : IRequestHandler<PlaceOrderCommand, PlaceOrderResult>
{
    private readonly IOrderRepository orders;
    private readonly TimeProvider clock;

    public PlaceOrderHandler(IOrderRepository orders, TimeProvider clock)
    {
        this.orders = orders;
        this.clock = clock;
    }

    public async Task<PlaceOrderResult> Handle(PlaceOrderCommand command, CancellationToken cancellationToken)
    {
        var order = Order.From(command.ExternalRef, command.RecipientName, command.DeliveryAddress, command.Quantity);
        orders.Add(order);
        await orders.SaveChangesAsync(cancellationToken);

        return new PlaceOrderResult(order.Id, clock.GetUtcNow().DateTime.AddDays(2));
    }
}
