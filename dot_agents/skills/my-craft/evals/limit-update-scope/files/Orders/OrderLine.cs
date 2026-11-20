namespace Orders;

public class OrderLine
{
    public string ArtNum { get; set; } = string.Empty;

    public int Qty { get; set; }

    public decimal UnitPrice { get; set; }
}
