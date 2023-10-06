namespace Microsoft.DataMigration.GP.HistoricalData;

enum 40904 "Hist. Payables Doc. Type"
{
    value(0; "Blank") { Caption = ''; }
    value(1; Invoice) { Caption = 'Invoice'; }
    value(2; "Finance Charge") { Caption = 'Finance Charge'; }
    value(3; "Misc. Charges") { Caption = 'Misc. Charges'; }
    value(4; "Return") { Caption = 'Return'; }
    value(5; "Credit Memo") { Caption = 'Credit Memo'; }
    value(6; Payment) { Caption = 'Payment'; }
}