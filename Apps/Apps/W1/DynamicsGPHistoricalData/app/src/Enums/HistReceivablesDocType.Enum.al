namespace Microsoft.DataMigration.GP.HistoricalData;

enum 40903 "Hist. Receivables Doc. Type"
{
    value(0; Balance) { Caption = 'Balance'; }
    value(1; SaleOrInvoice) { Caption = 'Sale / Invoice'; }
    value(2; "Scheduled Payment") { Caption = 'Scheduled Payment'; }
    value(3; "Debit Memo") { Caption = 'Debit Memo'; }
    value(4; "Finance Charge") { Caption = 'Finance Charge'; }
    value(5; "Service Repair") { Caption = 'Service Repair'; }
    value(6; Warranty) { Caption = 'Warranty'; }
    value(7; "Credit Memo") { Caption = 'Credit Memo'; }
    value(8; Return) { Caption = 'Return'; }
    value(9; Payment) { Caption = 'Payment'; }
    value(99; "Blank") { Caption = ''; }
}