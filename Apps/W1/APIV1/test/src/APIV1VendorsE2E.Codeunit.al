codeunit 139703 "APIV1 - Vendors E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Vendor]
    end;

    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'vendors';
        VendorKeyPrefixTxt: Label 'GRAPHVENDOR';
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
    procedure TestGetSimpleVendor()
    var
        Vendor: Record "Vendor";
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 201343] User can get a simple vendor with a GET request to the service.
        Initialize();

        // [GIVEN] A vendor exists in the system.
        CreateSimpleVendor(Vendor);

        // [WHEN] The user makes a GET request for a given Vendor.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response text contains the vendor information.
        VerifyVendorSimpleProperties(ResponseText, Vendor);
    end;

    [Test]
    procedure TestGetVendorWithComplexType()
    var
        Vendor: Record "Vendor";
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 201343] User can get a vendor that has non-empty values for complex type fields.
        Initialize();

        // [GIVEN] A vendor exists and has values assigned to some of the fields contained in complex types.
        CreateVendorWithAddress(Vendor);

        // [WHEN] The user calls GET for the given Vendor.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response text contains the Vendor information.
        VerifyVendorSimpleProperties(ResponseText, Vendor);
        VerifyVendorAddress(ResponseText, Vendor);
    end;

    [Test]
    procedure TestCreateSimpleVendor()
    var
        Vendor: Record "Vendor";
        TempVendor: Record "Vendor" temporary;
        VendorJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 201343] Create an vendor through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a simple vendor JSON object to send to the service.
        VendorJSON := GetSimpleVendorJSON(TempVendor);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, VendorJSON, ResponseText);

        // [THEN] The response text contains the vendor information.
        VerifyVendorSimpleProperties(ResponseText, TempVendor);

        // [THEN] The vendor has been created in the database.
        Vendor.GET(TempVendor."No.");
        VerifyVendorSimpleProperties(ResponseText, Vendor);
    end;

    [Test]
    procedure TestCreateVendorWithComplexType()
    var
        Vendor: Record "Vendor";
        VendorWithComplexTypeJSON: Text;
        TargetURL: Text;
        ResponseTxt: Text;
    begin
        // [SCENARIO 201343] Create a vendor with a complex type through a POST method and check if it was created
        Initialize();

        // [GIVEN] A payment term
        COMMIT();

        // [GIVEN] A JSON text with an vendor that has the Address as a property
        VendorWithComplexTypeJSON := GetVendorWithAddressJSON(Vendor);

        // [WHEN] The user posts the consructed object to the APIV1 - Vendors endpoint.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, VendorWithComplexTypeJSON, ResponseTxt);

        // [THEN] The response contains the values of the vendor created.
        VerifyVendorSimpleProperties(ResponseTxt, Vendor);
        VerifyVendorAddress(ResponseTxt, Vendor);
    end;

    [Test]
    procedure TestCreateVendorWithTemplate()
    var
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        TempVendor: Record "Vendor" temporary;
        Vendor: Record "Vendor";
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Template]
        // [SCENARIO 201343] User can create a new vendor and have the system apply a template.
        Initialize();
        LibraryInventory.CreatePaymentTerms(PaymentTerms);
        LibraryInventory.CreatePaymentMethod(PaymentMethod);

        // [GIVEN] A template selection rule exists to set the payment terms based on the payment method.
        WITH Vendor DO
            LibraryGraphMgt.CreateSimpleTemplateSelectionRule(ConfigTmplSelectionRules, PAGE::"APIV1 - Vendors", DATABASE::Vendor,
              FIELDNO("Payment Method Code"), PaymentMethod.Code,
              FIELDNO("Payment Terms Code"), PaymentTerms.Code);

        // [GIVEN] The user has constructed a vendor object containing a templated payment method code.
        CreateSimpleVendor(TempVendor);
        TempVendor."Payment Method Code" := PaymentMethod.Code;

        RequestBody := GetSimpleVendorJSON(TempVendor);
        RequestBody := LibraryGraphMgt.AddPropertytoJSON(RequestBody, 'paymentMethodId', PaymentMethod.SystemId);
        RequestBody := LibraryGraphMgt.AddPropertytoJSON(RequestBody, 'paymentTermsId', PaymentTerms.SystemId);

        // [WHEN] The user sends the request to the endpoint in a POST request.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response contains the sent vendor values and also the updated Payment Terms
        TempVendor."Payment Terms Code" := PaymentTerms.Code;
        VerifyVendorSimpleProperties(ResponseText, TempVendor);
        VerifyVendorAddress(ResponseText, Vendor);

        // [THEN] The vendor is created in the database with the payment terms set from the template.
        Vendor.GET(TempVendor."No.");
        VerifyVendorSimpleProperties(ResponseText, Vendor);
        VerifyVendorAddress(ResponseText, Vendor);

        // Cleanup
        ConfigTmplSelectionRules.DELETE(TRUE);
    end;

    [Test]
    procedure TestModifyVendor()
    var
        Vendor: Record "Vendor";
        TempVendor: Record "Vendor" temporary;
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 201343] User can modify a vendor through a PATCH request.
        Initialize();

        // [GIVEN] A vendor exists.
        CreateSimpleVendor(Vendor);
        TempVendor.TRANSFERFIELDS(Vendor);
        TempVendor.Name := LibraryUtility.GenerateGUID();
        RequestBody := GetSimpleVendorJSON(TempVendor);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response text contains the new values.
        VerifyVendorSimpleProperties(ResponseText, TempVendor);

        // [THEN] The record in the database contains the new values.
        Vendor.GET(Vendor."No.");
        VerifyVendorSimpleProperties(ResponseText, Vendor);
    end;

    [Test]
    procedure TestVendorModifyWithComplexTypes()
    var
        Vendor: Record "Vendor";
        TempVendor: Record "Vendor" temporary;
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 201343] User can modify a complex type in a vendor through a PATCH request.
        Initialize();

        // [GIVEN] A vendor exists with an address.
        CreateVendorWithAddress(Vendor);
        TempVendor.TRANSFERFIELDS(Vendor);

        // Create modified address
        RequestBody := GetVendorWithAddressJSON(TempVendor);

        // [WHEN] The user makes a patch request to the service and specifies Address field.
        COMMIT();        // Need to commit transaction to unlock integration record table.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response contains the new values.
        VerifyVendorSimpleProperties(ResponseText, TempVendor);
        VerifyVendorAddress(ResponseText, Vendor);

        // [THEN] The vendor in the database contains the updated values.
        Vendor.GET(Vendor."No.");
        VerifyVendorAddress(ResponseText, Vendor);
    end;

    [Test]
    procedure TestRemoveComplexTypeFromVendor()
    var
        Vendor: Record "Vendor";
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 201343] User can clear the values encapsulated in a complex type by specifying null.
        Initialize();

        // [GIVEN] A Vendor exists with a specific address.
        CreateVendorWithAddress(Vendor);
        RequestBody := '{ "address" : null }';

        // [WHEN] A user makes a PATCH request to the specific vendor.
        COMMIT(); // Need to commit in order to unlock integration record table.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response contains the updated vendor.
        Vendor.GET(Vendor."No.");
        VerifyVendorSimpleProperties(ResponseText, Vendor);

        // [THEN] The Vendor's address
        VerifyVendorAddress(ResponseText, Vendor);
    end;

    [Test]
    procedure TestDeleteVendor()
    var
        Vendor: Record "Vendor";
        VendorNo: Code[20];
        TargetURL: Text;
        Responsetext: Text;
    begin
        // [SCENARIO 201343] User can delete a vendor by making a DELETE request.
        Initialize();

        // [GIVEN] A vendor exists.
        CreateSimpleVendor(Vendor);
        VendorNo := Vendor."No.";

        // [WHEN] The user makes a DELETE request to the endpoint for the vendor.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, PAGE::"APIV1 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Responsetext);

        // [THEN] The response is empty.
        Assert.AreEqual('', Responsetext, 'DELETE response should be empty.');

        // [THEN] The vendor is no longer in the database.
        Vendor.SetRange("No.", VendorNo);
        Assert.IsTrue(Vendor.IsEmpty(), 'Vendor should be deleted.');
    end;

    local procedure CreateSimpleVendor(var Vendor: Record "Vendor")
    begin
        Vendor.INIT();
        Vendor."No." := GetNextVendorID();
        Vendor.Name := LibraryUtility.GenerateGUID();
        Vendor.INSERT(TRUE);

        COMMIT();
    end;

    local procedure CreateVendorWithAddress(var Vendor: Record "Vendor")
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.FINDFIRST();
        CreateSimpleVendor(Vendor);
        Vendor.Address := LibraryUtility.GenerateGUID();
        Vendor."Address 2" := LibraryUtility.GenerateGUID();
        Vendor.City := LibraryUtility.GenerateGUID();
        Vendor.County := LibraryUtility.GenerateGUID();
        Vendor."Country/Region Code" := CountryRegion.Code;
        Vendor.MODIFY(TRUE);
    end;

    local procedure GetNextVendorID(): Text[20]
    var
        Vendor: Record "Vendor";
    begin
        Vendor.SETFILTER("No.", STRSUBSTNO('%1*', VendorKeyPrefixTxt));
        IF Vendor.FINDLAST() THEN
            EXIT(INCSTR(Vendor."No."));

        EXIT(COPYSTR(VendorKeyPrefixTxt + '00001', 1, 20));
    end;

    local procedure GetSimpleVendorJSON(var Vendor: Record "Vendor") SimpleVendorJSON: Text
    var
        CustomerJson: Text;
    begin
        IF Vendor."No." = '' THEN
            Vendor."No." := GetNextVendorID();
        IF Vendor.Name = '' THEN
            Vendor.Name := LibraryUtility.GenerateGUID();
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'number', Vendor."No.");
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'displayName', Vendor.Name);
        SimpleVendorJSON := CustomerJson;
    end;

    local procedure VerifyVendorSimpleProperties(VendorJSON: Text; Vendor: Record "Vendor")
    begin
        Assert.AreNotEqual('', VendorJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(VendorJSON);
        VerifyPropertyInJSON(VendorJSON, 'number', Vendor."No.");
        VerifyPropertyInJSON(VendorJSON, 'displayName', Vendor.Name);
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, STRSUBSTNO(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyVendorAddress(VendorJSON: Text; var Vendor: Record "Vendor")
    begin
        WITH Vendor DO
            LibraryGraphMgt.VerifyAddressProperties(VendorJSON, Address, "Address 2", City, County, "Country/Region Code", "Post Code");
    end;

    local procedure GetVendorWithAddressJSON(var Vendor: Record "Vendor") Json: Text
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        AddressJson: Text;
    begin
        Json := GetSimpleVendorJSON(Vendor);
        WITH Vendor DO
            GraphMgtComplexTypes.GetPostalAddressJSON(Address, "Address 2", City, County, "Country/Region Code", "Post Code", AddressJson);
        Json := LibraryGraphMgt.AddComplexTypetoJSON(Json, 'address', AddressJson);
    end;
}

































