// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.CRM.Team;
using Microsoft.Sales.Document;

codeunit 139551 "Shpfy Staff Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;
    TestHttpRequestPolicy = BlockOutboundRequests;

    var
        ShpfyShop: Record "Shpfy Shop";
        Any: Codeunit Any;
        OrdersAPISubscriber: Codeunit "Shpfy Orders API Subscriber";
        IsInitialized: Boolean;
        ResponseResourceUrl: Text;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure TestStaffMembersActionVisibleOnlyForB2BStore()
    var
        LibraryAssert: Codeunit "Library Assert";
        ShpfyShopCard: TestPage "Shpfy Shop Card";
    begin
        // [Given] Shop exists
        this.Initialize();

        // [When] Set store as not B2B and check action is not visible
        ShpfyShop."B2B Enabled" := false;
        ShpfyShop.Modify(false);
        ShpfyShopCard.OpenView();
        ShpfyShopCard.GoToRecord(ShpfyShop);

        // [Then] The action should not be visible
        LibraryAssert.IsFalse(ShpfyShopCard.StaffMembers.Visible(), 'Staff Members action should not be visible for non-B2B store');
        ShpfyShopCard.Close();

        // [When] Set store as B2B and check action is visible
        ShpfyShop."B2B Enabled" := true;
        ShpfyShop.Modify(false);
        ShpfyShopCard.OpenView();
        ShpfyShopCard.GoToRecord(ShpfyShop);

        // [Then] The action should be visible
        LibraryAssert.IsTrue(ShpfyShopCard.StaffMembers.Visible(), 'Staff Members action should be visible for B2B store');
        ShpfyShopCard.Close();
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure TestImportStaff()
    var
        StaffMember: Record "Shpfy Staff Member";
        ShpfyStaffMemberAPI: Codeunit "Shpfy Staff Member API";
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [Given] Staff exists in Shopify and is available for import
        this.Initialize();

        // [When] Staff is imported into BC
        ShpfyStaffMemberAPI.GetStaffMembers(ShpfyShop.Code);

        // [Then] Staff exists in BC
        LibraryAssert.IsTrue(StaffMember.Count() = 2, 'There should be 2 staff members imported into BC.');
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure TestImportDeletedStaffReflectsDeletion()
    var
        StaffMember: Record "Shpfy Staff Member";
        ShpfyStaffMemberAPI: Codeunit "Shpfy Staff Member API";
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [Given] Staff was deleted in Shopify
        this.Initialize();

        this.CreateNewStaffMember(ShpfyShop.Code, StaffMember);

        // [When] Staff is imported into BC
        ShpfyStaffMemberAPI.GetStaffMembers(ShpfyShop.Code);

        // [Then] Staff is deleted in BC
        LibraryAssert.IsTrue(StaffMember.Count() = 2, 'There should be 2 staff members BC.');
    end;


    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure TestImportModifiedStaffReflectsChanges()
    var
        StaffMember: Record "Shpfy Staff Member";
        ShpfyStaffMemberAPI: Codeunit "Shpfy Staff Member API";
        LibraryAssert: Codeunit "Library Assert";
        OriginalName: Text;
    begin
        // [Given] Staff was modified in Shopify
        this.Initialize();

        CreateNewStaffMember(ShpfyShop.Code, StaffMember);
        OriginalName := StaffMember.Name;

        // [When] Staff is imported into BC
        ShpfyStaffMemberAPI.GetStaffMembers(ShpfyShop.Code);

        // [Then] Staff is modified in BC
        StaffMember.Get(ShpfyShop.Code, GetStaffIdToModify());
        LibraryAssert.IsFalse(StaffMember.Name = OriginalName, 'Staff name should be modified in BC.');
    end;

    [Test]
    procedure TestCannotAssignSameSalespersonToMultipleStaff()
    var
        StaffMember: Record "Shpfy Staff Member";
        Salesperson: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
        LibraryAssert: Codeunit "Library Assert";
        SalespersonPurchaserMappingErr: Label '%1 %2 already mapped to Shopify Staff Member %3.', Comment = '%1 = Salesperson/Purchaser table caption, %2 = Salesperson/Purchaser code, %3 = Shopify Staff Member name';
    begin
        this.Initialize();

        this.CreateNewStaffMember(ShpfyShop.Code, StaffMember);
        this.CreateNewStaffMember(ShpfyShop.Code, StaffMember);
        LibrarySales.CreateSalesperson(Salesperson);

        // [Given] A Salesperson Code is assigned to Staff A
        StaffMember.FindFirst();
        StaffMember.Validate("Salesperson Code", Salesperson.Code);
        StaffMember.Modify(false);
        Commit();

        // [When] The same Salesperson Code is assigned to Staff B
        StaffMember.FindLast();
        asserterror StaffMember.Validate("Salesperson Code", Salesperson.Code);

        // [Then] An error or validation prevents this assignment
        StaffMember.FindFirst();
        LibraryAssert.ExpectedError(
            StrSubstNo(SalespersonPurchaserMappingErr, Salesperson.TableCaption(), StaffMember."Salesperson Code", StaffMember.Name));
    end;

    [Test]
    procedure TestImportOrderToBCAssignSalesperson()
    var
        StaffMember: Record "Shpfy Staff Member";
        Salesperson: Record "Salesperson/Purchaser";
        OrdersToImport: Record "Shpfy Orders to Import";
        OrderHeader: Record "Shpfy Order Header";
        LibrarySales: Codeunit "Library - Sales";
        OrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
        ImportOrder: Codeunit "Shpfy Import Order";
        LibraryAssert: Codeunit "Library Assert";
        JShopifyOrder: JsonObject;
        JShopifyLineItems: JsonArray;
    begin
        this.Initialize();

        this.CreateNewStaffMember(ShpfyShop.Code, StaffMember, GetStaffIdToModify());
        LibrarySales.CreateSalesperson(Salesperson);
        StaffMember.FindFirst();
        StaffMember.Validate("Salesperson Code", Salesperson.Code);
        StaffMember.Modify(false);

        // [Given] An order exists in Shopify
        JShopifyOrder := OrderHandlingHelper.CreateShopifyOrderAsJson(ShpfyShop, OrdersToImport, JShopifyLineItems, true);

        // [When] The order is imported into BC
        BindSubscription(OrdersAPISubscriber);
        OrderHandlingHelper.ImportShopifyOrder(ShpfyShop, OrderHeader, OrdersToImport, ImportOrder, JShopifyOrder, JShopifyLineItems);
        UnbindSubscription(OrdersAPISubscriber);

        // [Then] The Salesperson is assigned on the imported order
        LibraryAssert.IsTrue(OrderHeader."Salesperson Code" = StaffMember."Salesperson Code", 'Salesperson should be assigned on the imported order.');
    end;

    [Test]
    procedure TestCreateSOFromImportedOrderSalespersonAssigned()
    var
        StaffMember: Record "Shpfy Staff Member";
        Salesperson: Record "Salesperson/Purchaser";
        OrderHeader: Record "Shpfy Order Header";
        SalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        ImportOrder: Codeunit "Shpfy Import Order";
        ProcessOrders: Codeunit "Shpfy Process Orders";
        LibraryAssert: Codeunit "Library Assert";
        OrderHandlingHelper: Codeunit "Shpfy Order Handling Helper";
    begin
        this.Initialize();

        this.CreateNewStaffMember(ShpfyShop.Code, StaffMember, GetStaffIdToModify());
        LibrarySales.CreateSalesperson(Salesperson);
        StaffMember.FindFirst();
        StaffMember.Validate("Salesperson Code", Salesperson.Code);
        StaffMember.Modify(false);

        // [Given] A Shopify order has been imported into BC
        BindSubscription(OrdersAPISubscriber);
        OrderHandlingHelper.ImportShopifyOrder(ShpfyShop, OrderHeader, ImportOrder, true);
        UnbindSubscription(OrdersAPISubscriber);
        Commit();

        // [When] A Sales Order is created in BC from the imported Shopify order
        ProcessOrders.ProcessShopifyOrder(OrderHeader);
        OrderHeader.Get(OrderHeader."Shopify Order Id");

        // [Then] The Salesperson is assigned on the Sales Order
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderHeader."Sales Order No.");
        LibraryAssert.AreEqual(OrderHeader."Salesperson Code", SalesHeader."Salesperson Code", 'ShpfyOrderHeader."Salesperson Code" = SalesHeader."Salesperson Code"');
    end;

    local procedure Initialize()
    var
        ShpfyStaffMember: Record "Shpfy Staff Member";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryRandom: Codeunit "Library - Random";
        AccessToken: SecretText;
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Shpfy Staff Test");
        ClearLastError();
        this.ResponseResourceUrl := 'Staff/StaffMembers.txt';

        ShpfyStaffMember.DeleteAll(false);

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Shpfy Staff Test");

        LibraryRandom.Init();

        Any.SetDefaultSeed();

        IsInitialized := true;
        Commit();

        // Creating Shopify Shop
        ShpfyShop := InitializeTest.CreateShop();
        ShpfyShop."B2B Enabled" := true;
        ShpfyShop.Modify();

        CommunicationMgt.SetTestInProgress(false);

        //Register Shopify Access Token
        AccessToken := LibraryRandom.RandText(20);
        InitializeTest.RegisterAccessTokenForShop(ShpfyShop.GetStoreName(), AccessToken);

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Shpfy Staff Test");
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

    local procedure CreateNewStaffMember(ShopCode: Code[20]; StaffMember: Record "Shpfy Staff Member")
    begin
        this.CreateNewStaffMember(ShopCode, StaffMember, 0);
    end;

    local procedure CreateNewStaffMember(ShopCode: Code[20]; StaffMember: Record "Shpfy Staff Member"; StaffId: BigInteger)
    begin
        StaffMember.Init();
        StaffMember."Shop Code" := ShopCode;
        StaffMember.Id := StaffId;
        if StaffId = 0 then
            StaffMember.Id := Any.IntegerInRange(1, 99999);
        StaffMember.Name := CopyStr(Any.AlphabeticText(100), 1, MaxStrLen(StaffMember.Name));
        StaffMember.Insert(false);
    end;

    local procedure GetStaffIdToModify(): BigInteger
    begin
        // When changing this value make sure to also change the value in the test data file StaffMembers.txt
        exit(1234567890L);
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
    end;
}
