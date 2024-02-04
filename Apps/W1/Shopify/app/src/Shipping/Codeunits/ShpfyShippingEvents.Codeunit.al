namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

/// <summary>
/// Codeunit Shpfy Shipping Events (ID 30192).
/// </summary>
codeunit 30192 "Shpfy Shipping Events"
{
    [InternalEvent(false)]
    internal procedure OnBeforeRetrieveTrackingUrl(var SalesShipmentHeader: Record "Sales Shipment Header"; var TrackingUrl: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    /// <summary> 
    /// Raised Before Get Notify Customer.
    /// </summary>
    /// <param name="SalesShipmentHeader">Parameter of type Record "Sales Shipment Header".</param>
    /// <param name="LocationId">Parameter of type BigInteger.</param>
    /// <param name="NotifyCustomer">Parameter of type Boolean.</param>
    /// <param name="IsHandled">Parameter of type Boolean.</param>
    internal procedure OnGetNotifyCustomer(SalesShipmentHeader: Record "Sales Shipment Header"; LocationId: BigInteger; var NotifyCustomer: Boolean; var IsHandled: Boolean)
    begin
    end;
}
