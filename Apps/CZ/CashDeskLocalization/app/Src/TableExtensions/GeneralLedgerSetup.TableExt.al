tableextension 11781 "General Ledger Setup CZP" extends "General Ledger Setup"
{
    fields
    {
        field(11740; "Cash Desk Nos. CZP"; Code[20])
        {
            Caption = 'Cash Desk Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(11741; "Cash Payment Limit (LCY) CZP"; Decimal)
        {
            Caption = 'Cash Payment Limit (LCY)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
    }
}
