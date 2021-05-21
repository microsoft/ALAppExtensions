tableextension 11512 "Swiss QR-Bill Payment Method" extends "Payment Method"
{
    fields
    {
        field(11510; "Swiss QR-Bill Layout"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Swiss QR-Bill Layout";
            Caption = 'QR-Bill Layout';
        }
    }
}