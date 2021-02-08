tableextension 11770 "Sales Invoice Header CZP" extends "Sales Invoice Header"
{
    fields
    {
        field(11740; "Cash Desk Code CZP"; Code[20])
        {
            Caption = 'Cash Desk Code';
            TableRelation = "Cash Desk CZP";
            DataClassification = CustomerContent;
        }
        field(11741; "Cash Document Action CZP"; Enum "Cash Document Action CZP")
        {
            Caption = 'Cash Document Action';
            DataClassification = CustomerContent;
        }
    }
}
