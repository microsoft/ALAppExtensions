/// <summary>
/// Enum Shpfy Name Source (ID 30108) implements Interface Shpfy ICustomer Name.
/// </summary>
enum 30108 "Shpfy Name Source" implements "Shpfy ICustomer Name"
{
    Extensible = true;
    DefaultImplementation = "Shpfy ICustomer Name" = "Shpfy Name = ''";

    value(0; CompanyName)
    {
        Caption = 'Company Name';
        Implementation = "Shpfy ICustomer Name" = "Shpfy Name = CompanyName";
    }
    value(1; FirstAndLastName)
    {
        Caption = 'First Name and Last Name';
        Implementation = "Shpfy ICustomer Name" = "Shpfy Name = First. LastName";
    }
    value(2; LastAndFirstName)
    {
        Caption = 'Last Name and First Name';
        Implementation = "Shpfy ICustomer Name" = "Shpfy Name = Last. FirstName";
    }
    value(3; None)
    {
        Caption = 'None';
        Implementation = "Shpfy ICustomer Name" = "Shpfy Name = ''";
    }
}
