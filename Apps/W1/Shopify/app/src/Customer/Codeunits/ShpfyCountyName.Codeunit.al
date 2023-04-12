/// <summary>
/// Codeunit Shpfy County Name (ID 30109) implements Interface Shpfy ICounty.
/// </summary>
codeunit 30109 "Shpfy County Name" implements "Shpfy ICounty"
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
        exit(CopyStr(CustomerAddress."Province Name".Trim(), 1, MaxStrLen(Customer.County)));
    end;
}