tableextension 11744 "Service Shipment Header CZL" extends "Service Shipment Header"
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
        field(31068; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
        }
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;
        }
    }
}
