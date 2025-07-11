codeunit 148162 "SE local Company Information"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;


    [Test]
    procedure RegisteredOfficeInfoOnCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO] Check that "Registered Office Info" and "Plus Giro Number" fields on Company Information exists.

        // [GIVEN] Company Information with SE Core extension
        CompanyInformation.Get();

        // [WHEN] open Company Information page
        CompanyInformationPage.OpenView();

        // [THEN] Verify fields and values are available on Company Information Page.
        CompanyInformationPage."Registered Office Info".AssertEquals(CompanyInformation."Registered Office Info");
        CompanyInformationPage."Plus Giro Number".AssertEquals(CompanyInformation."Plus Giro Number");
    end;

    [Test]
    procedure RegisteredOfficeWithAlphaNumericCharacter()
    var
        CompanyInformation: Record "Company Information";
        RegisteredOfficeLbl: Label '@#$123$#@***';
    begin
        // [GIVEN] Company Information with SE Core extension
        CompanyInformation.Get();

        // [WHEN] assign value to "Registered Office Info" field
        CompanyInformation.Validate("Registered Office Info", RegisteredOfficeLbl);
        CompanyInformation.Modify();

        // [THEN] Verify Registered Office field of Company Information accept Special and Numeric Character.
        CompanyInformation.TestField("Registered Office Info", RegisteredOfficeLbl);
    end;

    [Test]
    procedure RegisteredOfficeLengthError()
    var
        CompanyInformation: Record "Company Information";
        RegisteredOfficeLbl: Label '@#$123$#@***@#$123$#@***@#$123$#@***@#$123$#@***';
        StringLengthErr: Label 'The length of the string is %1, but it must be less than or equal to 20 characters.', Locked = true;
        TextCount: Integer;
    begin
        // [SCENARIO] verify that Registered Office field on Company Information exists and cannot accept input of length > 20.

        CompanyInformation.Get();
        TextCount := StrLen(RegisteredOfficeLbl);

        // [WHEN] assign value with length more than 20 to "Registered Office Info" field
        asserterror CompanyInformation.Validate("Registered Office Info", RegisteredOfficeLbl);

        // [THEN] Verify Maximum field length Error.
        Assert.ExpectedError(StrSubstNo(StringLengthErr, TextCount));
    end;
}