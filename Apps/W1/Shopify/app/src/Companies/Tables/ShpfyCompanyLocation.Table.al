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
        field(13; "Recipient"; Text[100])
        {
            Caption = 'Company/Attention';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the recipient name for the company location.';
        }
        field(14; "Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the location is the default location for the company.';
        }
        field(15; "Shpfy Payment Terms Id"; BigInteger)
        {
            Caption = 'Shopify Payment Terms Id';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the Shopify Payment Terms Id which is mapped with Customer''s Payment Terms.';
        }
        field(16; "Company Name"; Text[500])
        {
            Caption = 'Company Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Company".Name where(SystemId = field("Company SystemId")));
            ToolTip = 'Specifies the name of the company.';
        }
        field(17; "Shpfy Payment Term"; Text[150])
        {
            Caption = 'Shopify Payment Term';
            FieldClass = FlowField;
            CalcFormula = lookup("Shpfy Payment Terms".Description where(Id = field("Shpfy Payment Terms Id")));
            ToolTip = 'Specifies the description of the Shopify Payment Term.';
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
