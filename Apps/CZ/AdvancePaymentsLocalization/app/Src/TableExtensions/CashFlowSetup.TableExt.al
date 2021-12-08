tableextension 31042 "Cash Flow Setup CZZ" extends "Cash Flow Setup"
{
    fields
    {
        field(31002; "S. Adv. Letter CF Acc. No. CZZ"; Code[20])
        {
            Caption = 'Sales Adv. Letter CF Account No.';
            TableRelation = "Cash Flow Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckAccountType("S. Adv. Letter CF Acc. No. CZZ");
            end;
        }
        field(31003; "P. Adv. Letter CF Acc. No. CZZ"; Code[20])
        {
            Caption = 'Purch. Adv. Letter CF Account No.';
            TableRelation = "Cash Flow Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckAccountType("P. Adv. Letter CF Acc. No. CZZ");
            end;
        }
    }
}