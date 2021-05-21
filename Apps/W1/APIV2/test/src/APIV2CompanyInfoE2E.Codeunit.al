codeunit 139806 "APIV2 - Company Info. E2E"
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
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 204030] User can get the company information that has non-empty values for complex type field address.
        Initialize();

        // [GIVEN] The company information record exists and has values assigned to the fields contained in complex types.
        CompanyInformation.Get();

        // [WHEN] The user calls GET for the given Company Information.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CompanyInformation.SystemId, Page::"APIV2 - Company Information", ServiceNameTxt);
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
        CompanyInformation.Get();
        CompanyInformation.Name := LibraryUtility.GenerateGUID();
        ModifiedName := CompanyInformation.Name;
        RequestBody := GetSimpleCompanyInformationJSON(CompanyInformation);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CompanyInformation.SystemId, Page::"APIV2 - Company Information", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response text contains the new values.
        VerifyPropertyInJSON(Response, 'displayName', ModifiedName);

        // [THEN] The record in the database contains the new values.
        CompanyInformation.Get();
        CompanyInformation.TestField(Name, ModifiedName);
    end;

    local procedure VerifyCompanyInformationProperties(CompanyInformationJSON: Text; var CompanyInformation: Record "Company Information")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformationRecordRef: RecordRef;
        EnterpriseNoFieldRef: FieldRef;
        TaxRegistrationNumber: Text;
    begin
        Assert.AreNotEqual('', CompanyInformationJSON, EmptyJSONErr);
        GeneralLedgerSetup.Get();

        VerifyPropertyInJSON(CompanyInformationJSON, 'displayName', CompanyInformation.Name);
        VerifyPropertyInJSON(CompanyInformationJSON, 'phoneNumber', CompanyInformation."Phone No.");
        VerifyPropertyInJSON(CompanyInformationJSON, 'faxNumber', CompanyInformation."Fax No.");
        VerifyPropertyInJSON(CompanyInformationJSON, 'email', CompanyInformation."E-Mail");
        VerifyPropertyInJSON(CompanyInformationJSON, 'website', CompanyInformation."Home Page");

        TaxRegistrationNumber := CompanyInformation."VAT Registration No.";
        CompanyInformationRecordRef.GetTable(CompanyInformation);
        if CompanyInformationRecordRef.FieldExist(11310) then begin
            EnterpriseNoFieldRef := CompanyInformationRecordRef.Field(11310);
            if (EnterpriseNoFieldRef.Type = FieldType::Text) and (EnterpriseNoFieldRef.Name = 'Enterprise No.') then
                TaxRegistrationNumber := EnterpriseNoFieldRef.Value();
        end;

        VerifyPropertyInJSON(CompanyInformationJSON, 'taxRegistrationNumber', TaxRegistrationNumber);
        VerifyPropertyInJSON(CompanyInformationJSON, 'industry', CompanyInformation."Industrial Classification");
        VerifyPropertyInJSON(CompanyInformationJSON, 'currencyCode', GeneralLedgerSetup."LCY Code");
        VerifyPropertyInJSON(CompanyInformationJSON, 'addressLine1', CompanyInformation.Address);
        VerifyPropertyInJSON(CompanyInformationJSON, 'addressLine2', CompanyInformation."Address 2");
        VerifyPropertyInJSON(CompanyInformationJSON, 'city', CompanyInformation.City);
        VerifyPropertyInJSON(CompanyInformationJSON, 'state', CompanyInformation.County);
        VerifyPropertyInJSON(CompanyInformationJSON, 'country', CompanyInformation."Country/Region Code");
        VerifyPropertyInJSON(CompanyInformationJSON, 'postalCode', CompanyInformation."Post Code");
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, StrSubstNo(WrongPropertyValueErr, PropertyName));
    end;

    local procedure GetSimpleCompanyInformationJSON(var CompanyInformation: Record "Company Information") CompanyInformationJSON: Text
    begin
        if CompanyInformation.Name = '' then
            CompanyInformation.Name := LibraryUtility.GenerateGUID();

        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON('', 'displayName', CompanyInformation.Name);
        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON(CompanyInformationJSON, 'addressLine1', CompanyInformation.Address);
        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON(CompanyInformationJSON, 'addressLine2', CompanyInformation."Address 2");
        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON(CompanyInformationJSON, 'city', CompanyInformation.City);
        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON(CompanyInformationJSON, 'state', CompanyInformation.County);
        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON(CompanyInformationJSON, 'country', CompanyInformation."Country/Region Code");
        CompanyInformationJSON := LibraryGraphMgt.AddPropertytoJSON(CompanyInformationJSON, 'postalCode', CompanyInformation."Post Code");
    end;
}















