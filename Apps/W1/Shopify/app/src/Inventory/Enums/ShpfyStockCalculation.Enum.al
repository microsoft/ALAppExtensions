/// <summary>
/// Enum Shpfy Inventory Policy (ID 30135).
/// </summary>
enum 30135 "Shpfy Stock Calculation" implements "Shpfy Stock Calculation"
{
    Caption = 'Shopify Stock Calculation"';
    Extensible = true;
    DefaultImplementation = "Shpfy Stock Calculation" = "Shpfy Disabled Value";
    value(0; Disabled)
    {
        Caption = 'Disabled';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Disabled Value";
    }

    value(1; "Projected Available Balance Today")
    {
        Caption = 'Projected Available Balance at Today';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Balance Today";
    }
}

