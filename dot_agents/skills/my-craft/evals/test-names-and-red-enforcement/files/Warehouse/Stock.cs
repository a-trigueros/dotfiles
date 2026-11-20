namespace Warehouse;

public sealed record Sku
{
    private Sku(string value) => Value = value;

    public string Value { get; }

    public static Sku Parse(string raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
            throw new ArgumentException("SKU must be provided.", nameof(raw));

        return new Sku(raw.Trim().ToUpperInvariant());
    }

    public override string ToString() => Value;
}

public sealed class Stock
{
    private readonly Dictionary<Sku, int> _levels;

    public Stock(IEnumerable<(Sku sku, int level)> initialLevels)
    {
        _levels = initialLevels.ToDictionary(pair => pair.sku, pair => pair.level);
    }

    public int Available(Sku sku) => _levels.TryGetValue(sku, out var level) ? level : 0;
}
