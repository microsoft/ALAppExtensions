tableextension 18844 "Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(18839; "Exclude GST in TCS Base"; Boolean)
        {
            Caption = 'Exclude GST in TCS Base';
            DataClassification = EndUserIdentifiableInformation;
            editable = false;
        }
    }
}