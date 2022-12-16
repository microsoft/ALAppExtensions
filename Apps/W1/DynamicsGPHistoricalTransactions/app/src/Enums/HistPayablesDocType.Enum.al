enum 40004 "Hist. Payables Doc. Type"
{
    Extensible = true;

    value(0; "Unknown") { Caption = 'Unknown'; }
    value(1; Invoice) { Caption = 'Invoice'; }
    value(2; "Finance Charge") { Caption = 'Finance Charge'; }
    value(3; "Misc. Charges") { Caption = 'Misc. Charges'; }
    value(4; "Return") { Caption = 'Return'; }
    value(5; "Credit Memo") { Caption = 'Credit Memo'; }
    value(6; Payment) { Caption = 'Payment'; }
}