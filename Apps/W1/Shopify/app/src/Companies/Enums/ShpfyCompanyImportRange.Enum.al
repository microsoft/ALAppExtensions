namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Company Import Range (ID 30149).
/// </summary>
enum 30149 "Shpfy Company Import Range"
{
    Caption = 'Shopify Company Import Range';
    Extensible = false;

    value(0; None)
    {
        Caption = 'None';
    }
    value(1; WithOrderImport)
    {
        Caption = 'With Order Import';
    }
    value(2; AllCompanies)
    {
        Caption = 'All Companies';
    }
}
