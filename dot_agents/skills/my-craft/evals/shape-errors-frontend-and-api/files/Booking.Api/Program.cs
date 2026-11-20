using Bookings.Api;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var bookings = new List<Booking>();

app.MapPost("/api/bookings", (BookingRequest request) =>
{
    var booking = new Booking(request.Title, request.Start, request.End);
    bookings.Add(booking);
    return Results.Created($"/api/bookings/{booking.Id}", booking);
});

app.Run();

public record BookingRequest(string Title, DateTime Start, DateTime End);
