namespace Microsoft.DataMigration.GP.HistoricalData;

enum 40905 "Hist. Inventory Doc. Type"
{
    value(0; "Blank") { Caption = ''; }
    value(1; "Inventory Adjustment") { Caption = 'Inventory Adjustment'; }
    value(2; Variance) { Caption = 'Variance'; }
    value(3; "Inventory Transfer") { Caption = 'Inventory Transfer'; }
    value(4; "Purchase Receipt") { Caption = 'Purchase Receipt'; }
    value(5; "Sales Returns") { Caption = 'Sales Returns'; }
    value(6; "Sales Invoices") { Caption = 'Sales Invoices'; }
    value(7; "Assembly") { Caption = 'Assembly'; }
    value(8; "Inventory Cost Adjustment") { Caption = 'Inventory Cost Adjustment'; }
}