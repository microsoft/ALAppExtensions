/// <summary>
/// Enum Shpfy Create Product Status Value (ID 30129) implements Interface Shpfy ICreateProductStatusValue.
/// </summary>
enum 30129 "Shpfy Cr. Prod. Status Value" implements "Shpfy ICreateProductStatusValue"
{
    Caption = 'Shopify Create Product Status Value';
    Extensible = false;

    value(0; Active)
    {
        Caption = 'Active';
        Implementation = "Shpfy ICreateProductStatusValue" = "Shpfy CreateProdStatusActive";

    }
    value(1; Draft)
    {
        Caption = 'Draft';
        Implementation = "Shpfy ICreateProductStatusValue" = "Shpfy CreateProdStatusDraft";
    }
}
