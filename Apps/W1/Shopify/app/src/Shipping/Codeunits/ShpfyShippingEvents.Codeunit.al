/// <summary>
/// Codeunit Shpfy Shipping Events (ID 30192).
/// </summary>
codeunit 30192 "Shpfy Shipping Events"
{
    Access = Internal;

    [InternalEvent(false)]
    internal procedure BeforeRetrieveTrackingUrl(var ShipingHeader: Record "Sales Shipment Header"; var TrackingUrl: Text; IsHandled: Boolean)
    begin
    end;
}
