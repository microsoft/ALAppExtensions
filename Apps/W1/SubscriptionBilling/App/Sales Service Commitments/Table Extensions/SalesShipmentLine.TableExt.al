namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

tableextension 8010 "Sales Shipment Line" extends "Sales Shipment Line"
{
    fields
    {
        modify("No.")
        {
            TableRelation = if (Type = const("Service Object")) "Subscription Header" where("End-User Customer No." = field("Sell-to Customer No."));
        }
    }
}