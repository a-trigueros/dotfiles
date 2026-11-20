using CSharpFunctionalExtensions;

namespace Booking;

public sealed record ReservationId(Guid Value);

public enum ReservationStatus
{
    Confirmed,
    Cancelled
}

public sealed record Reservation(
    ReservationId Id,
    string GuestName,
    DateOnly Arrival,
    int Nights,
    ReservationStatus Status);

public enum CreateError
{
    InvalidNights
}

public static class ReservationService
{
    public static Result<Reservation, CreateError> Create(
        string guestName,
        DateOnly arrival,
        int nights) =>
        nights <= 0
            ? Result.Failure<Reservation, CreateError>(CreateError.InvalidNights)
            : Result.Success<Reservation, CreateError>(new Reservation(
                new ReservationId(Guid.NewGuid()),
                guestName,
                arrival,
                nights,
                ReservationStatus.Confirmed));

    public static Reservation? Find(
        ReservationId id,
        IReadOnlyDictionary<ReservationId, Reservation> reservations) =>
        reservations.TryGetValue(id, out var reservation) ? reservation : null;
}
