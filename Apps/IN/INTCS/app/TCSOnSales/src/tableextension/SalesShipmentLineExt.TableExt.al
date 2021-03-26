tableextension 18841 "Sales Shipment Line Ext" extends "Sales Shipment Line"
{
    fields
    {
        field(18838; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18839; "Assessee Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
    }
}