/// <summary>
/// Codeunit Shpfy Customer GetName Test (ID 139584).
/// </summary>
codeunit 139584 "Shpfy Customer GetName Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCustomerGetName()
    var
        ICustomerName: Interface "Shpfy ICustomer Name";
        FirstNameLbl: Label 'First Name', Locked = true;
        LastNameLbl: Label 'Last Name', Locked = true;
        CompanyNameLbl: Label 'Company Name', Locked = true;
    begin
        // [SCENARIO] Get the right name based on the enum value of "Shpfy Name Source"

        // [GIVEN] "Shpfy Name Source"::CompanyName
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::CompanyName;
        // [THEN] The rsult must be CompanyName
        LibraryAssert.AreEqual(CompanyNameLbl, ICustomerName.GetName(FirstNameLbl, LastNameLbl, CompanyNameLbl), '"Shpfy Name Source"::CompanyName');

        // [GIVEN] "Shpfy Name Source"::FirstAndLastName
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::FirstAndLastName;
        // [THEN] The rsult must be FirstName + ' ' + LastName
        LibraryAssert.AreEqual(FirstNameLbl + ' ' + LastNameLbl, ICustomerName.GetName(FirstNameLbl, LastNameLbl, CompanyNameLbl), '"Shpfy Name Source"::FirstAndLastName');

        // [GIVEN] "Shpfy Name Source"::LastAndFirstName
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::LastAndFirstName;
        // [THEN] The rsult must be LastName + ' ' + FirstName
        LibraryAssert.AreEqual(LastNameLbl + ' ' + FirstNameLbl, ICustomerName.GetName(FirstNameLbl, LastNameLbl, CompanyNameLbl), '"Shpfy Name Source"::LastAndFirstName');

        // [GIVEN] "Shpfy Name Source"::None
        // [GIVEN] FirstName, LastName and CompanyName
        ICustomerName := "Shpfy Name Source"::None;
        // [THEN] The rsult must be a empty string
        LibraryAssert.AreEqual('', ICustomerName.GetName(FirstNameLbl, LastNameLbl, CompanyNameLbl), '"Shpfy Name Source"::None');
    end;
}
