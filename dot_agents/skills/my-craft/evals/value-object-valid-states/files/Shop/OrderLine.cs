namespace Shop;

public class OrderLine
{
    public OrderLine(string articleNumber, int quantity, decimal unitPrice)
    {
        if (quantity <= 0)
            throw new ArgumentException("Quantity must be positive.", nameof(quantity));
        if (unitPrice < 0)
            throw new ArgumentException("Unit price cannot be negative.", nameof(unitPrice));

        ArticleNumber = articleNumber;
        Quantity = quantity;
        UnitPrice = unitPrice;
    }

    public string ArticleNumber { get; }

    public int Quantity { get; }

    public decimal UnitPrice { get; }
}
