tableextension 18601 "Gate Entry Return Shipment Hdr" extends "Return Shipment Header"
{
    fields
    {
        field(18601; "Vehicle No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18602; "Vehicle Type"; Enum "GST Vehicle Type")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}