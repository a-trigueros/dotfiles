namespace Bookings.Api;

public class Booking
{
    public Booking(string title, DateTime start, DateTime end)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Title is required.", nameof(title));
        if (end <= start)
            throw new ArgumentException("End must be after start.", nameof(end));

        Id = Guid.NewGuid();
        Title = title;
        Start = start;
        End = end;
    }

    public Guid Id { get; }

    public string Title { get; }

    public DateTime Start { get; }

    public DateTime End { get; }
}
