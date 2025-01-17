namespace Microsoft.Integration.Shopify;

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
#if not CLEANSCHEMA28
        field(5; Display; Boolean)
        {
            Caption = 'Display';
            DataClassification = SystemMetadata;
            Editable = false;
            ObsoleteReason = 'This field is not imported.';
#if not CLEAN25
            ObsoleteState = Pending;
            ObsoleteTag = '25.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '28.0';
#endif
        }
#endif
        field(6; Provider; Text[512])
        {
            Caption = 'Provider';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; Sentiment; Enum "Shpfy Assessment Sentiment")
        {
            Caption = 'Sentiment';
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
