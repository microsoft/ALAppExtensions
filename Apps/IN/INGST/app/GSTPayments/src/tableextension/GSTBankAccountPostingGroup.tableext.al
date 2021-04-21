tableextension 18243 "GST Bank Account Posting Group" extends "Bank Account Posting Group"
{
    fields
    {
        field(18243; "GST Rounding Account"; Code[20])
        {
            Caption = 'GST Rounding Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where(Blocked = const(False), "Account Type" = filter(Posting));
        }
    }

}