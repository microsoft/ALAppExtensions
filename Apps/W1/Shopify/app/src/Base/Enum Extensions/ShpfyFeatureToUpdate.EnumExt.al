#if not CLEAN22
namespace Microsoft.Integration.Shopify;

using System.Environment.Configuration;

enumextension 30101 "Shpfy Feature To Update" extends "Feature To Update"
{
    value(30101; ShopifyNewCustomerItemTemplates)
    {
        Implementation = "Feature Data Update" = "Shpfy Templates";
        ObsoleteReason = 'Feature "Shopify new customer an item templates" will be enabled by default in version 25';
        ObsoleteState = Pending;
        ObsoleteTag = '22.0';
    }
}
#endif