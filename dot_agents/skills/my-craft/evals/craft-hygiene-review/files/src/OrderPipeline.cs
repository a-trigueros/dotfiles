using Acme.Orders.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Acme.Orders.Pipeline;

// Orchestrates the intake of order drafts. The rest of this class — the
// legacy import half — lives in OrderPipeline.Import.cs.
public partial class OrderPipeline
{
    #region Intake

    public ShipmentResult Enqueue(OrderDraft draft)
    {
        var label = "SHIP/" + draft.RecipientName.Trim() + "   //" + draft.DeliveryAddress;
        var eta = DateTime.Now.AddDays(2);

        try
        {
            orders.SaveDraft(draft, label, eta); // label lands in the Orders.ShippingLabel column
            audit.Record("order.enqueued", draft.ExternalRef);
            return ShipmentResult.Accepted(draft.ExternalRef, eta);
        }
        catch (DbUpdateException ex)
        {
            log.LogError(ex, "Draft persist failed for {Ref}", draft.ExternalRef);
            throw ex;
        }
        catch (InvalidOperationException)
        {
        }

        return ShipmentResult.Rejected(draft.ExternalRef, "Invalid draft");
    }

    #endregion

    #region State

    public int QueueDepth => pending.Count;

    private const int MaxDraftsPerDay = 50;

    private readonly Queue<OrderDraft> pending = new();

    private readonly IOrderRepository orders;
    private readonly IAuditTrail audit;
    private readonly ILogger<OrderPipeline> log;

    #endregion
}
