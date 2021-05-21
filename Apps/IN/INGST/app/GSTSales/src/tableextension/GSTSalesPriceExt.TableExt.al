tableextension 18152 "GST Sales Price Ext" extends "Sales Price"
{
    fields
    {
        field(18141; "Price Inclusive of Tax"; boolean)
        {
            Caption = 'Price Inclusive of Tax';
            DataClassification = CustomerContent;
        }
    }
}