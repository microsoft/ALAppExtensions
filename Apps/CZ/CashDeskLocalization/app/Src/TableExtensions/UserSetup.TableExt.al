tableextension 11780 "User Setup CZP" extends "User Setup"
{
    fields
    {
        field(11740; "Cash Resp. Ctr. Filter CZP"; Code[10])
        {
            Caption = 'Cash Responsibility Center Filter';
            TableRelation = "Responsibility Center";
            DataClassification = CustomerContent;
        }
        field(11742; "Cash Desk Amt. Appr. Limit CZP"; Integer)
        {
            BlankZero = true;
            Caption = 'Cash Desk Amt. Approval Limit';
            DataClassification = CustomerContent;
        }
        field(11743; "Unlimited Cash Desk Appr. CZP"; Boolean)
        {
            Caption = 'Unlimited Cash Desk Approval';
            DataClassification = CustomerContent;
        }
    }
}
