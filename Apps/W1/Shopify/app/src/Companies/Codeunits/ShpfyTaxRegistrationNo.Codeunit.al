namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

codeunit 30367 "Shpfy Tax Registration No." implements "Shpfy Tax Registration Id Mapping"
{
    procedure GetTaxRegistrationId(var Customer: Record Customer): Text;
    begin
        exit(Customer."Registration Number");
    end;
}

