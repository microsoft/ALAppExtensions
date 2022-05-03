/// <summary>
/// Enum Shpfy County Source (ID 30104) implements Interface Shpfy ICounty.
/// </summary>
enum 30104 "Shpfy County Source" implements "Shpfy ICounty"
{
    Access = Internal;
    Caption = 'Shopify County Source';
    Extensible = true;
    DefaultImplementation = "Shpfy ICounty" = "Shpfy County Name";

    value(0; Code)
    {
        Caption = 'Code';
        Implementation = "Shpfy ICounty" = "Shpfy County Code";
    }
    value(1; Name)
    {
        Caption = 'Name';
        Implementation = "Shpfy ICounty" = "Shpfy County Name";
    }

}
