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
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'This information is available in Shopify Order Header table.';
        }
        field(7; "Presentment Amount"; Decimal)
        {
            Caption = 'Presentment Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; "Rate %"; Decimal)
        {
            Caption = 'Rate %';
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
        OrderTaxLine: Record "Shpfy Order Tax Line";
    begin
        if "Line No." = 0 then begin
            OrderTaxLine.SetRange("Parent Id", "Parent Id");
            if OrderTaxLine.FindLast() then
                "Line No." := OrderTaxLine."Line No." + 1
            else
                "Line No." := 1;
        end;
    end;
}