tableextension 10017 "IRS 1096 Purch. Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(10017; "IRS 1096 Form No. Series"; Code[20])
        {
            Caption = 'IRS 1096 Form No. Series';
            TableRelation = "No. Series";
        }
    }
}