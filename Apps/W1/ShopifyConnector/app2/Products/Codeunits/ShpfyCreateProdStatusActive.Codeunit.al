/// <summary>
/// Codeunit Shpfy CreateProdStatusActive (ID 30172) implements Interface Shpfy.ICreateProductStatusValue.
/// </summary>
codeunit 30172 "Shpfy CreateProdStatusActive" implements "Shpfy ICreateProductStatusValue"
{
    /// <summary>
    /// GetStatus.
    /// </summary>
    /// <param name="Item">Record Item.</param>
    /// <returns>Return value of type enum "Shopify Product Status".</returns>
    procedure GetStatus(Item: Record Item): enum "Shpfy Product Status";
    begin
        exit(Enum::"Shpfy Product Status"::Active);
    end;
}
