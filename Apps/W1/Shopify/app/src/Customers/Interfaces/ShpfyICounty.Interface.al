namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface "Shpfy ICounty."
/// </summary>
interface "Shpfy ICounty"
{
    Access = Internal;

    /// <summary> 
    /// Description for County.
    /// </summary>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return variable "Text".</returns>
    procedure County(ShopifyCustomerAddress: Record "Shpfy Customer Address"): Text;

    /// <summary> 
    /// Description for County.
    /// </summary>
    /// <param name="ShopifyCompanyLocation">Parameter of type Record "Shopify Company Location".</param>
    /// <returns>Return variable "Text".</returns>
    procedure County(ShopifyCompanyLocation: Record "Shpfy Company Location"): Text;
}