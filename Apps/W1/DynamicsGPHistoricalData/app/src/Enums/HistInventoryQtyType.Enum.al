namespace Microsoft.DataMigration.GP.HistoricalData;

enum 40908 "Hist. Inventory Qty. Type"
{
    value(0; Unknown) { Caption = 'Unknown'; }
    value(1; "On Hand") { Caption = 'On Hand'; }
    value(2; Returned) { Caption = 'Returned'; }
    value(3; "In Use") { Caption = 'In Use'; }
    value(4; "In Service") { Caption = 'In Service'; }
    value(5; Damaged) { Caption = 'Damaged'; }
}