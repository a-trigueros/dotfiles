namespace Acme.Bookings.Domain;

public enum ReservationStatus
{
    Confirmed,
    Cancelled
}

public class Reservation
{
    public Guid Id { get; set; }

    public string GuestName { get; set; } = string.Empty;

    public DateOnly Arrival { get; set; }

    public int Nights { get; set; }

    public decimal TotalPrice { get; set; }

    public ReservationStatus Status { get; set; }

    public bool IsCancellable(DateOnly today)
    {
        return Status == ReservationStatus.Confirmed && Arrival.AddDays(-2) >= today;
    }
}
