tableextension 11785 "Detailed Cust. Ledg. Entry CZL" extends "Detailed Cust. Ledg. Entry"
{
    fields
    {
        field(11770; "Customer Posting Group CZL"; Code[20])
        {
            Caption = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
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