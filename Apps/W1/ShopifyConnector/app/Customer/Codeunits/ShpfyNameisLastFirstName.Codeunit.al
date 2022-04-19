/// <summary>
/// Codeunit Shpfy Name is Last. FirstName" (ID 30122) implements Interface Shpfy ICustomer Name.
/// </summary>
codeunit 30122 "Shpfy Name is Last. FirstName" implements "Shpfy ICustomer Name"
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
        Name: Text;
    begin
        Name := LastName.Trim() + ' ' + FirstName.Trim();
        exit(CopyStr(Name.Trim(), 1, MaxStrLen(Customer.Name)));
    end;
}