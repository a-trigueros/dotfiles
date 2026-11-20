using Booking;
using Xunit;

namespace Booking.UnitTests;

public class CreateShould
{
    [Fact]
    public void Refuses_non_positive_nights()
    {
        var result = ReservationService.Create("Ada", new DateOnly(2026, 3, 1), 0);

        Assert.True(result.IsFailure);
        Assert.Equal(CreateError.InvalidNights, result.Error);
    }

    [Fact]
    public void Confirms_a_valid_reservation()
    {
        var result = ReservationService.Create("Ada", new DateOnly(2026, 3, 1), 3);

        Assert.True(result.IsSuccess);
        Assert.Equal(ReservationStatus.Confirmed, result.Value.Status);
    }
}
