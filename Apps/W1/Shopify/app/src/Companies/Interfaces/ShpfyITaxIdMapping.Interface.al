namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

interface "Shpfy Tax Registration Id Mapping"
{
    procedure GetTaxRegistrationId(var Customer: Record Customer): Text;
}