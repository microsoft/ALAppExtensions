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
            ToolTip = 'The name of the sales channel.';
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
