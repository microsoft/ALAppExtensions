/// <summary>
/// Codeunit Shpfy RemoveProductDoNothing (ID 30183) implements Interface Shpfy IRemoveProductAction.
/// </summary>
codeunit 30183 "Shpfy RemoveProductDoNothing" implements "Shpfy IRemoveProductAction"
{
    /// <summary>
    /// RemoveProductAction.
    /// </summary>
    /// <param name="Product">VAR Record "Shopify Product".</param>
    procedure RemoveProductAction(var Product: Record "Shpfy Product")
    begin
    end;
}
