namespace Microsoft.DataMigration.GP.HistoricalData;

enum 40900 "Hist. Sales Trx. Type"
{
    value(0; "Blank") { Caption = ''; }
    value(1; "Quote") { Caption = 'Quote'; }
    value(2; "Order") { Caption = 'Order'; }
    value(3; "Invoice") { Caption = 'Invoice'; }
    value(4; "Return Order") { Caption = 'Return Order'; }
    value(5; "Back Order") { Caption = 'Back Order'; }
    value(6; "Fulfillment Order") { Caption = 'Fulfillment Order'; }
}