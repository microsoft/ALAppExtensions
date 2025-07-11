codeunit 136865 "Use Case Object Helper Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Use Case Object Helper] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestGetUseCaseID()
    var
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        UseCaseObjectHelper: Codeunit "Use Case Object Helper";
        ExpectedCaseID, CaseID, EmptyGuid : Guid;
    begin
        // [SCENARIO] To check if function is returning use case id if the name is passed

        // [GIVEN] There should be a record in tax use case table
        ExpectedCaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryUseCase.CreateUseCase('VAT', ExpectedCaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function GetUseCaseID is called
        CaseID := UseCaseObjectHelper.GetUseCaseID('Test Use Case');

        // [THEN] it should return the Case id of that use case
        Assert.AreEqual(ExpectedCaseID, CaseID, 'CaseId should be same');
    end;

    [Test]
    procedure TestGetUseCaseIDForError()
    var
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        UseCaseObjectHelper: Codeunit "Use Case Object Helper";
        ExpectedCaseID, CaseID, EmptyGuid : Guid;
        InvalidParentUseCaseErr: Label 'Parent Use Case :%1 does not exist', Comment = '%1= Parent Use Case Description';
    begin
        // [SCENARIO] To check if function is returning error if a false case id is passed

        // [GIVEN] There should be a record in tax use case table
        ExpectedCaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryUseCase.CreateUseCase('VAT', ExpectedCaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function GetUseCaseID is called with a false name
        asserterror CaseID := UseCaseObjectHelper.GetUseCaseID('Test Use CaseX');

        // [THEN] it should return a error message
        Assert.AreEqual(GetLastErrorText, StrSubstNo(InvalidParentUseCaseErr, 'Test Use CaseX'), 'Invalied error message');
    end;

    [Test]
    procedure TestGetUseCaseName()
    var
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        UseCaseObjectHelper: Codeunit "Use Case Object Helper";
        CaseID, EmptyGuid : Guid;
        ExpectedName: Text[2000];
    begin
        // [SCENARIO] To check if function is returning use case name if the id is passed

        // [GIVEN] There should be a record in tax use case table
        CaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function GetUseCaseID is called
        ExpectedName := UseCaseObjectHelper.GetUseCaseName(CaseID);

        // [THEN] it should return the description of that use case
        Assert.AreEqual('Test Use Case', ExpectedName, 'Description should be same');
    end;
}