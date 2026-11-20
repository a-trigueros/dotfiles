namespace Shop;

// Row of the supplier CSV feed, all fields raw strings.
public sealed class ImportedOrderLine
{
    public string ArticleNumber { get; init; } = string.Empty;

    public string Quantity { get; init; } = string.Empty;

    public string UnitPrice { get; init; } = string.Empty;
}

public class ImportMapper
{
    public OrderLine ToOrderLine(ImportedOrderLine raw)
    {
        return new OrderLine(
            raw.ArticleNumber,
            int.Parse(raw.Quantity),
            decimal.Parse(raw.UnitPrice));
    }
}
