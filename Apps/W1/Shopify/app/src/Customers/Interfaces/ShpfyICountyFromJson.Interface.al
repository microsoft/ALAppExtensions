namespace Microsoft.Integration.Shopify;

interface "Shpfy ICounty From Json"
{
    Access = Internal;

    procedure County(JAddressObject: JsonObject): Text;
}