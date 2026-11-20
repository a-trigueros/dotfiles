namespace Acme.Bookings.Api;

public class ReservationApiModel
{
    public Guid Id { get; set; }

    public string GuestName { get; set; } = string.Empty;

    public DateOnly Arrival { get; set; }

    public int Nights { get; set; }

    public decimal TotalPrice { get; set; }

    public string Status { get; set; } = string.Empty;

    public List<string> GuestTag { get; set; } = new();
}
