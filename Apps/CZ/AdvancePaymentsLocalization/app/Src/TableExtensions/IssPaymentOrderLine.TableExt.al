tableextension 31040 "Iss. Payment Order Line CZZ" extends "Iss. Payment Order Line CZB"
{
    fields
    {
        field(31000; "Purch. Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Purchase Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Vendor)) "Purch. Adv. Letter Header CZZ"."No.";
        }
    }
}
