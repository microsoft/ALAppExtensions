enum 40007 "Hist. Migration Step Type"
{
    Extensible = true;

    value(0; "Not Started") { Caption = 'Not Started'; }
    value(1; "GP GL Accounts") { Caption = 'GP G/L Accounts'; }
    value(2; "GP GL Journal Trx.") { Caption = 'GP G/L Journal Trx.'; }
    value(3; "GP Receivables Trx.") { Caption = 'GP Receivables Trx.'; }
    value(4; "GP Payables Trx.") { Caption = 'GP Payables Trx.'; }
    value(5; "GP Inventory Trx.") { Caption = 'GP Inventory Trx.'; }
    value(6; "GP Purchase Receivables Trx.") { Caption = 'GP Purchase Receivables Trx.'; }
    value(99; Finished) { Caption = 'Finished'; }
}