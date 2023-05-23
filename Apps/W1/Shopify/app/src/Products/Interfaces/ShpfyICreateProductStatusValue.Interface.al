/// <summary>
/// Interface "Shpfy ICreateProductStatusValue."
/// </summary>
interface "Shpfy ICreateProductStatusValue"
{
    Access = Internal;

    /// <summary>
    /// GetStatus.
    /// </summary>
    /// <param name="Item">Record Item.</param>
    /// <returns>Return value of type Enum "Shopify Product Status".</returns>
    procedure GetStatus(Item: Record Item): Enum "Shpfy Product Status";
}
