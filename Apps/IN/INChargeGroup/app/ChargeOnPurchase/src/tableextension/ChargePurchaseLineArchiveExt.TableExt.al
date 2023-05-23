tableextension 18532 "Charge Purch. Line Archive Ext" extends "Purchase Line Archive"
{
    fields
    {
        field(18680; "Charge Group Code"; Code[10])
        {
            Caption = 'Charge Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Charge Group Header";
        }
        field(18681; "Charge Group Line No."; Integer)
        {
            Caption = 'Charge Group Line No.';
            DataClassification = CustomerContent;
        }
    }
}