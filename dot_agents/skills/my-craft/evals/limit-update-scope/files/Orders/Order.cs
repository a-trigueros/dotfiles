namespace Orders;

public class Order
{
    public string CustNm { get; set; } = string.Empty;

    public List<OrderLine> Lines { get; set; } = new();

    public decimal Total { get; private set; }

    public void CalcTotal()
    {
        Total = Lines.Sum(l => l.Qty * l.UnitPrice);
    }
}
