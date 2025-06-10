codeunit 139542 "Shpfy Company Locations Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestHttpRequestPolicy = BlockOutboundRequests;

    var
        ShpfyCompanyLocation: Record "Shpfy Company Location";
        Customer: Record Customer;
        IsInitialized: Boolean;
        ResponseResourceUrl: Text;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure TestCreateCompanyLocationSuccess()
    var
        ShpfyCompany: Record "Shpfy Company";
        ShpfyCompanyAPI: Codeunit "Shpfy Company API";
        ShpfyCompanies: TestPage "Shpfy Companies";
    begin
        // [Given] A valid customer and company location setup
        this.Initialize();
        ShpfyCompany.GetBySystemId(this.ShpfyCompanyLocation."Company SystemId");
        // [When] CreateCompanyLocation is called
        ShpfyCompanyAPI.CreateCompanyLocation(this.ShpfyCompanyLocation, this.Customer);

        // [Then] Company location should be created successfully
        this.ShpfyCompanyLocation.SetRange("Customer Id", this.Customer.SystemId);
        this.ShpfyCompanyLocation.FindFirst();
        ShpfyCompanies.OpenEdit();
        ShpfyCompanies.GoToRecord(ShpfyCompany);
        ShpfyCompanies.Locations.GoToRecord(this.ShpfyCompanyLocation);
    end;

    [Test]
    procedure TestCreateCompanyLocationCustomerAlreadyExportedAsCompany()
    var
        ShpfyCompany: Record "Shpfy Company";
        ShpfySkippedRecord: Record "Shpfy Skipped Record";
        LibraryAssert: Codeunit "Library Assert";
        ShpfyCompanyAPI: Codeunit "Shpfy Company API";
    begin
        // [Given] Customer already exported as a company
        this.Initialize();
        ShpfyCompany.GetBySystemId(this.ShpfyCompanyLocation."Company SystemId");
        ShpfyCompany."Customer SystemId" := Customer.SystemId;
        ShpfyCompany.Modify(true);

        // [When] CreateCompanyLocation is called
        ShpfyCompanyAPI.CreateCompanyLocation(this.ShpfyCompanyLocation, this.Customer);

        // [Then] Operation should be skipped and record should be logged as skipped
        ShpfySkippedRecord.SetRange("Table ID", Database::Customer);
        ShpfySkippedRecord.SetRange("Record ID", this.Customer.RecordId);
        LibraryAssert.IsTrue(ShpfySkippedRecord.FindFirst(), 'Expected skipped record to be logged');
        LibraryAssert.IsTrue(ShpfySkippedRecord."Skipped Reason".Contains('already exported as a company'), 'Expected reason to mention already exported as company');
    end;

    [Test]
    procedure TestCreateCompanyLocationCustomerAlreadyExportedAsLocation()
    var
        ShpfySkippedRecord: Record "Shpfy Skipped Record";
        LibraryAssert: Codeunit "Library Assert";
        ShpfyCompanyAPI: Codeunit "Shpfy Company API";
    begin
        // [Given] Customer already exported as a location
        this.Initialize();
        this.ShpfyCompanyLocation."Customer Id" := Customer.SystemId;
        this.ShpfyCompanyLocation.Modify(true);

        // [When] CreateCompanyLocation is called
        ShpfyCompanyAPI.CreateCompanyLocation(this.ShpfyCompanyLocation, this.Customer);

        // [Then] Operation should be skipped and record should be logged as skipped
        ShpfySkippedRecord.SetRange("Table ID", Database::Customer);
        ShpfySkippedRecord.SetRange("Record ID", this.Customer.RecordId);
        LibraryAssert.IsTrue(ShpfySkippedRecord.FindFirst(), 'Expected skipped record to be logged');
        LibraryAssert.IsTrue(ShpfySkippedRecord."Skipped Reason".Contains('already exported as a location'), 'Expected reason to mention already exported as location');
    end;

    internal procedure Initialize()
    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyCompany: Record "Shpfy Company";
        ShpfyCompanyInitialize: Codeunit "Shpfy Company Initialize";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        AccessToken: SecretText;
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Shpfy Company Locations Test");
        ClearLastError();
        this.ResponseResourceUrl := 'Companies/CompanyLocations.txt';
        if this.IsInitialized then
            exit;

        LibraryRandom.Init();
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Shpfy Company Locations Test");
        this.IsInitialized := true;
        Commit();

        ShpfyShop := InitializeTest.CreateShop();
        ShpfyShop."B2B Enabled" := true;
        ShpfyShop.Modify();

        CommunicationMgt.SetTestInProgress(false);
        this.ShpfyCompanyLocation := ShpfyCompanyInitialize.CreateShopifyCompanyLocation();
        ShpfyCompany.GetBySystemId(this.ShpfyCompanyLocation."Company SystemId");
        ShpfyCompany."Shop Code" := ShpfyShop.Code;
        ShpfyCompany.Modify(false);

        LibrarySales.CreateCustomer(this.Customer);
        AccessToken := LibraryRandom.RandText(20);
        InitializeTest.RegisterAccessTokenForShop(ShpfyShop.GetStoreName(), AccessToken);

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Shpfy Company Locations Test");
    end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        this.MakeResponse(Response);
        exit(false); // Prevents actual HTTP call
    end;

    local procedure MakeResponse(var HttpResponseMessage: TestHttpResponseMessage): Boolean
    begin
        this.LoadResourceIntoHttpResponse(ResponseResourceUrl, HttpResponseMessage);
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
    end;
}