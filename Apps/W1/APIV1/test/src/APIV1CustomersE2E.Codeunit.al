codeunit 139702 "APIV1 - Customers E2E"
{
    // version Test,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Customer]
    end;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        CustomerNoPrefixTxt: Label 'GRAPHCUSTOMER';
        EmptyJSONErr: Label 'JSON should not be empty.';
        ServiceNameTxt: Label 'customers';
        PhoneNumberNameTxt: Label 'phoneNumber';
        EmailNameTxt: Label 'email';
        WebsiteNameTxt: Label 'website';
        TaxLiableNameTxt: Label 'taxLiable';
        TaxAreaIdNameTxt: Label 'taxAreaId';
        CurrencyCodeNameTxt: Label 'currencyCode';
        PaymentTermsIdNameTxt: Label 'paymentTermsId';
        ShipmentMethodIdNameTxt: Label 'shipmentMethodId';
        PaymentMethodIdNameTxt: Label 'paymentMethodId';
        BlockedNameTxt: Label 'blocked';

    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;
        COMMIT();
    end;

    [Test]
    procedure TestGetSimpleCustomer()
    var
        Customer: Record "Customer";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184717] User can get a simple customer with a GET request to the service.
        Initialize();

        // [GIVEN] A customer exists in the system.
        CreateSimpleCustomer(Customer);

        // [WHEN] The user makes a GET request for a given Customer.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Customer.SystemId, PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the customer information.
        VerifySimpleProperties(Response, Customer);
    end;

    [Test]
    procedure TestGetCustomerWithComplexType()
    var
        Customer: Record "Customer";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184717] User can get a customer that has non-empty values for complex type fields.
        Initialize();

        // [GIVEN] A customer exists and has values assigned to some of the fields contained in complex types.
        CreateCustomerWithAddress(Customer);
        Commit();

        // [WHEN] The user calls GET for the given Customer.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Customer.SystemId, PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the customer information.
        VerifySimpleProperties(Response, Customer);
        VerifyCustomerAddress(Response, Customer);
    end;

    [Test]
    procedure TestGetCustomerWithAddressAndSpecialCharacters()
    var
        Customer: Record "Customer";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184717] User can get a customer that has non-empty values for complex type fields.
        Initialize();

        // [GIVEN] A customer exists and has values assigned to some of the fields contained in complex types.
        CreateCustomerWithAddress(Customer);
        Customer.Address := 'Test "Adress" 12æ åø"';
        Customer.MODIFY();
        Commit();

        // [WHEN] The user calls GET for the given Customer.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Customer.SystemId, PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the customer information.
        VerifySimpleProperties(Response, Customer);
        VerifyCustomerAddress(Response, Customer);
    end;

    [Test]
    procedure TestCreateDetailedCustomer()
    var
        Customer: Record "Customer";
        Currency: Record "Currency";
        TaxArea: Record "Tax Area";
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        PaymentMethod: Record "Payment Method";
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        TaxAreaID: Guid;
        CustomerJSON: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO 184717] User can create a new Customer through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a detailed customer JSON object to send to the service
        IF GeneralLedgerSetup.UseVat() THEN BEGIN
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            TaxAreaID := VATBusinessPostingGroup.SystemId;
        END ELSE BEGIN
            TaxArea.CreateTaxArea(LibraryUtility.GenerateGUID(), '', '');
            TaxAreaID := TaxArea.SystemId;
        END;

        Assert.IsFalse(ISNULLGUID(TaxAreaID), 'Id was not generated for VAT / Sales Tax');
        LibraryERM.CreatePaymentTerms(PaymentTerms);
        CreateShipmentMethod(ShipmentMethod);
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        LibraryERM.CreateCurrency(Currency);

        CustomerJSON := GetComplexCustomerJSON(Customer, Currency, TaxAreaID, PaymentTerms, ShipmentMethod, PaymentMethod);
        COMMIT();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CustomerJSON, Response);

        // [THEN] The customer has been created in the database with all the details
        Customer.GET(Customer."No.");
        VerifyComplexProperties(Response, Customer, Currency, TaxAreaID, PaymentTerms, ShipmentMethod, PaymentMethod);
    end;

    [Test]
    procedure TestCreateCustomerWithComplexType()
    var
        TempCustomer: Record "Customer" temporary;
        Customer: Record "Customer";
        CustomerJson: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO 184717] User can create a new customer through a POST method and provide values for a complex type.
        Initialize();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Customers", ServiceNameTxt);

        // [GIVEN] The user has constructed a customer object containing the address field.
        CreateCustomerWithAddress(TempCustomer);
        CustomerJson := GetCustomerWithAddressJSON(TempCustomer);

        // [WHEN] The user posts the consructed object to the APIV1 - Customers endpoint.
        LibraryGraphMgt.PostToWebService(TargetURL, CustomerJson, Response);

        // [THEN] The response contains the values of the customer created.
        VerifySimpleProperties(Response, TempCustomer);
        VerifyCustomerAddress(Response, TempCustomer);

        // [THEN] And the customer is created in the database.
        Customer.GET(TempCustomer."No.");
        VerifySimpleProperties(Response, Customer);
        VerifyCustomerAddress(Response, Customer);
    end;

    [Test]
    procedure TestCreateCustomerWithTemplate()
    var
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        CountryRegion: Record "Country/Region";
        TempCustomer: Record "Customer" temporary;
        Customer: Record "Customer";
        CityName: Text[20];
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Template]
        // [SCENARIO 184717] User can create a new customer and have the system apply a template.
        Initialize();
        ConfigTmplSelectionRules.DELETEALL();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Customers", ServiceNameTxt);
        CountryRegion.FINDLAST();
        CityName := LibraryUtility.GenerateGUID();

        // [GIVEN] A template selection rule exists to set the city based on the country code.
        WITH Customer DO
            LibraryGraphMgt.CreateSimpleTemplateSelectionRule(ConfigTmplSelectionRules, PAGE::"APIV1 - Customers", DATABASE::Customer,
              FIELDNO("Country/Region Code"), CountryRegion.Code,
              FIELDNO(City), CityName);

        // [GIVEN] The user has constructed a customer object containing a templated country code.
        CreateSimpleCustomer(TempCustomer);
        TempCustomer."Country/Region Code" := CountryRegion.Code;
        RequestBody := GetCustomerWithAddressJSON(TempCustomer);

        // [WHEN] The user sends the request to the endpoint in a POST request.
        LibraryGraphMgt.PostToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the sent customer values and also the city.
        TempCustomer.City := CityName;
        VerifySimpleProperties(Response, TempCustomer);
        VerifyCustomerAddress(Response, TempCustomer);

        // [THEN] The customer is created in the database with the city set from the template.
        Customer.GET(TempCustomer."No.");
        VerifyCustomerAddress(Response, Customer);
    end;

    [Test]
    procedure TestDeleteCustomer()
    var
        Customer: Record "Customer";
        CustNo: Code[20];
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO 184717] User can delete a customer by making a DELETE request.
        Initialize();

        // [GIVEN] A customer exists.
        CreateSimpleCustomer(Customer);
        CustNo := Customer."No.";

        // [WHEN] The user makes a DELETE request to the endpoint for the customer.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Customer.SystemId, PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The customer is no longer in the database.
        Customer.SetRange("No.", CustNo);
        Assert.IsTrue(Customer.IsEmpty(), 'Customer should be deleted.');
    end;

    [Test]
    procedure TestModifyCustomer()
    var
        Customer: Record "Customer";
        TempCustomer: Record "Customer" temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184717] User can modify a customer through a PATCH request.
        Initialize();

        // [GIVEN] A customer exists.
        CreateSimpleCustomer(Customer);
        TempCustomer.TRANSFERFIELDS(Customer);
        TempCustomer.Name := LibraryUtility.GenerateGUID();
        RequestBody := GetSimpleCustomerJSON(TempCustomer);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Customer.SystemId, PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response text contains the new values.
        VerifySimpleProperties(Response, TempCustomer);

        // [THEN] The record in the database contains the new values.
        Customer.GET(Customer."No.");
        VerifySimpleProperties(Response, Customer);
    end;

    [Test]
    procedure TestModifyCustomerWithComplexType()
    var
        Customer: Record "Customer";
        TempCustomer: Record "Customer" temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184717] User can modify a complex type in a customer through a PATCH request.
        Initialize();

        // [GIVEN] A customer exists with an address.
        CreateCustomerWithAddress(Customer);
        TempCustomer.TRANSFERFIELDS(Customer);
        TempCustomer.Address := LibraryUtility.GenerateGUID();
        TempCustomer.City := LibraryUtility.GenerateGUID();
        RequestBody := GetCustomerWithAddressJSON(TempCustomer);

        // [WHEN] The user makes a patch request to the service and specifies address fields.
        COMMIT(); // Need to commit transaction to unlock integration record table.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Customer.SystemId, PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the new values.
        VerifySimpleProperties(Response, TempCustomer);
        VerifyCustomerAddress(Response, TempCustomer);

        // [THEN] The customer in the database contains the updated values.
        Customer.GET(Customer."No.");
        VerifyCustomerAddress(Response, Customer);
    end;

    [Test]
    procedure TestRemoveComplexTypeFromCustomer()
    var
        Customer: Record "Customer";
        TargetURL: Text;
        RequestBody: Text;
        Response: Text;
    begin
        // [SCENARIO 184717] User can clear the values encapsulated in a complex type by specifying null.
        Initialize();

        // [GIVEN] A customer exists with a specific address.
        CreateCustomerWithAddress(Customer);
        RequestBody := '{ "address" : null }';

        // [WHEN] A user makes a PATCH request to the specific customer.
        COMMIT(); // Need to commit in order to unlock integration record table.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Customer.SystemId, PAGE::"APIV1 - Customers", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the updated customer.
        Customer.GET(Customer."No.");
        VerifySimpleProperties(Response, Customer);
        VerifyCustomerAddress(Response, Customer);

        // [THEN] The customer's address fields are empty.
        Customer.TESTFIELD(Address, '');
        Customer.TESTFIELD("Address 2", '');
        Customer.TESTFIELD(City, '');
        Customer.TESTFIELD(County, '');
        Customer.TESTFIELD("Country/Region Code", '');
        Customer.TESTFIELD("Post Code", '');
    end;

    local procedure CreateCustomerWithAddress(var Customer: Record "Customer")
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.FINDFIRST();
        CreateSimpleCustomer(Customer);
        Customer.Address := LibraryUtility.GenerateGUID();
        Customer."Address 2" := LibraryUtility.GenerateGUID();
        Customer.City := LibraryUtility.GenerateGUID();
        Customer.County := LibraryUtility.GenerateGUID();
        Customer."Country/Region Code" := CountryRegion.Code;
        Customer.MODIFY(TRUE);
    end;

    local procedure CreateSimpleCustomer(var Customer: Record "Customer")
