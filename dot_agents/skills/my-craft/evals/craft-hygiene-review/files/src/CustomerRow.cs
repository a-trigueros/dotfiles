namespace Acme.Orders.Persistence;

// Mapped to the Customers table by EF Core; column configuration lives in the
// DbContext (not shown here).
public class CustomerRow
{
    public Guid Id { get; set; }

    public string DisplayName { get; set; } = string.Empty;

    public string Notes { get; set; } = string.Empty; // free-form, written as typed by staff

    public DateTime CreatedUtc { get; set; }
}
