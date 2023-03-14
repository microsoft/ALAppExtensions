/// <summary>
/// Codeunit Shpfy Name is CompanyName (ID 30120) implements Interface Shpfy ICustomer Name.
/// </summary>
codeunit 30120 "Shpfy Name is CompanyName" implements "Shpfy ICustomer Name"
{
    Access = Internal;

    /// <summary> 
    /// Description for GetName.
    /// </summary>
    /// <param name="FirstName">Parameter of type Text.</param>
    /// <param name="LastName">Parameter of type Text.</param>
    /// <param name="CompanyName">Parameter of type Text.</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetName(FirstName: Text; LastName: Text; CompanyName: Text): Text
    var
        Customer: Record Customer;
    begin
        exit(CopyStr(CompanyName.Trim(), 1, MaxStrLen(Customer.Name)));
    end;
}