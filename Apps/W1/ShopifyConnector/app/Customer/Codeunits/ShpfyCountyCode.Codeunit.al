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
}