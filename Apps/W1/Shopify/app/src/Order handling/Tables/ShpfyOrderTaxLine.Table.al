/// <summary>
/// Table Shpfy Order Tax Line (ID 30122).
/// </summary>
table 30122 "Shpfy Order Tax Line"
{
    Access = Internal;
    Caption = 'Shopify Order Tax Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Parent Id"; BigInteger)
        {
            Caption = 'Parent Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; Title; Code[20])
        {
            Caption = 'Title';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Parent Id", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        TaxLine: Record "Shpfy Order Tax Line";
    begin
        if "Line No." = 0 then begin
            TaxLine.SetRange("Parent Id", "Parent Id");
            if TaxLine.FindLast() then
                "Line No." := TaxLine."Line No." + 1
            else
                "Line No." := 1;
        end;
    end;
}
