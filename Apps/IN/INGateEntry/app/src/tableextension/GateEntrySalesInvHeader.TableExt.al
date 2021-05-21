tableextension 18603 "Gate Entry Sales Inv. Header" extends "Sales Invoice Header"
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