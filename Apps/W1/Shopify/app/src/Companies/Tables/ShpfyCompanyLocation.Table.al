namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Company Location (ID 30151).
/// </summary>
table 30151 "Shpfy Company Location"
{
    Caption = 'Shopify Company Location';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Company SystemId"; Guid)
        {
            Caption = 'Company SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(4; "Address 2"; Text[100])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(5; Zip; Code[20])
        {
            Caption = 'Zip';
            DataClassification = CustomerContent;
        }
        field(6; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(7; "Country/Region Code"; Code[2])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(8; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(9; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Province Code"; Code[10])
        {
            Caption = 'Province';
            DataClassification = CustomerContent;
        }
        field(11; "Province Name"; Text[50])
        {
            Caption = 'Province Name';
            DataClassification = CustomerContent;
        }
        field(12; "Tax Registration Id"; Text[150])
        {
            Caption = 'Tax Registration Id';
            DataClassification = CustomerContent;
        }
        field(13; "Recipient"; Text[100])
        {
            Caption = 'Recipient';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Idx1; "Company SystemId") { }
    }
}
