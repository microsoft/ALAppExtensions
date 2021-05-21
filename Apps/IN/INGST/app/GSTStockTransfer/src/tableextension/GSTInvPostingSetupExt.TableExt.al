tableextension 18390 "GST Inv. Posting Setup Ext" extends "Inventory Posting Setup"
{
    fields
    {
        field(18390; "Unrealized Profit Account"; Code[20])
        {
            Caption = 'Unrealized Profit Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
    }
}