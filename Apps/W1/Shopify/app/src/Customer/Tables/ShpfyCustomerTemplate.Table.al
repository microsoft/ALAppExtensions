/// <summary>
/// Table Shpfy Customer Template (ID 30107).
/// </summary>
table 30107 "Shpfy Customer Template"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Shopify Customer Template';

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shop Code';
            TableRelation = "Shpfy Shop";
            ValidateTableRelation = true;
        }

        field(2; "Country/Region Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Country/Region Code';
        }

        field(3; "Customer Template Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Template code';
            TableRelation = "Config. Template Header".Code where("Table Id" = const(18));
            ValidateTableRelation = true;
        }
        field(4; "Default Customer No."; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Customer No.';
            TableRelation = Customer."No.";
            ValidateTableRelation = true;
        }
    }

    keys
    {
        key(PK; "Shop Code", "Country/Region Code")
        {
            Clustered = true;
        }
    }
}