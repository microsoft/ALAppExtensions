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
        field(9; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
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
