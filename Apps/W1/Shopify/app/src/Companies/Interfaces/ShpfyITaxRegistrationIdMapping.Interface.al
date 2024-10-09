namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Interface "Shpfy Tax Registration Id Mapping"
/// </summary>
interface "Shpfy Tax Registration Id Mapping"
{
    procedure GetTaxRegistrationId(var Customer: Record Customer): Text;

    procedure SetMappingFiltersForCustomers(var Customer: Record Customer; CompanyLocation: Record "Shpfy Company Location");
}