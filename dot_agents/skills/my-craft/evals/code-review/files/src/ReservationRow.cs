namespace Acme.Bookings.Persistence;

// Mapped to the Reservations table by EF Core; column configuration lives in the
// DbContext (not shown here).
public class ReservationRow
{
    public Guid Id { get; set; }

    public string GuestName { get; set; } = string.Empty;

    public DateOnly Arrival { get; set; }

    public int Nights { get; set; }

    public string RoomType { get; set; } = string.Empty;

    public decimal TotalPrice { get; set; }

    public string Currency { get; set; } = string.Empty;

    public string Status { get; set; } = string.Empty;

    public string? SpecialRequests { get; set; }

    public DateTime CreatedUtc { get; set; }

    public DateTime? ModifiedUtc { get; set; }

    public string? CancelledReason { get; set; }

    public Guid? CancelledByStaffId { get; set; }

    public int RowVersion { get; set; }
}
