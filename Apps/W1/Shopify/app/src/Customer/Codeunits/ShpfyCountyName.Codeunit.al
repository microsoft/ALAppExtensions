/// <summary>
/// Codeunit Shpfy County Name (ID 30109) implements Interface Shpfy ICounty.
/// </summary>
codeunit 30109 "Shpfy County Name" implements "Shpfy ICounty"
{
    Access = Internal;

    /// <summary> 
    /// Description for County.
    /// </summary>
    /// <param name="ShpfyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure County(ShpfyCustomerAddress: Record "Shpfy Customer Address"): Text
    var
        Customer: Record Customer;
    begin
        exit(CopyStr(ShpfyCustomerAddress."Province Name".Trim(), 1, MaxStrLen(Customer.County)));
    end;
}