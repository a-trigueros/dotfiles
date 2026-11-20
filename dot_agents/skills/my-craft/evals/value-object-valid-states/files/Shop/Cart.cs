namespace Shop;

public class Cart
{
    private readonly List<OrderLine> _lines = new();

    public IReadOnlyList<OrderLine> Lines => _lines;

    public void Add(string articleNumber, int quantity, decimal unitPrice)
    {
        if (quantity <= 0)
            throw new ArgumentException("Quantity must be positive.", nameof(quantity));

        _lines.Add(new OrderLine(articleNumber, quantity, unitPrice));
    }
}
