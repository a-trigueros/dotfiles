using FluentValidation;

namespace Acme.Orders.Pipeline;

public sealed class PlaceOrderValidator : AbstractValidator<PlaceOrderCommand>
{
    public PlaceOrderValidator()
    {
        RuleFor(c => c.ExternalRef).NotEmpty();
        RuleFor(c => c.RecipientName).NotEmpty().MaximumLength(200);
        RuleFor(c => c.DeliveryAddress).NotEmpty();
        RuleFor(c => c.Quantity).GreaterThan(0);
    }
}
