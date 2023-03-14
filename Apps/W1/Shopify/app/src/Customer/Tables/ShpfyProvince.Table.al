/// <summary>
/// Table Shpfy Province (ID 30108).
/// </summary>
table 30108 "Shpfy Province"
{
    Access = Internal;
    Caption = 'Shopify Province';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Country/Region Id"; BigInteger)
        {
            Caption = 'Country/Region Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(3; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(4; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(5; Tax; Decimal)
        {
            Caption = 'Tax';
            DataClassification = CustomerContent;
        }

        field(6; "Tax Name"; Code[10])
        {
            Caption = 'Tax Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(7; "Tax Type"; enum "Shpfy Tax Type")
        {
            Caption = 'TaxType';
            DataClassification = CustomerContent;
        }

        field(8; "Tax Percentage"; Decimal)
        {
            Caption = 'Tax Percentage';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id, "Country/Region Id")
        {
            Clustered = true;
        }
    }
}