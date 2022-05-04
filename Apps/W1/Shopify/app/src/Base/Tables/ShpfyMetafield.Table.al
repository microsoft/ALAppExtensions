/// <summary>
/// Table Shpfy Metafield (ID 30101).
/// </summary>
table 30101 "Shpfy Metafield"
{
    Access = Internal;
    Caption = 'Shopify Metafield';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; Namespace; Text[100])
        {
            Caption = 'Namespace';
            DataClassification = SystemMetadata;
        }

        field(3; "Owner Resource"; Text[50])
        {
            Caption = 'Owner Resource';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                case "Owner Resource" of
                    'customer':
                        "Parent Table No." := Database::"Shpfy Customer";
                end;
            end;
        }

        field(4; "Owner Id"; BigInteger)
        {
            Caption = 'Owner Id';
            DataClassification = SystemMetadata;
        }


        field(5; Name; Text[30])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }

        field(6; "Value Type"; enum "Shpfy Metafield Value Type")
        {
            Caption = 'Value Type';
            DataClassification = CustomerContent;
        }

        field(7; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }

        field(101; "Parent Table No."; Integer)
        {
            Caption = 'Parent Table No.';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                case "Parent Table No." of
                    Database::"Shpfy Customer":
                        "Owner Resource" := 'customer';
                end;
            end;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    var
        Metafield: Record "Shpfy Metafield";
    begin
        if Namespace = '' then
            Namespace := 'Microsoft.Dynamics365.BusinessCentral';
        if Id = 0 then
            if Metafield.FindFirst() and (Metafield.Id < 0) then
                Id := Metafield.Id - 1
            else
                Id := -1;
    end;
}