namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Sales Channel (ID 30159).
/// </summary>
table 30160 "Shpfy Sales Channel"
{
    Caption = 'Shopify Sales Channel';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            Editable = false;
            ToolTip = 'Specifies the unique identifier of the sales channel.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            Editable = false;
            ToolTip = 'Specifies the name of the sales channel.';
        }
        field(3; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            Editable = false;
            ToolTip = 'Specifies the code of the shop.';
        }
        field(4; "Use for publication"; Boolean)
        {
            Caption = 'Use for publication';
            ToolTip = 'Specifies if the sales channel is used for new products publication.';
        }
        field(5; Default; Boolean)
        {
            Caption = 'Default';
            Editable = false;
            ToolTip = 'Specifies if the sales channel is the default one. Used for new products publication if no other channel is selected';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}
