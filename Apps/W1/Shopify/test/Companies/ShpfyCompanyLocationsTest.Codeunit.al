// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;

codeunit 139539 "Shpfy Company Locations Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;
    TestHttpRequestPolicy = BlockOutboundRequests;

    var
        Shop: Record "Shpfy Shop";
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
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
        CompanyAPI: Codeunit "Shpfy Company API";
        ShopifyCompanies: TestPage "Shpfy Companies";
    begin
        // [Given] A valid customer and company location setup
        this.Initialize();
        ShopifyCompany.GetBySystemId(this.CompanyLocation."Company SystemId");
        // [When] CreateCompanyLocation is called
        CompanyAPI.SetCompany(ShopifyCompany);
        CompanyAPI.SetShop(Shop);
        CompanyAPI.CreateCompanyLocation(this.Customer);

        // [Then] Company location should be created successfully
#pragma warning disable AA0210
        this.CompanyLocation.SetRange("Customer Id", this.Customer.SystemId);
#pragma warning restore AA0210
        this.CompanyLocation.FindFirst();
        ShopifyCompanies.OpenEdit();
        ShopifyCompanies.GoToRecord(ShopifyCompany);
        ShopifyCompanies.Locations.GoToRecord(this.CompanyLocation);
    end;

    [Test]
    procedure TestCreateCompanyLocationCustomerAlreadyExportedAsCompany()
    var
        Company: Record "Shpfy Company";
        SkippedRecord: Record "Shpfy Skipped Record";
        LibraryAssert: Codeunit "Library Assert";
        CompanyAPI: Codeunit "Shpfy Company API";
    begin
        // [Given] Customer already exported as a company
        this.Initialize();
        Company.GetBySystemId(this.CompanyLocation."Company SystemId");
        Company."Customer SystemId" := Customer.SystemId;
        Company.Modify(true);
        // [Given] Ensure Shpfy Skipped Record is empty
        SkippedRecord.DeleteAll(false);

        // [When] CreateCompanyLocation is called
        CompanyAPI.SetCompany(Company);
        CompanyAPI.SetShop(Shop);
        CompanyAPI.CreateCompanyLocation(this.Customer);

        // [Then] Operation should be skipped and record should be logged as skipped
        SkippedRecord.SetRange("Table ID", Database::Customer);
        SkippedRecord.SetRange("Record ID", this.Customer.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Expected skipped record to be logged');
        LibraryAssert.IsTrue(SkippedRecord."Skipped Reason".Contains('already exported as a company'), 'Expected reason to mention already exported as company');
    end;

    [Test]
    procedure TestCreateCompanyLocationCustomerAlreadyExportedAsLocation()
    var
        SkippedRecord: Record "Shpfy Skipped Record";
        LibraryAssert: Codeunit "Library Assert";
        CompanyAPI: Codeunit "Shpfy Company API";
    begin
        // [Given] Customer already exported as a location
        this.Initialize();
        this.CompanyLocation."Customer Id" := Customer.SystemId;
        this.CompanyLocation.Modify(true);
        // [Given] Ensure the customer was not previously exported as a company
        ShopifyCompany.GetBySystemId(this.CompanyLocation."Company SystemId");
        Clear(this.ShopifyCompany."Customer SystemId");
        this.ShopifyCompany.Modify(false);
        // [Given] Ensure Shpfy Skipped Record is empty
        SkippedRecord.DeleteAll(false);

        // [When] CreateCompanyLocation is called
        CompanyAPI.SetCompany(ShopifyCompany);
        CompanyAPI.SetShop(Shop);
        CompanyAPI.CreateCompanyLocation(this.Customer);

        // [Then] Operation should be skipped and record should be logged as skipped
        SkippedRecord.SetRange("Table ID", Database::Customer);
        SkippedRecord.SetRange("Record ID", this.Customer.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Expected skipped record to be logged');
        LibraryAssert.IsTrue(SkippedRecord."Skipped Reason".Contains('already exported as a location'), 'Expected reason to mention already exported as location');
    end;

    internal procedure Initialize()
    var
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
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

        Shop := InitializeTest.CreateShop();
        Shop."B2B Enabled" := true;
        Shop.Modify();

        CommunicationMgt.SetTestInProgress(false);
        this.CompanyLocation := CompanyInitialize.CreateShopifyCompanyLocation();
        ShopifyCompany.GetBySystemId(this.CompanyLocation."Company SystemId");
        ShopifyCompany."Shop Code" := Shop.Code;
        ShopifyCompany.Modify(false);

        LibrarySales.CreateCustomer(this.Customer);
        AccessToken := LibraryRandom.RandText(20);
        InitializeTest.RegisterAccessTokenForShop(Shop.GetStoreName(), AccessToken);

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
