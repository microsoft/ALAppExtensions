tableextension 31002 "VAT Entry CZZ" extends "VAT Entry"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Header CZZ";
        }
    }
}
