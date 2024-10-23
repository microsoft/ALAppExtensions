namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Sales Channel (ID 30159).
/// </summary>
table 30159 "Shpfy Sales Channel"
{
    Caption = 'Shpfy Sales Channel';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            Editable = false;
            ToolTip = 'The unique identifier of the sales channel.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            Editable = false;
            ToolTip = 'The name of the sales channel.';
        }
        field(3; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            Editable = false;
            ToolTip = 'The code of the shop.';
        }
        field(4; "Use for publication"; Boolean)
        {
            Caption = 'Use for publication';
            ToolTip = 'Indicates if the sales channel is used for new products publication.';
        }
        field(5; Default; Boolean)
        {
            Caption = 'Default';
            Editable = false;
            ToolTip = 'Indicates if the sales channel is the default one. Used for new products publication if any other channel is chosen.';
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
