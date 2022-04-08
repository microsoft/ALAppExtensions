/// <summary>
/// Table Shpfy Order Risk (ID 30123).
/// </summary>
table 30123 "Shpfy Order Risk"
{
    Access = Internal;
    Caption = 'Shopify Order Risk';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Order Id"; BigInteger)
        {
            Caption = 'Order Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; Level; Enum "Shpfy Risk Level")
        {
            Caption = 'Level';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Message"; Text[512])
        {
            Caption = 'Message';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; Display; Boolean)
        {
            Caption = 'Display';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Order Id", "Line No.")
        {
            Clustered = true;
        }
    }

}
