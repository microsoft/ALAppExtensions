namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

codeunit 30368 "Shpfy VAT Tax Registration No." implements "Shpfy Tax Registration Id Mapping"
{
    procedure GetTaxRegistrationId(var Customer: Record Customer): Text;
    begin
        exit(Customer."VAT Registration No.");
    end;

    procedure SetMappingFiltersForCustomers(var Customer: Record Customer; CompanyLocation: Record "Shpfy Company Location")
    begin
        Customer.SetRange("VAT Registration No.", CompanyLocation."Tax Registration Id");
    end;
}

