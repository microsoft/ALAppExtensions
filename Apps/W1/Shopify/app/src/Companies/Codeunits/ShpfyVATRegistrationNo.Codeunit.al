namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy VAT Registration No. (ID 30368) implements Interface Shpfy Tax Registration Id Mapping.
/// </summary>
codeunit 30368 "Shpfy VAT Registration No." implements "Shpfy Tax Registration Id Mapping"
{
    Access = Internal;

    procedure GetTaxRegistrationId(var Customer: Record Customer): Text[150];
    begin
        exit(Customer."VAT Registration No.");
    end;

    procedure SetMappingFiltersForCustomers(var Customer: Record Customer; CompanyLocation: Record "Shpfy Company Location")
    begin
        Customer.SetRange("VAT Registration No.", CompanyLocation."Tax Registration Id");
    end;
}