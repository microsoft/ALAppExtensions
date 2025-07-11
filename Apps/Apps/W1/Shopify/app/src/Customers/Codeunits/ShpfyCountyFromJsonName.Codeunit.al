namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

codeunit 30239 "Shpfy County From Json Name" implements "Shpfy ICounty From Json"
{
    Access = Internal;

    internal procedure County(JAddressObject: JsonObject): Text
    var
        Customer: Record Customer;
        JsonHelper: Codeunit "Shpfy Json Helper";
    begin
        exit(CopyStr(JsonHelper.GetValueAsText(JAddressObject, 'province').Trim(), 1, MaxStrLen(Customer.County)));
    end;
}