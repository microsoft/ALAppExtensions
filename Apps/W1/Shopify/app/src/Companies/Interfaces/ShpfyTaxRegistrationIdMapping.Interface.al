namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Interface "Shpfy Tax Registration Id Mapping"
/// </summary>
interface "Shpfy Tax Registration Id Mapping"
{
    /// <summary>
    /// Returns the tax registration id for the customer.
    /// </summary>
    /// <param name="Customer">Customer record</param>
    /// <returns>Tax registration id</returns>
    procedure GetTaxRegistrationId(var Customer: Record Customer): Text[150];

    /// <summary>
    /// Sets the tax registration mapping filters for the customer.
    /// </summary>
    /// <param name="Customer">Customer record</param>
    /// <param name="CompanyLocation">Company location record</param>
    procedure SetMappingFiltersForCustomers(var Customer: Record Customer; CompanyLocation: Record "Shpfy Company Location");
}