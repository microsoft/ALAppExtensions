codeunit 139866 "APIV2 - Contacts E2E"
{
    // version Test,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Api] [Contact]
    end;

    var
        Assert: Codeunit Assert;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryMarketing: Codeunit "Library - Marketing";
        IsInitialized: Boolean;
        EmptyJSONErr: Label 'JSON should not be empty.';
        ServiceNameTxt: Label 'contacts';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetSimpleContact()
    var
        Contact: Record "Contact";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get a simple contact with a GET request to the service.
        Initialize();
        NoSeriesManagement.GetNextNo(SetupContactNumberSeries(), WorkDate(), true);

        // [GIVEN] A contact exists in the system.
        CreateSimpleContact(Contact);

        // [WHEN] The user makes a GET request for a given Contact.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Contact.SystemId, Page::"APIV2 - Contacts", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the Contact information.
        VerifySimpleProperties(Response, Contact);
    end;

    [Test]
    procedure TestGetContactWithAddressAndSpecialCharacters()
    var
        Contact: Record "Contact";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184717] User can get a Contact that has non-empty values for complex type fields.
        Initialize();
        NoSeriesManagement.GetNextNo(SetupContactNumberSeries(), WorkDate(), true);

        // [GIVEN] A Contact exists and has values assigned to some of the fields contained in complex types.
        CreateContactWithAddress(Contact);
        Contact.Address := 'Test "Adress" 12æ åø"';
        Contact.Modify();
        Commit();

        // [WHEN] The user calls GET for the given Contact.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Contact.SystemId, Page::"APIV2 - Contacts", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the Contact information.
        VerifySimpleProperties(Response, Contact);
    end;

    // [Test]
    procedure TestCreateDetailedContact()
    var
        Contact: Record "Contact";
        TempContact: Record "Contact" temporary;
        ContactJSON: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO 184717] User can create a new Contact through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a detailed Contact JSON object to send to the service
        ContactJSON := GetComplexContactJSON(TempContact);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Contacts", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, ContactJSON, Response);

        // [THEN] The Contact has been created in the database with all the details
        Contact.Get(TempContact."No.");
        VerifyComplexProperties(Response, Contact);
    end;

    [Test]
    procedure TestModifyContactWithAddress()
    var
        Contact: Record "Contact";
        TempContact: Record "Contact" temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184717] User can modify address in a Contact through a PATCH request.
        Initialize();
        NoSeriesManagement.GetNextNo(SetupContactNumberSeries(), WorkDate(), true);

        // [GIVEN] A Contact exists with an address.
        CreateContactWithAddress(Contact);
        TempContact.TransferFields(Contact);
        TempContact.Address := LibraryUtility.GenerateGUID();
        TempContact.City := LibraryUtility.GenerateGUID();
        RequestBody := GetSimpleContactJSON(TempContact);

        // [WHEN] The user makes a patch request to the service and specifies address fields.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Contact.SystemId, Page::"APIV2 - Contacts", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the new values.
        VerifySimpleProperties(Response, TempContact);

        // [THEN] The Contact in the database contains the updated values.
        Contact.Get(Contact."No.");
        VerifySimpleProperties(Response, TempContact);
    end;

    [Test]
    procedure TestDeleteContact()
    var
        Contact: Record "Contact";
        CustNo: Code[20];
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO 184717] User can delete a Contact by making a DELETE request.
        Initialize();

        // [GIVEN] A Contact exists.
        CreateSimpleContact(Contact);
        CustNo := Contact."No.";

        // [WHEN] The user makes a DELETE request to the endpoint for the Contact.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Contact.SystemId, Page::"APIV2 - Contacts", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The Contact is no longer in the database.
        Contact.SetRange("No.", CustNo);
        Assert.IsTrue(Contact.IsEmpty(), 'Contact should be deleted.');
    end;

    local procedure CreateContactWithAddress(var Contact: Record "Contact")
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.FindFirst();
        CreateSimpleContact(Contact);
        Contact.Address := LibraryUtility.GenerateGUID();
        Contact."Address 2" := LibraryUtility.GenerateGUID();
        Contact.City := LibraryUtility.GenerateGUID();
        Contact.County := LibraryUtility.GenerateGUID();
        Contact."Country/Region Code" := CountryRegion.Code;
        Contact.Modify(true);
        Commit();
    end;

    local procedure CreateSimpleContact(var Contact: Record "Contact")
    begin
        LibraryMarketing.CreateCompanyContact(Contact);
        Commit();  // Need to commit in order to unlock tables and allow web service to pick up changes.
    end;

    local procedure GetSimpleContactJSON(var Contact: Record "Contact") ContactJson: Text
    var
        NoSeriesManagement: Codeunit "NoSeriesManagement";
    begin
        if Contact."No." = '' then
            Contact."No." := NoSeriesManagement.GetNextNo(SetupContactNumberSeries(), WorkDate(), false);
        if Contact.Name = '' then
            Contact.Name := LibraryUtility.GenerateGUID();
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'number', Contact."No.");
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'displayName', Contact.Name);
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'companyName', Contact."Company Name");
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'addressLine1', Contact.Address);
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'addressLine2', Contact."Address 2");
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'city', Contact.City);
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'state', Contact.County);
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'country', Contact."Country/Region Code");
        ContactJson := LibraryGraphMgt.AddPropertytoJSON(ContactJson, 'postalCode', Contact."Post Code");
        exit(ContactJson)
    end;

    local procedure VerifySimpleProperties(JSON: Text; Contact: Record "Contact")
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'number', Contact."No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'displayName', Contact.Name);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'companyName', Contact."Company Name");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'addressLine1', Contact.Address);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'addressLine2', Contact."Address 2");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'city', Contact.City);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'state', Contact.County);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'country', Contact."Country/Region Code");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'postalCode', Contact."Post Code");
#if not CLEAN19
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'businessRelation', Contact."Business Relation");
#endif
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'contactBusinessRelation', Format(Contact."Contact Business Relation"));
    end;

    local procedure GetComplexContactJSON(var Contact: Record "Contact"): Text
    var
        LineJSON: Text;
    begin
        LineJSON := GetSimpleContactJSON(Contact);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'phoneNumber', Contact."Phone No.");
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'mobilePhoneNumber', Contact."Mobile Phone No.");
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'email', Contact."E-Mail");
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'website', Contact."Home Page");
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'type', Format(Contact.Type));
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'searchName', Contact."Search Name");
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, 'privacyBlocked', false);
        exit(LineJSON)
    end;

    local procedure VerifyComplexProperties(JSON: Text; Contact: Record "Contact")
    begin
        VerifySimpleProperties(JSON, Contact);

        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'phoneNumber', Contact."Phone No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'mobilePhoneNumber', Contact."Mobile Phone No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'email', Contact."E-Mail");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'website', Contact."Home Page");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'type', Format(Contact.Type));
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'searchName', Contact."Search Name");
        Assert.IsFalse(Contact."Privacy Blocked", 'Privacy Blocked should be false');
    end;

    procedure SetupContactNumberSeries(): Code[20]
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        MarketingSetup.Get();
        if MarketingSetup."Contact Nos." = '' then
            MarketingSetup.Validate("Contact Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        MarketingSetup.Modify(true);
        exit(MarketingSetup."Contact Nos.");
    end;

}
