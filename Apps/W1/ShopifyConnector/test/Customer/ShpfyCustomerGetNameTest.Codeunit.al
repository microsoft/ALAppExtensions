/// <summary>
/// Codeunit Shpfy Customer GetName Test (ID 30506).
/// </summary>
codeunit 30506 "Shpfy Customer GetName Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCustomerGetName()
    var
        ICustomerName: Interface "Shpfy ICustomer Name";
        FirstName: Label 'First Name', Locked = true;
        LastName: Label 'Last Name', Locked = true;
        CompanyName: Label 'Company Name', Locked = true;
    begin
        // [SCENARIO] Get the right name based on the enum value of "Shpfy Name Source"

        // [GIVEN] "Shpfy Name Source"::CompanyName
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::CompanyName;
        // [THEN] The rsult must be CompanyName
        Assert.AreEqual(CompanyName, ICustomerName.GetName(FirstName, LastName, CompanyName), '"Shpfy Name Source"::CompanyName');

        // [GIVEN] "Shpfy Name Source"::FirstAndLastName
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::FirstAndLastName;
        // [THEN] The rsult must be FirstName + ' ' + LastName
        Assert.AreEqual(FirstName + ' ' + LastName, ICustomerName.GetName(FirstName, LastName, CompanyName), '"Shpfy Name Source"::FirstAndLastName');

        // [GIVEN] "Shpfy Name Source"::LastAndFirstName
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::LastAndFirstName;
        // [THEN] The rsult must be LastName + ' ' + FirstName
        Assert.AreEqual(LastName + ' ' + FirstName, ICustomerName.GetName(FirstName, LastName, CompanyName), '"Shpfy Name Source"::LastAndFirstName');

        // [GIVEN] "Shpfy Name Source"::None
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::None;
        // [THEN] The rsult must be a empty string
        Assert.AreEqual('', ICustomerName.GetName(FirstName, LastName, CompanyName), '"Shpfy Name Source"::None');
    end;
}
