tableextension 11783 "Isolated Certificate CZL" extends "Isolated Certificate"
{
    fields
    {
        field(31140; "Certificate Code CZL"; Code[20])
        {
            Caption = 'Certificate Code';
            Editable = false;
            TableRelation = "Certificate Code CZL";
            DataClassification = CustomerContent;
        }
    }
}