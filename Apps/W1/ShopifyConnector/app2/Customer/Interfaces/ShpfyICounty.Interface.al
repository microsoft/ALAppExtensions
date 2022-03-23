/// <summary>
/// Interface "Shpfy ICounty."
/// </summary>
interface "Shpfy ICounty"
{
    /// <summary> 
    /// Description for County.
    /// </summary>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return variable "Text".</returns>
    procedure County(ShopifyCustomerAddress: Record "Shpfy Customer Address"): Text;
}