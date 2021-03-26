tableextension 18604 "Gate Entry Sales Shpmnt Hdr" extends "Sales Shipment Header"
{
    fields
    {
        field(18601; "LR/RR No."; code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18602; "LR/RR Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}