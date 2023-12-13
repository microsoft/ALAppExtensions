namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy County Source (ID 30104) implements Interface Shpfy ICounty.
/// </summary>
enum 30104 "Shpfy County Source" implements "Shpfy ICounty", "Shpfy ICounty From Json"
{
    Caption = 'Shopify County Source';
    Extensible = false;
    DefaultImplementation = "Shpfy ICounty" = "Shpfy County Name";

    value(0; Code)
    {
        Caption = 'Code';
        Implementation = "Shpfy ICounty" = "Shpfy County Code",
                         "Shpfy ICounty From Json" = "Shpfy County From Json Code";
    }
    value(1; Name)
    {
        Caption = 'Name';
        Implementation = "Shpfy ICounty" = "Shpfy County Name",
                         "Shpfy ICounty From Json" = "Shpfy County From Json Name";
    }

}