#if not CLEAN17
    var
        GraphMgtCustomer: Codeunit "Graph Mgt - Customer";
#endif
    begin
        Customer.INIT();
        Customer."No." := NextCustomerNo();
        Customer.Name := LibraryUtility.GenerateGUID();
        Customer.INSERT(TRUE);
#if not CLEAN17
        GraphMgtCustomer.UpdateIntegrationRecords(TRUE); // Currently need to do this as integration records aren't be created otherwise.
#endif
        Customer.GET(Customer."No.");

        COMMIT(); // Need to commit in order to unlock tables and allow web service to pick up changes.
    end;

    local procedure GetCustomerWithAddressJSON(var Customer: Record "Customer") Json: Text
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        AddressJson: Text;
    begin
        Json := GetSimpleCustomerJSON(Customer);
        WITH Customer DO
            GraphMgtComplexTypes.GetPostalAddressJSON(Address, "Address 2", City, County, "Country/Region Code", "Post Code", AddressJson);
        Json := LibraryGraphMgt.AddComplexTypetoJSON(Json, 'address', AddressJson);
    end;

    local procedure GetSimpleCustomerJSON(var Customer: Record "Customer"): Text
    var
        CustomerJson: Text;
    begin
        IF Customer."No." = '' THEN
            Customer."No." := NextCustomerNo();
        IF Customer.Name = '' THEN
            Customer.Name := LibraryUtility.GenerateGUID();
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'number', Customer."No.");
        CustomerJson := LibraryGraphMgt.AddPropertytoJSON(CustomerJson, 'displayName', Customer.Name);
        EXIT(CustomerJson)
    end;

    local procedure NextCustomerNo(): Code[20]
    var
        Customer: Record "Customer";
    begin
        Customer.SETFILTER("No.", STRSUBSTNO('%1*', CustomerNoPrefixTxt));
        IF Customer.FINDLAST() THEN
            EXIT(INCSTR(Customer."No."));

        EXIT(COPYSTR(CustomerNoPrefixTxt + '0001', 1, 20));
    end;

    local procedure GetComplexCustomerJSON(var Customer: Record "Customer"; Currency: Record "Currency"; TaxAreaID: Guid; PaymentTerms: Record "Payment Terms"; ShipmentMethod: Record "Shipment Method"; PaymentMethod: Record "Payment Method"): Text
    var
        LineJSON: Text;
    begin
        LineJSON := GetCustomerWithAddressJSON(Customer);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, PhoneNumberNameTxt, '123456789');
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, EmailNameTxt, 'a@b.com');
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, WebsiteNameTxt, 'microsoft.com');
        LineJSON := LibraryGraphMgt.AddComplexTypetoJSON(LineJSON, TaxLiableNameTxt, 'true');
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, TaxAreaIdNameTxt, LibraryGraphMgt.StripBrackets(TaxAreaID));
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, CurrencyCodeNameTxt, Currency.Code);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, PaymentTermsIdNameTxt, PaymentTerms.SystemId);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, ShipmentMethodIdNameTxt, ShipmentMethod.SystemId);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, PaymentMethodIdNameTxt, PaymentMethod.SystemId);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, BlockedNameTxt, FORMAT(Customer.Blocked::All));

        EXIT(LineJSON)
    end;

    local procedure VerifyComplexProperties(JSON: Text; Customer: Record "Customer"; Currency: Record "Currency"; TaxAreaID: Guid; PaymentTerms: Record "Payment Terms"; ShipmentMethod: Record "Shipment Method"; PaymentMethod: Record "Payment Method")
    begin
        VerifySimpleProperties(JSON, Customer);

        Assert.AreEqual('123456789', Customer."Phone No.", 'Customer should have the correct phone number.');
        Assert.AreEqual('a@b.com', Customer."E-Mail", 'Customer should have the correct email.');
        Assert.AreEqual('microsoft.com', Customer."Home Page", 'Customer should have the correct website.');
        Assert.AreEqual(TRUE, Customer."Tax Liable", 'Customer should have the correct ''tax liable'' information.');
        Assert.AreEqual(TaxAreaID, Customer."Tax Area ID", 'Customer should have the correct tax area id.');
        Assert.AreEqual(Currency.Code, Customer."Currency Code", 'Customer should have the correct currency code.');
        Assert.AreEqual(PaymentTerms.Code, Customer."Payment Terms Code", 'Customer should have the correct payment terms code.');
        Assert.AreEqual(ShipmentMethod.Code, Customer."Shipment Method Code", 'Customer should have the correct shipment method code.');
        Assert.AreEqual(PaymentMethod.Code, Customer."Payment Method Code", 'Customer should have the correct payment method.');
        Assert.AreEqual(
          FORMAT(Customer.Blocked::All), FORMAT(Customer.Blocked), 'Customer should have the correct ''blocked'' information');
    end;

    local procedure VerifyCustomerAddress(CustomerJSON: Text; var Customer: Record "Customer")
    begin
        WITH Customer DO
            LibraryGraphMgt.VerifyAddressProperties(CustomerJSON, Address, "Address 2", City, County, "Country/Region Code", "Post Code");
    end;

    local procedure VerifySimpleProperties(JSON: Text; Customer: Record "Customer")
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'number', Customer."No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'displayName', Customer.Name);
    end;

    local procedure CreateShipmentMethod(var ShipmentMethod: Record "Shipment Method")
    begin
        WITH ShipmentMethod DO BEGIN
            INIT();
            Code := LibraryUtility.GenerateRandomCode(FIELDNO(Code), DATABASE::"Shipment Method");
            Description := Code;
            INSERT(TRUE);
        END;
    end;
}





















































