codeunit 139706 "APIV1 - Company Info. E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Company Information]
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'companyInformation';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';

    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;
        COMMIT();
    end;

    [Test]
    procedure TestGetCompanyInformationWithComplexType()
    var
        CompanyInformation: Record "Company Information";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 204030] User can get the company information that has non-empty values for complex type field address.
        Initialize();

        // [GIVEN] The company information record exists and has values assigned to the fields contained in complex types.
        CompanyInformation.GET();

        // [WHEN] The user calls GET for the given Company Information.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CompanyInformation.SystemId, PAGE::"APIV1 - Company Information", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the Company Information.
        VerifyCompanyInformationProperties(Response, CompanyInformation);
    end;

    [Test]
    procedure TestModifyCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        ModifiedName: Text;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 204030] User can modify a company information through a PATCH request.
        Initialize();

        // [Given] A company information exists.
        CompanyInformation.GET();
        CompanyInformation.Name := LibraryUtility.GenerateGUID();
        ModifiedName := CompanyInformation.Name;
        RequestBody := GetSimpleCompanyInformationJSON(CompanyInformation);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CompanyInformation.SystemId, PAGE::"APIV1 - Company Information", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response text contains the new values.
        VerifyPropertyInJSON(Response, 'displayName', ModifiedName);

        // [THEN] The record in the database contains the new values.
        CompanyInformation.GET();
        CompanyInformation.TESTFIELD(Name, ModifiedName);
    end;

    [Test]
    procedure TestModifyCompanyInformationWithComplexType()
    var
        CompanyInformation: Record "Company Information";
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 204030] User can modify a complex type in a company information through a PATCH request.
        Initialize();

        // [GIVEN] A company information record exists with an address.
        CompanyInformation.GET();
        CompanyInformation.Address := LibraryUtility.GenerateGUID();
        CompanyInformation."Address 2" := LibraryUtility.GenerateGUID();
        RequestBody := GetCompanyInformationWithAddressJSON(CompanyInformation);

        // [WHEN] The user makes a patch request to the service and specifies address fields.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CompanyInformation.SystemId, PAGE::"APIV1 - Company Information", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the new values.
        VerifyAddressIncompanyInformation(Response, CompanyInformation);

        // [THEN] The company information in the database contains the updated values.
        CompanyInformation.GET();
        VerifyAddressIncompanyInformation(Response, CompanyInformation);
    end;

    [Test]
    procedure TestRemoveComplexTypeFromCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        TargetURL: Text;
        RequestBody: Text;
        Response: Text;
    begin
        // [SCENARIO 204030] User can clear the values encapsulated in a complex type by specifying null.
        Initialize();

        // [GIVEN] A company information exists with an address.
        CompanyInformation.GET();
        RequestBody := '{ "address" : null }';

        // [WHEN] A user makes a PATCH request to the company information.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CompanyInformation.SystemId, PAGE::"APIV1 - Company Information", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the updated company information.
        CompanyInformation.GET();
        VerifyAddressIncompanyInformation(Response, CompanyInformation);

        // [THEN] The company information address fields are empty.
        CompanyInformation.TESTFIELD(Address, '');
        CompanyInformation.TESTFIELD("Address 2", '');
        CompanyInformation.TESTFIELD(City, '');
        CompanyInformation.TESTFIELD(County, '');
        CompanyInformation.TESTFIELD("Country/Region Code", '');
        CompanyInformation.TESTFIELD("Post Code", '');
    end;

    local procedure VerifyCompanyInformationProperties(CompanyInformationJSON: Text; var CompanyInformation: Record "Company Information")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        Assert.AreNotEqual('', CompanyInformationJSON, EmptyJSONErr);
        GeneralLedgerSetup.GET();

        VerifyPropertyInJSON(CompanyInformationJSON, 'displayName', CompanyInformation.Name);
        VerifyPropertyInJSON(CompanyInformationJSON, 'phoneNumber', CompanyInformation."Phone No.");
        VerifyPropertyInJSON(CompanyInformationJSON, 'faxNumber', CompanyInformation."Fax No.");
        VerifyPropertyInJSON(CompanyInformationJSON, 'email', CompanyInformation."E-Mail");
        VerifyPropertyInJSON(CompanyInformationJSON, 'website', CompanyInformation."Home Page");
        VerifyPropertyInJSON(CompanyInformationJSON, 'taxRegistrationNumber', CompanyInformation."VAT Registration No.");
        VerifyPropertyInJSON(CompanyInformationJSON, 'industry', CompanyInformation."Industrial Classification");
        VerifyPropertyInJSON(CompanyInformationJSON, 'currencyCode', GeneralLedgerSetup."LCY Code");
        VerifyAddressIncompanyInformation(CompanyInformationJSON, CompanyInformation);
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, STRSUBSTNO(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyAddressIncompanyInformation(CompanyInfoJSON: Text; var CompanyInformation: Record "Company Information")
    begin
        WITH CompanyInformation DO
            LibraryGraphMgt.VerifyAddressProperties(CompanyInfoJSON, Address, "Address 2", City, County, "Country/Region Code", "Post Code");
    end;

    local procedure GetSimpleCompanyInformationJSON(var CompanyInformation: Record "Company Information") CompanyInformationJSON: Text
    begin
        IF CompanyInformation.Name = '' THEN
            CompanyInformation.Name := LibraryUtility.GenerateGUID();

        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON('', 'displayName', CompanyInformation.Name);
    end;

    local procedure GetCompanyInformationWithAddressJSON(var CompanyInformation: Record "Company Information") JSON: Text
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        AddressJSON: Text;
    begin
        JSON := GetSimpleCompanyInformationJSON(CompanyInformation);

        WITH CompanyInformation DO
            GraphMgtComplexTypes.GetPostalAddressJSON(Address, "Address 2", City, County, "Country/Region Code", "Post Code", AddressJSON);

        JSON := LibraryGraphMgt.AddComplexTypetoJSON(JSON, 'address', AddressJSON);
    end;
}















