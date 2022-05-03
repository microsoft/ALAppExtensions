codeunit 139803 "APIV2 - Vendors E2E"
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
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
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
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, Page::"APIV2 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response text contains the vendor information.
        VerifyVendorSimpleProperties(ResponseText, Vendor);
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
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, VendorJSON, ResponseText);

        // [THEN] The response text contains the vendor information.
        VerifyVendorSimpleProperties(ResponseText, TempVendor);

        // [THEN] The vendor has been created in the database.
        Vendor.Get(TempVendor."No.");
        VerifyVendorSimpleProperties(ResponseText, Vendor);
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
        with Vendor do
            LibraryGraphMgt.CreateSimpleTemplateSelectionRule(ConfigTmplSelectionRules, Page::"APIV2 - Vendors", Database::Vendor,
              FieldNo("Payment Method Code"), PaymentMethod.Code,
              FieldNo("Payment Terms Code"), PaymentTerms.Code);

        // [GIVEN] The user has constructed a vendor object containing a templated payment method code.
        CreateSimpleVendor(TempVendor);
        TempVendor."Payment Method Code" := PaymentMethod.Code;

        RequestBody := GetSimpleVendorJSON(TempVendor);
        RequestBody := LibraryGraphMgt.AddPropertytoJSON(RequestBody, 'paymentMethodId', PaymentMethod.SystemId);
        RequestBody := LibraryGraphMgt.AddPropertytoJSON(RequestBody, 'paymentTermsId', PaymentTerms.SystemId);

        // [WHEN] The user sends the request to the endpoint in a POST request.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response contains the sent vendor values and also the updated Payment Terms
        TempVendor."Payment Terms Code" := PaymentTerms.Code;
        VerifyVendorSimpleProperties(ResponseText, TempVendor);
        VerifyVendorAddress(ResponseText, Vendor);

        // [THEN] The vendor is created in the database with the payment terms set from the template.
        Vendor.Get(TempVendor."No.");
        VerifyVendorSimpleProperties(ResponseText, Vendor);
        VerifyVendorAddress(ResponseText, Vendor);

        // Cleanup
        ConfigTmplSelectionRules.DELETE(true);
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
        TempVendor.TransferFields(Vendor);
        TempVendor.Name := LibraryUtility.GenerateGUID();
        RequestBody := GetSimpleVendorJSON(TempVendor);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, Page::"APIV2 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response text contains the new values.
        VerifyVendorSimpleProperties(ResponseText, TempVendor);

        // [THEN] The record in the database contains the new values.
        Vendor.Get(Vendor."No.");
        VerifyVendorSimpleProperties(ResponseText, Vendor);
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
        TargetURL := LibraryGraphMgt.CreateTargetURL(Vendor.SystemId, Page::"APIV2 - Vendors", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Responsetext);

        // [THEN] The response is empty.
        Assert.AreEqual('', Responsetext, 'DELETE response should be empty.');

        // [THEN] The vendor is no longer in the database.
        Vendor.SetRange("No.", VendorNo);
        Assert.IsTrue(Vendor.IsEmpty(), 'Vendor should be deleted.');
    end;

    local procedure CreateSimpleVendor(var Vendor: Record "Vendor")
    begin
        Vendor.Init();
        Vendor."No." := GetNextVendorID();
        Vendor.Name := LibraryUtility.GenerateGUID();
        Vendor.Insert(true);

        Commit();
    end;

    local procedure GetNextVendorID(): Text[20]
    var
        Vendor: Record "Vendor";
    begin
        Vendor.SetFilter("No.", StrSubstNo('%1*', VendorKeyPrefixTxt));
        if Vendor.FindLast() then
            exit(IncStr(Vendor."No."));

        exit(CopyStr(VendorKeyPrefixTxt + '00001', 1, 20));
    end;

    local procedure GetSimpleVendorJSON(var Vendor: Record "Vendor") SimpleVendorJSON: Text
    var
        CustomerJson: Text;
    begin
        if Vendor."No." = '' then
            Vendor."No." := GetNextVendorID();
        if Vendor.Name = '' then
            Vendor.Name := LibraryUtility.GenerateGUID();
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'number', Vendor."No.");
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'displayName', Vendor.Name);
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'addressLine1', Vendor.Address);
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'addressLine2', Vendor."Address 2");
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'city', Vendor.City);
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'state', Vendor.County);
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'country', Vendor."Country/Region Code");
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'postalCode', Vendor."Post Code");
        SimpleVendorJSON := CustomerJson;
    end;

    local procedure VerifyVendorSimpleProperties(VendorJSON: Text; Vendor: Record "Vendor")
    begin
        Assert.AreNotEqual('', VendorJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(VendorJSON);
        VerifyPropertyInJSON(VendorJSON, 'number', Vendor."No.");
        VerifyPropertyInJSON(VendorJSON, 'displayName', Vendor.Name);
        VerifyPropertyInJSON(VendorJSON, 'addressLine1', Vendor.Address);
        VerifyPropertyInJSON(VendorJSON, 'addressLine2', Vendor."Address 2");
        VerifyPropertyInJSON(VendorJSON, 'city', Vendor.City);
        VerifyPropertyInJSON(VendorJSON, 'state', Vendor.County);
        VerifyPropertyInJSON(VendorJSON, 'country', Vendor."Country/Region Code");
        VerifyPropertyInJSON(VendorJSON, 'postalCode', Vendor."Post Code");
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, StrSubstNo(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyVendorAddress(VendorJSON: Text; var Vendor: Record "Vendor")
    begin
        with Vendor do
            LibraryGraphMgt.VerifyAddressProperties(VendorJSON, Address, "Address 2", City, County, "Country/Region Code", "Post Code");
    end;
}

































