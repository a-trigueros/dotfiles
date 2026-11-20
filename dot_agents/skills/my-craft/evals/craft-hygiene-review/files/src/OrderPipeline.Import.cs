using Acme.Orders.Persistence;

namespace Acme.Orders.Pipeline;

// Second half of OrderPipeline — legacy import helpers.
public partial class OrderPipeline
{
    internal void ImportFromLegacy(IEnumerable<LegacyRow> rows)
    {
        var accepted = 0;

        foreach (var row in rows)
        {
            if (accepted >= MaxDraftsPerDay)
            {
                audit.Record("import.throttled", row.LegacyId);
                break;
            }

            Enqueue(new OrderDraft(row.LegacyId, row.CustomerName, row.DeliveryAddress, row.Quantity));
            accepted++;
        }
    }
}
