/// <summary>
/// Enum Shpfy Create Product Status Value (ID 30129) implements Interface Shpfy ICreateProductStatusValue.
/// </summary>
enum 30129 "Shpfy Cr. Prod. Status Value" implements "Shpfy ICreateProductStatusValue"
{
    Access = Internal;
    Caption = 'Shopify Create Product Status Value';
    Extensible = true;
    DefaultImplementation = "Shpfy ICreateProductStatusValue" = "Shpfy CreateProdStatusActive";

    value(0; Active)
    {
        Caption = 'Active';
    }
    value(1; Draft)
    {
        Caption = 'Draft';
        Implementation = "Shpfy ICreateProductStatusValue" = "Shpfy CreateProdStatusDraft";
    }
}
