tableextension 18931 "Gen.Jnl Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(18929; "Narration Document No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18930; "Cheque Date"; Date)
        {
            Caption = 'Cheque Date';
        }
        field(18931; "Cheque No."; Code[10])
        {
            Caption = 'Cheque No.';
        }
    }
}