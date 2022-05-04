/// <summary>
/// Codeunit Shpfy CreateProdStatusDraft (ID 30173) implements Interface Shopify.ICreateProductStatusValue.
/// </summary>
codeunit 30173 "Shpfy CreateProdStatusDraft" implements "Shpfy ICreateProductStatusValue"
{
    Access = Internal;

    /// <summary>
    /// GetStatus.
    /// </summary>
    /// <param name="Item">Record Item.</param>
    /// <returns>Return value of type enum "Shopify Product Status".</returns>
    internal procedure GetStatus(Item: Record Item): enum "Shpfy Product Status";
    begin
        exit(Enum::"Shpfy Product Status"::Draft);
    end;
}
