namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy County Code (ID 30108) implements Interface Shpfy ICounty.
/// </summary>
codeunit 30108 "Shpfy County Code" implements "Shpfy ICounty"
{
    Access = Internal;

    /// <summary> 
    /// Description for County.
    /// </summary>
    /// <param name="CustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure County(CustomerAddress: Record "Shpfy Customer Address"): Text
    var
        Customer: Record Customer;
    begin
        exit(CopyStr(CustomerAddress."Province Code", 1, MaxStrLen(Customer.County)));
    end;

    /// <summary> 
    /// Description for County.
    /// </summary>
    /// <param name="CompanyLocation">Parameter of type Record "Shopify Company Location".</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure County(CompanyLocation: Record "Shpfy Company Location"): Text
    var
        Customer: Record Customer;
    begin
        exit(CopyStr(CompanyLocation."Province Code", 1, MaxStrLen(Customer.County)));
    end;
}