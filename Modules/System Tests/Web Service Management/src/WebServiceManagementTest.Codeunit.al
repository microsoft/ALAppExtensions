// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139043 "Web Service Management Test"
{
    Subtype = Test;

    var
        WebServiceManagement: Codeunit "Web Service Management";
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        ClientType: Enum "Client Type";
        Initialized: Boolean;
        PageServiceTxt: Label 'PageService';
        CodeunitServiceTxt: Label 'CodeunitService';
        QueryServiceTxt: Label 'QueryService';
        UnpublishedPageTxt: Label 'UnpublishedPage';
        PageATxt: Label 'PageA';
        PageBTxt: Label 'PageB';
        PageCTxt: Label 'PageC';
        PageDTxt: Label 'PageD';
        ODataUnboundActionHelpUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2138827';

    [Test]
    [Scope('OnPrem')]
    procedure TestUrlsAreSet()
    var
        WebService: Record "Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageServiceTxt, true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Codeunit, Codeunit::"Dummy Codeunit", CodeunitServiceTxt, true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Query, Query::"Dummy Query", QueryServiceTxt, true);
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, Page::"Dummy Page2", UnpublishedPageTxt, false);
        WebServiceManagement.LoadRecords(WebServiceAggregate);

        if WebServiceAggregate.Get(WebService."Object Type"::Page, PageServiceTxt) then begin
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), PageServiceTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), PageServiceTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), PageServiceTxt);
        end;

        if WebServiceAggregate.Get(WebService."Object Type"::Query, QueryServiceTxt) then begin
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), QueryServiceTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), QueryServiceTxt);
            VerifyUrlMissingServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), QueryServiceTxt);
        end;

        if WebServiceAggregate.Get(WebService."Object Type"::Codeunit, CodeunitServiceTxt) then begin
            VerifyUrlMissingServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), CodeunitServiceTxt);
            VerifyODataV4CodeunitHelpUrl(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), CodeunitServiceTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), CodeunitServiceTxt);
        end;

        if WebServiceAggregate.Get(WebService."Object Type"::Page, UnpublishedPageTxt) then begin
            Assert.AreEqual('', WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), 'ODataV3 Url should be empty when not published: ' + CodeunitServiceTxt);
            Assert.AreEqual('', WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), 'ODataV4 Url should be empty when not published: ' + CodeunitServiceTxt);
            Assert.AreEqual('', WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), 'SOAP Url should be empty when not published: ' + CodeunitServiceTxt);
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPublishedAppServiceWithNoTenantService()
    var
        WebService: Record "Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageServiceTxt, true);
        WebServiceManagement.LoadRecords(WebServiceAggregate);

        if WebServiceAggregate.Get(WebService."Object Type"::Page, PageServiceTxt) then begin
            Assert.IsTrue(WebServiceAggregate.Published, PageServiceTxt + ' web service record "Published" field should be checked.');
            Assert.IsTrue(WebServiceAggregate."All Tenants", PageServiceTxt + ' all tenants should be checked.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPublishedAppServiceWithMatchingPublishedTenantService()
    var
        WebService: Record "Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageATxt, true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageATxt, true);
        WebServiceManagement.LoadRecords(WebServiceAggregate);

        if WebServiceAggregate.Get(WebService."Object Type"::Page, PageATxt) then begin
            Assert.IsTrue(WebServiceAggregate.Published, PageATxt + ' web service record "Published" field should be checked.');
            Assert.IsTrue(WebServiceAggregate."All Tenants", PageATxt + ' all tenants should be checked.');
        end;
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestPublishedAppServiceWithPublishedTenantService()
    var
        WebService: Record "Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageATxt, true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageBTxt, true);
        WebServiceManagement.LoadRecords(WebServiceAggregate);

        if WebServiceAggregate.Get(WebService."Object Type"::Page, PageATxt) then begin
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), PageATxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), PageATxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), PageATxt);
            Assert.IsTrue(WebServiceAggregate.Published, PageATxt + ' web service record "Published" field should be checked.');
        end;

        if WebServiceAggregate.Get(WebService."Object Type"::Page, PageBTxt) then begin
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), PageBTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), PageBTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), PageBTxt);
            Assert.IsTrue(WebServiceAggregate.Published, PageBTxt + ' web service record "Published" field should be checked.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPublishedAppServiceWithNonPublishedTenantService()
    var
        WebService: Record "Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageATxt, true);
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Page, Page::"Dummy Page", PageBTxt, false);
        WebServiceManagement.LoadRecords(WebServiceAggregate);

        if WebServiceAggregate.Get(WebService."Object Type"::Page, PageCTxt) then begin
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), PageCTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), PageCTxt);
            VerifyUrlHasServiceName(WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), PageCTxt);
            Assert.IsTrue(WebServiceAggregate.Published, PageCTxt + ' web service record "Published" field should be checked.');
        end;

        if WebServiceAggregate.Get(WebService."Object Type"::Page, PageDTxt) then begin
            Assert.AreEqual('', WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV3), PageDTxt + ' web service record "ODataV3 Url" should be empty.');
            Assert.AreEqual('', WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::ODataV4), PageDTxt + ' web service record "ODataV4 Url" should be empty.');
            Assert.AreEqual('', WebServiceManagement.GetWebServiceUrl(WebServiceAggregate, ClientType::SOAP), PageDTxt + ' web service record "SOAP Url" should be empty.');
            Assert.IsFalse(WebServiceAggregate.Published, PageDTxt + ' web service record "Published" field should be checked.');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAllTenantsInsertion()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
        AutoServiceName: Text[240];
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        // Test that inserting a record for all tenants correctly writes a system record.
        AutoServiceName := Any.GuidValue();

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate."All Tenants" := true;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        // Verify Web Service
        Assert.IsTrue(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should exist in the Web Service table');
        Assert.AreEqual(WebService."Object Type"::Page, WebService."Object Type", AutoServiceName + ' should be a page');
        Assert.AreEqual(PAGE::"Dummy Page", WebService."Object ID", AutoServiceName + ' incorrect object ID');
        Assert.AreEqual(AutoServiceName, WebService."Service Name", AutoServiceName + ' incorrect service name');
        Assert.IsTrue(WebService.Published, AutoServiceName + ' should be published');

        // Verify Tenant Web Service
        Assert.IsFalse(
          TenantWebService.Get(OBJECTTYPE::Page, AutoServiceName), AutoServiceName + ' should not exist in the Tenant Web Service table');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTenantInsertion()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
        AutoServiceName: Text[240];
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        // Test that inserting a record for a single tenant correctly writes a tenant record.
        AutoServiceName := Any.GuidValue();

        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate."All Tenants" := false;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        // Verify Web Service
        Assert.IsFalse(WebService.Get(OBJECTTYPE::Page, AutoServiceName), AutoServiceName + ' should not exist in the Web Service table');

        // Verify Tenant Web Service
        Assert.IsTrue(
          TenantWebService.Get(OBJECTTYPE::Page, AutoServiceName), AutoServiceName + ' should exist in the Tenant Web Service table');
        Assert.AreEqual(TenantWebService."Object Type"::Page, TenantWebService."Object Type", AutoServiceName + ' should be a page');
        Assert.AreEqual(PAGE::"Dummy Page", TenantWebService."Object ID", AutoServiceName + ' incorrect object ID');
        Assert.AreEqual(AutoServiceName, TenantWebService."Service Name", AutoServiceName + ' incorrect service name');
        Assert.IsTrue(TenantWebService.Published, AutoServiceName + ' should be published');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDuplicateServiceName()
    var
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
        AutoServiceName: Text[240];
    begin
        PermissionsMock.Set('Web Service Admin');

        Initialize();
        // Test that adding a new web service with the same Object Type and Service Name as an existing record
        // (system or tenant record) will result in a duplicate service error.
        AutoServiceName := Any.GuidValue();

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := Page::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate."All Tenants" := true;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := Page::"Dummy Page2";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate."All Tenants" := false;
        TempWebServiceAggregate.Published := true;

        asserterror TempWebServiceAggregate.Insert(true);
        Assert.ExpectedError('The web service cannot be added because it conflicts with an unpublished system web service for the object.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertServiceNameDisallowed()
    var
        WebService: Record "Web Service";
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        // Test that adding a new tenant web service for an object (type and ID) that has an unpublished
        // system record will give an error.

        WebService.Init();
        WebService."Object Type" := WebService."Object Type"::Page;
        WebService."Object ID" := PAGE::"Dummy Page";
        WebService."Service Name" := Any.GuidValue();
        WebService.Published := false;
        WebService.Insert(true);

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := Any.GuidValue();
        TempWebServiceAggregate."All Tenants" := false;
        TempWebServiceAggregate.Published := true;

        asserterror TempWebServiceAggregate.Insert(true);
        Assert.ExpectedError('The web service cannot be added because it conflicts with an unpublished system web service for the object.');

        // Test that adding a new web service for an object (type and ID) that has an unpublished
        // system record will give an error.

        WebService.Init();
        WebService."Object Type" := WebService."Object Type"::Page;
        WebService."Object ID" := PAGE::"Dummy Page";
        WebService."Service Name" := Any.GuidValue();
        WebService.Published := false;
        WebService.Insert(true);

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := Any.GuidValue();
        TempWebServiceAggregate."All Tenants" := true;
        TempWebServiceAggregate.Published := true;

        asserterror TempWebServiceAggregate.Insert(true);
        Assert.ExpectedError('The web service cannot be added because it conflicts with an unpublished system web service for the object.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestModifyAllTenantsRecord()
    var
        WebService: Record "Web Service";
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
        AutoServiceName: Text[240];
        AutoServiceName2: Text[240];
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        // Test that changing the Object Type, Object ID, Service Name, and Publish fields
        // of a system record will change the value of the system record.
        AutoServiceName := Any.GuidValue();

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate.ExcludeFieldsOutsideRepeater := false;
        TempWebServiceAggregate.ExcludeNonEditableFlowFields := false;
        TempWebServiceAggregate."All Tenants" := true;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        Assert.IsTrue(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should exist in the Web Service table');

        // Change 'Object ID', 'Publish', 'ExcludeFieldsOutsideRepeater' and 'ExcludeNonEditableFlowFields'
        TempWebServiceAggregate.Get(TempWebServiceAggregate."Object Type"::Page, AutoServiceName);
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page2";
        TempWebServiceAggregate.ExcludeFieldsOutsideRepeater := true;
        TempWebServiceAggregate.ExcludeNonEditableFlowFields := true;
        TempWebServiceAggregate.Published := false;
        TempWebServiceAggregate.Modify(true);

        Assert.IsTrue(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should exist in the Web Service table');
        Assert.AreEqual(WebService."Object Type"::Page, WebService."Object Type", AutoServiceName + ' object type should be page.');
        Assert.IsFalse(WebService.Published, AutoServiceName + ' should not be published');
        Assert.IsTrue(
          WebService.ExcludeFieldsOutsideRepeater,
          AutoServiceName + ' should exclude fields outside repeater');
        Assert.IsTrue(
          WebService.ExcludeNonEditableFlowFields,
          AutoServiceName + ' should exclude non-editable flow fields');

        // Change 'Object Type'
        TempWebServiceAggregate."Object ID" := QUERY::"Dummy Query";
        TempWebServiceAggregate.Rename(TempWebServiceAggregate."Object Type"::Query, AutoServiceName);

        Assert.IsFalse(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should not exist in the Web Service table');
        Assert.IsTrue(
          WebService.Get(WebService."Object Type"::Query, AutoServiceName), AutoServiceName + ' should exist in the Web Service table');
        Assert.AreEqual(WebService."Object Type"::Query, WebService."Object Type", AutoServiceName + ' object type should be query.');
        Assert.AreEqual(QUERY::"Dummy Query", WebService."Object ID", AutoServiceName + ' incorrect object id');

        // Change 'Service Name'
        AutoServiceName2 := Any.GuidValue();
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Rename(TempWebServiceAggregate."Object Type"::Query, AutoServiceName2);

        Assert.IsFalse(
          WebService.Get(WebService."Object Type"::Query, AutoServiceName),
          AutoServiceName + ' should not exist in the Web Service table');
        Assert.IsTrue(
          WebService.Get(WebService."Object Type"::Query, AutoServiceName2), AutoServiceName2 + ' should exist in the Web Service table');
        Assert.IsTrue(WebService.Published, AutoServiceName2 + ' should be published');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestModifyTenantRecord()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
        AutoServiceName: Text[240];
        AutoServiceName2: Text[240];
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebService.DeleteAll();
        // Test that changing the Object Type, Object ID, Service Name, and Publish fields
        // of a tenant record will change the value of the tenant record.
        AutoServiceName := Any.GuidValue();

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate.ExcludeFieldsOutsideRepeater := false;
        TempWebServiceAggregate.ExcludeNonEditableFlowFields := false;
        TempWebServiceAggregate."All Tenants" := false;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        Assert.IsTrue(
          TenantWebService.Get(WebService."Object Type"::Page, AutoServiceName),
          AutoServiceName + ' should exist in the Tenant Web Service table');

        // Change 'Object ID', 'Publish', 'ExcludeFieldsOutsideRepeater' and 'ExcludeNonEditableFlowFields'
        TempWebServiceAggregate.Get(TempWebServiceAggregate."Object Type"::Page, AutoServiceName);
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page2";
        TempWebServiceAggregate.ExcludeFieldsOutsideRepeater := true;
        TempWebServiceAggregate.ExcludeNonEditableFlowFields := true;
        TempWebServiceAggregate.Published := false;
        TempWebServiceAggregate.Modify(true);

        Assert.IsTrue(
          TenantWebService.Get(TenantWebService."Object Type"::Page, AutoServiceName),
          AutoServiceName + ' should exist in the Tenant Web Service table');
        Assert.AreEqual(
          TenantWebService."Object Type"::Page, TenantWebService."Object Type", AutoServiceName + ' object type should be page.');
        Assert.IsFalse(TenantWebService.Published, AutoServiceName + ' should not be published');
        Assert.IsTrue(
          TenantWebService.ExcludeFieldsOutsideRepeater,
          AutoServiceName + ' should exclude fields outside repeater');
        Assert.IsTrue(
          TenantWebService.ExcludeNonEditableFlowFields,
          AutoServiceName + ' should exclude non-editable flow fields');

        // Change 'Object Type'
        TempWebServiceAggregate."Object ID" := QUERY::"Dummy Query";
        TempWebServiceAggregate.Rename(TempWebServiceAggregate."Object Type"::Query, AutoServiceName);

        Assert.IsFalse(
          TenantWebService.Get(TenantWebService."Object Type"::Page, AutoServiceName),
          AutoServiceName + ' should not exist in the Tenant Web Service table');
        Assert.IsTrue(
          TenantWebService.Get(TenantWebService."Object Type"::Query, AutoServiceName),
          AutoServiceName + ' should exist in the Tenant Web Service table');
        Assert.AreEqual(
          TenantWebService."Object Type"::Query, TenantWebService."Object Type", AutoServiceName + ' object type should be query.');
        Assert.AreEqual(QUERY::"Dummy Query", TenantWebService."Object ID", AutoServiceName + ' incorrect object id');

        // Change 'Service Name'
        AutoServiceName2 := Any.GuidValue();
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Rename(TempWebServiceAggregate."Object Type"::Query, AutoServiceName2);

        Assert.IsFalse(
          TenantWebService.Get(TenantWebService."Object Type"::Query, AutoServiceName),
          AutoServiceName + ' should not exist in the Web Service table');
        Assert.IsTrue(
          TenantWebService.Get(TenantWebService."Object Type"::Query, AutoServiceName2),
          AutoServiceName2 + ' should exist in the Web Service table');
        Assert.IsTrue(TenantWebService.Published, AutoServiceName2 + ' should be published');

        // Changing the web service to have the same Object (Type and ID) as an unpublished system record
        // will produce an error.
        WebService.Init();
        WebService."Object Type" := WebService."Object Type"::Page;
        WebService."Object ID" := PAGE::"Dummy Page";
        WebService."Service Name" := AutoServiceName;
        WebService.Published := false;
        WebService.Insert();

        TempWebServiceAggregate.Get(TempWebServiceAggregate."Object Type"::Query, AutoServiceName2);
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        asserterror TempWebServiceAggregate.Rename(TempWebServiceAggregate."Object Type"::Page, AutoServiceName2);
        Assert.ExpectedError('The web service cannot be modified because it conflicts with an unpublished system web service for the object.');

        // Changing the web service to have the same Object Type and Service Name as an existing record
        // (system or tenant record) will result in an error.
        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate."All Tenants" := false;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        TempWebServiceAggregate.Get(TempWebServiceAggregate."Object Type"::Query, AutoServiceName2);
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate.Rename(TempWebServiceAggregate."Object Type"::Page, AutoServiceName2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteAllTenantsRecord()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
        AutoServiceName: Text[240];
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        // Deleting a system record will delete the system record
        AutoServiceName := Any.GuidValue();

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate."All Tenants" := true;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        TempWebServiceAggregate.Get(TempWebServiceAggregate."Object Type"::Page, AutoServiceName);
        Assert.IsTrue(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should exist in the Web Service table');
        Assert.IsFalse(
          TenantWebService.Get(TenantWebService."Object Type"::Page, AutoServiceName),
          AutoServiceName + ' should not exist in the Tenant Web Service table');

        TempWebServiceAggregate.Delete(true);
        Assert.IsFalse(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should not exist in the Web Service table');
        Assert.IsFalse(
          TenantWebService.Get(TenantWebService."Object Type"::Page, AutoServiceName),
          AutoServiceName + ' should not exist in the Tenant Web Service table');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteTenantRecord()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        TempWebServiceAggregate: Record "Web Service Aggregate" temporary;
        Any: Codeunit Any;
        AutoServiceName: Text[240];
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        // Deleting a tenant record will delete the tenant record
        // Deleting a system record will delete the system record
        AutoServiceName := Any.GuidValue();

        TempWebServiceAggregate.Init();
        TempWebServiceAggregate."Object Type" := TempWebServiceAggregate."Object Type"::Page;
        TempWebServiceAggregate."Object ID" := PAGE::"Dummy Page";
        TempWebServiceAggregate."Service Name" := AutoServiceName;
        TempWebServiceAggregate."All Tenants" := false;
        TempWebServiceAggregate.Published := true;
        TempWebServiceAggregate.Insert(true);

        TempWebServiceAggregate.Get(TempWebServiceAggregate."Object Type"::Page, AutoServiceName);
        Assert.IsFalse(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should not exist in the Web Service table');
        Assert.IsTrue(
          TenantWebService.Get(TenantWebService."Object Type"::Page, AutoServiceName),
          AutoServiceName + ' should exist in the Tenant Web Service table');

        TempWebServiceAggregate.Delete(true);
        Assert.IsFalse(
          WebService.Get(WebService."Object Type"::Page, AutoServiceName), AutoServiceName + ' should not exist in the Web Service table');
        Assert.IsFalse(
          TenantWebService.Get(TenantWebService."Object Type"::Page, AutoServiceName),
          AutoServiceName + ' should not exist in the Tenant Web Service table');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateWebService()
    var
        WebService: Record "Web Service";
        ObjectNameLbl: Label 'TestWebService';
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Page, Page::"Dummy Page", ObjectNameLbl, true);

        if WebService.Get(WebService."Object Type"::Page, ObjectNameLbl) then
            Assert.IsTrue(WebService.Published, ObjectNameLbl + ' web service record "Published" field should be checked.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateTenantWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        ObjectNameLbl: Label 'TestTenantWebService';
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, Page::"Dummy Page", ObjectNameLbl, true);

        if TenantWebService.Get(TenantWebService."Object Type"::Page, ObjectNameLbl) then
            Assert.IsTrue(TenantWebService.Published, ObjectNameLbl + ' tenant web service record "Published" field should be checked.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteTenantWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
        ObjectNameLbl: Label 'TestTenantWebService';
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, Page::"Dummy Page", ObjectNameLbl, true);

        WebServiceManagement.LoadRecords(WebServiceAggregate);
        Assert.IsTrue(WebServiceAggregate.Get(WebServiceAggregate."Object Type"::Page, ObjectNameLbl), 'Web Service should be present');

        ClearLastError();
        // Delete tenant web service
        WebServiceManagement.DeleteWebService(WebServiceAggregate);
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred when deleting a tenant web service');

        WebServiceManagement.LoadRecords(WebServiceAggregate);
        Assert.IsFalse(WebServiceAggregate.Get(WebServiceAggregate."Object Type"::Page, ObjectNameLbl), 'Web Service should not be present');

        Assert.IsFalse(TenantWebService.Get(TenantWebService."Object Type"::Page, ObjectNameLbl), 'Tenant web service should not be present');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteWebService()
    var
        WebService: Record "Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
        ObjectNameLbl: Label 'TestWebService';
    begin
        PermissionsMock.Set('Web Service Admin');
        Initialize();
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Page, Page::"Dummy Page", ObjectNameLbl, true);

        WebServiceManagement.LoadRecords(WebServiceAggregate);
        Assert.IsTrue(WebServiceAggregate.Get(WebServiceAggregate."Object Type"::Page, ObjectNameLbl), 'Web Service should be present');

        ClearLastError();
        // Delete web service
        WebServiceManagement.DeleteWebService(WebServiceAggregate);
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred when deleting a web service');

        WebServiceManagement.LoadRecords(WebServiceAggregate);
        Assert.IsFalse(WebServiceAggregate.Get(WebServiceAggregate."Object Type"::Page, ObjectNameLbl), 'Web Service should not be present');

        Assert.IsFalse(WebService.Get(WebService."Object Type"::Page, ObjectNameLbl), 'Web service should not be present');
    end;

    local procedure VerifyUrlHasServiceName(Url: Text; ServiceName: Text[240])
    begin
        Assert.IsTrue(
          StrPos(Url, ServiceName) > 1,
          StrSubstNo('Url was ''%1'' but should be populated and contain ServiceName ''%2''.', Url, ServiceName))
    end;

    local procedure VerifyUrlMissingServiceName(Url: Text; ServiceName: Text[240])
    begin
        Assert.AreEqual('Not applicable', Url, StrSubstNo('Url was ''%1'' but should be "Not applicable" for ''%2''.', Url, ServiceName));
    end;

    local procedure VerifyODataV4CodeunitHelpUrl(Url: Text; ServiceName: Text[240])
    begin
        Assert.AreEqual(ODataUnboundActionHelpUrlLbl, Url, StrSubstNo('Url was ''%1'' but should be "Not applicable" for ''%2''.', Url, ServiceName));
    end;

    local procedure Initialize()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        WebServiceAggregate: Record "Web Service Aggregate";
    begin
        if Initialized then
            exit;

        WebService.DeleteAll();
        TenantWebService.DeleteAll();
        WebServiceAggregate.DeleteAll();
        Initialized := true;
    end;
}

