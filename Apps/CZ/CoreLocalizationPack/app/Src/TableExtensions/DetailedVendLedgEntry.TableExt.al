tableextension 11786 "Detailed Vend. Ledg. Entry CZL" extends "Detailed Vendor Ledg. Entry"
{
    fields
    {
        field(11770; "Vendor Posting Group CZL"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
            DataClassification = CustomerContent;
        }
        field(11790; "Appl. Across Post. Groups CZL"; Boolean)
        {
            Caption = 'Application Across Posting Groups';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}