namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Transaction Status (ID 30133).
/// </summary>
enum 30133 "Shpfy Transaction Status"
{
    Caption = 'Shopify Transaction Status';
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Failure)
    {
        Caption = 'Failure';
    }
    value(3; Success)
    {
        Caption = 'Success';
    }
    value(4; Error)
    {
        Caption = 'Error';
    }
    value(5; "Awaiting Response")
    {
        Caption = 'Awaiting Response';
    }
    value(6; "Unknown")
    {
        Caption = 'Unknown';
    }
}
