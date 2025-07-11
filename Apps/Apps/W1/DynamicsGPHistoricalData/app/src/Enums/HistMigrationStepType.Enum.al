namespace Microsoft.DataMigration.GP.HistoricalData;

enum 40907 "Hist. Migration Step Type"
{
    value(0; "Not Started") { Caption = 'Not Started'; }
    value(1; "Started") { Caption = 'Started'; }
    value(2; "GP GL Accounts") { Caption = 'GP G/L Accounts'; }
    value(3; "GP GL Journal Trx.") { Caption = 'GP G/L Journal Trx.'; }
    value(4; "GP Receivables Trx.") { Caption = 'GP Receivables Trx.'; }
    value(5; "GP Payables Trx.") { Caption = 'GP Payables Trx.'; }
    value(6; "GP Inventory Trx.") { Caption = 'GP Inventory Trx.'; }
    value(7; "GP Purchase Receivables Trx.") { Caption = 'GP Purchase Receivables Trx.'; }
    value(98; "Resetting Data") { Caption = 'Resetting Historical Data'; }
    value(99; Finished) { Caption = 'Finished'; }
}