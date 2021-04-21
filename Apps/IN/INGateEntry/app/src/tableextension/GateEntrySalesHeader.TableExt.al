tableextension 18602 "Gate Entry Sales Header" extends "Sales Header"
{
    fields
    {
        field(18601; "LR/RR No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(18602; "LR/RR Date"; Date)
        {
            DataClassification = CustomerContent;
        }
    }
}