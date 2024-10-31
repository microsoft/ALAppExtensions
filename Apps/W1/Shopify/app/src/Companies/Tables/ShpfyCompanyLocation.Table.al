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
            ToolTip = 'Specifies the unique identifier for the company location in Shopify.';
        }
        field(2; "Company SystemId"; Guid)
        {
            Caption = 'Company SystemId';
            DataClassification = SystemMetadata;
            Editable = false;
            ToolTip = 'Specifies the unique identifier for the company in Shopify.';
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the address of the company location.';
        }
        field(4; "Address 2"; Text[100])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the second address line of the company location.';
        }
        field(5; Zip; Code[20])
        {
            Caption = 'Zip';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the postal code of the company location.';
        }
        field(6; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the city of the company location.';
        }
        field(7; "Country/Region Code"; Code[2])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the country/region code of the company location.';
        }
        field(8; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the phone number of the company location.';
        }
        field(9; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the name of the company location.';
        }
        field(10; "Province Code"; Code[10])
        {
            Caption = 'Province';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the province code of the company location.';
        }
        field(11; "Province Name"; Text[50])
        {
            Caption = 'Province Name';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the province name of the company location.';
        }
        field(12; "Tax Registration Id"; Text[150])
        {
            Caption = 'Tax Registration Id';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the tax registration identifier of the company location.';
        }
        field(13; "Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the location is the default location for the company.';
        }
        field(14; "Shpfy Payment Terms Id"; BigInteger)
        {
            Caption = 'Shpfy Payment Terms Id';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Shopify Payment Terms Id which is mapped with Customer''s Payment Terms.';
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
