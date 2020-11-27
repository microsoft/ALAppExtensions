tableextension 11729 "Return Shipment Header CZL" extends "Return Shipment Header"
{
    fields
    {
        field(11781; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(31073; "EU 3-Party Trade CZL"; Boolean)
        {
            Caption = 'EU 3-Party Trade';
            DataClassification = CustomerContent;
        }
    }
}
