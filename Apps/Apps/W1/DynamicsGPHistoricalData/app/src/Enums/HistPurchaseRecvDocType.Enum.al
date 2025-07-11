namespace Microsoft.DataMigration.GP.HistoricalData;

enum 40906 "Hist. Purchase Recv. Doc. Type"
{
    value(0; "Blank") { Caption = ''; }
    value(1; Shipment) { Caption = 'Shipment'; }
    value(2; Invoice) { Caption = 'Invoice'; }
    value(3; "Shipment/Invoice") { Caption = 'Shipment/Invoice'; }
    value(4; "Return") { Caption = 'Return'; }
    value(5; "Return w/Credit") { Caption = 'Return w/Credit'; }
    value(6; "Inventory Return") { Caption = 'Inventory Return'; }
    value(7; "Inventory Return w/Credit") { Caption = 'Inventory Return w/Credit'; }
    value(8; "Intransit Transfer") { Caption = 'Intransit Transfer'; }
}