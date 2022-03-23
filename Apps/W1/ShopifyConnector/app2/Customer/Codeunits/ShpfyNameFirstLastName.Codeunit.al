/// <summary>
/// Codeunit Shpfy Name = First. LastName (ID 30121) implements Interface Shpfy ICustomer Name.
/// </summary>
codeunit 30121 "Shpfy Name = First. LastName" implements "Shpfy ICustomer Name"
{
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
        Name := FirstName.Trim() + ' ' + LastName.Trim();
        exit(CopyStr(Name.Trim(), 1, MaxStrLen(Customer.Name)));
    end;
}