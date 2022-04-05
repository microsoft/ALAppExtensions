/// <summary>
/// Codeunit Shpfy Name = '' (ID 30119) implements Interface Shpfy ICustomer Name.
/// </summary>
codeunit 30119 "Shpfy Name = ''" implements "Shpfy ICustomer Name"
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
    begin
    end;
}