// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration.Excel;

using System.Integration.Excel;
using System.Integration;
using System.TestLibraries.Integration.Excel;
using System;
using System.TestLibraries.Utilities;
codeunit 132525 "Edit in Excel Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        LibraryAssert: Codeunit "Library Assert";
        EditInExcelTest: Codeunit "Edit in Excel Test";
        EditInExcel: Codeunit "Edit in Excel";
        IsInitialized: Boolean;
        EventServiceName: Text[240];
#if not CLEAN22
        WebServiceHasBeenDisabledErr: Label 'You can''t edit this page in Excel because it''s not set up for it. To use the Edit in Excel feature, you must publish the web service called ''%1''. Contact your system administrator for help.', Comment = '%1 = Web service name';
#endif

    [Test]
    procedure TestEditInExcelCreatesWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        EditInExcelList: Page "Edit in Excel List";
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();

        EditinExcelFilters.AddField('Id', Enum::"Edit in Excel Filter Type"::Equal, 'test', Enum::"Edit in Excel Edm Type"::"Edm.String");

        EditInExcel.EditPageInExcel(CopyStr(EditInExcelList.Caption, 1, 240), Page::"Edit in Excel List", EditinExcelFilters);

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual(EditInExcelList.Caption + '_Excel', TenantWebService."Service Name", 'The tenant web service has incorrect name');
    end;

#if not CLEAN22
#pragma warning disable AL0432
    [Test]
    procedure TestEditInExcelCreatesWebServiceOld()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();

        EditInExcel.EditPageInExcel(CopyStr(EditInExcelList.Caption, 1, 240), EditInExcelList.ObjectId(false), '');

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual(EditInExcelList.Caption + '_Excel', TenantWebService."Service Name", 'The tenant web service has incorrect name');
    end;

    [Test]
    procedure TestEditInExcelDisabledWebServiceOld() // New test now exist under workbook tests
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
        PageName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        PageName := 'TestServiceName';
        InsertTenantWebService(Page::"Edit in Excel List", PageName + '_Excel', false, false, false);

        asserterror EditInExcel.EditPageInExcel(PageName, EditInExcelList.ObjectId(false), '');
        LibraryAssert.ExpectedError(StrSubstNo(WebServiceHasBeenDisabledErr, PageName + '_Excel'));
    end;
#pragma warning restore AL0432
#endif

    [Test]
    procedure TestEditInExcelReuseWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        PageName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        PageName := 'TestServiceName';
        InsertTenantWebService(Page::"Edit in Excel List", PageName + '_Excel', false, false, true);

        EditInExcel.EditPageInExcel(PageName, Page::"Edit in Excel List", EditinExcelFilters);

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual(PageName + '_Excel', TenantWebService."Service Name", 'The tenant web service name has changed');
        LibraryAssert.AreEqual(PageName + '_Excel', EditInExcelTest.GetServiceName(), 'The service name given to the edit in excel event is incorrect');
    end;

#if not CLEAN22
#pragma warning disable AL0432
    [Test]
    procedure TestEditInExcelReuseWebServiceOld()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
        PageName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        PageName := 'TestServiceName';
        InsertTenantWebService(Page::"Edit in Excel List", PageName + '_Excel', false, false, true);

        EditInExcel.EditPageInExcel(PageName, EditInExcelList.ObjectId(false), '');

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual(PageName + '_Excel', TenantWebService."Service Name", 'The tenant web service name has changed');
        LibraryAssert.AreEqual(PageName + '_Excel', EditInExcelTest.GetServiceName(), 'The service name given to the edit in excel event is incorrect');
    end;
#pragma warning restore AL0432
#endif

    [Test]
    procedure TestEditInExcelReuseSpecificWebService()
    var
        TenantWebService: Record "Tenant Web Service";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        EditInExcelList: Page "Edit in Excel List";
        ServiceName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        ServiceName := EditInExcelList.Caption + '_Excel';
        InsertTenantWebService(Page::"Edit in Excel List", 'aaa', true, true, true);
        InsertTenantWebService(Page::"Edit in Excel List", ServiceName, false, false, true);
        InsertTenantWebService(Page::"Edit in Excel List", 'zzz', true, true, true);

        EditInExcel.EditPageInExcel(CopyStr(EditInExcelList.Caption, 1, 240), Page::"Edit in Excel List", EditinExcelFilters);

        LibraryAssert.RecordCount(TenantWebService, 3);
        LibraryAssert.AreEqual(ServiceName, EditInExcelTest.GetServiceName(), 'The service name used is wrong'); // if there's a service called pageCaption_Excel then always use that one
    end;

#if not CLEAN22
#pragma warning disable AL0432
    [Test]
    procedure TestEditInExcelReuseSpecificWebServiceOld()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
        ServiceName: Text[100];
    begin
        Init();

        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        ServiceName := EditInExcelList.Caption + '_Excel';
        InsertTenantWebService(Page::"Edit in Excel List", 'aaa', true, true, true);
        InsertTenantWebService(Page::"Edit in Excel List", ServiceName, false, false, true);
        InsertTenantWebService(Page::"Edit in Excel List", 'zzz', true, true, true);

        EditInExcel.EditPageInExcel(CopyStr(EditInExcelList.Caption, 1, 240), EditInExcelList.ObjectId(false), '');

        LibraryAssert.RecordCount(TenantWebService, 3);
        LibraryAssert.AreEqual(ServiceName, EditInExcelTest.GetServiceName(), 'The service name used is wrong'); // if there's a service called pageCaption_Excel then always use that one
    end;
#pragma warning restore AL0432
#endif

    [Test]
    procedure TestEditInExcelNumberInFieldNameReplacement()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        RegularFieldName: Text;
        FieldNameStartingWDigit: Text;
    begin
        Init();
        FieldNameStartingWDigit := EditinExcelTestLibrary.ExternalizeODataObjectName('3field');
        RegularFieldName := EditinExcelTestLibrary.ExternalizeODataObjectName('field');
        LibraryAssert.AreEqual('field', RegularFieldName, 'Conversion alters name that does not begin with a string');
        LibraryAssert.AreEqual('_x0033_field', FieldNameStartingWDigit, 'Did not convert the name with number correctly');
    end;

    [Test]
    procedure TestEditInExcelWebServiceStartsWithNumber()
    var
        TenantWebService: Record "Tenant Web Service";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();

        EditInExcel.EditPageInExcel('3Service', Page::"Edit in Excel List", EditinExcelFilters);

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual('WS3Service_Excel', TenantWebService."Service Name", 'The tenant web service has incorrect name');
    end;

#if not CLEAN22
#pragma warning disable AL0432
    [Test]
    procedure TestEditInExcelWebServiceStartsWithNumberOld()
    var
        TenantWebService: Record "Tenant Web Service";
        EditInExcelList: Page "Edit in Excel List";
    begin
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();

        EditInExcel.EditPageInExcel('3Service', EditInExcelList.ObjectId(false), '');

        LibraryAssert.RecordCount(TenantWebService, 1);
        TenantWebService.FindFirst();
        LibraryAssert.AreEqual('WS3Service_Excel', TenantWebService."Service Name", 'The tenant web service has incorrect name');
    end;
#pragma warning restore AL0432
#endif

    [Test]
    procedure TestEditInExcelInvalidFilterObject()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
    begin
        // [Scenario] Edit in Excel is called with invalid json filter object
        Init();

        // [Given] Invalid json filter object (missing last bracket)
        JsonFilter := '{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"01121212"}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';

        LibraryAssert.IsFalse(FilterJsonObject.ReadFrom(JsonFilter), 'Json filter should not be readable');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);
        LibraryAssert.IsTrue(IsNull(FieldFilters), 'Field filters were created.');

    end;

    [Test]
    procedure TestEditInExcelStructuredFilter()
    var
        TenantWebService: Record "Tenant Web Service";
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
    begin
        //[Scenario] Edit In Excel is called with a complex JSON filter
        Init();

        // [Given] TenantWebServiceExists, JSON Filter and Payload Objects
        TenantWebService.SetRange("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.SetRange("Object ID", Page::"Edit in Excel List");
        TenantWebService.DeleteAll();
        JsonFilter := '{ "type": "and", "childNodes": [ { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Legal Entity" } }, { "type": "and", "childNodes": [ { "type": "or", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Legal Entity" } }, { "type": "eq", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Natural Person" } } ] } ] } ] }, { "type": "ge", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Natural Person" } } ] }, { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "lt", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "1" } }, { "type": "eq", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "3" } } ] }, { "type": "le", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "-2" } } ] }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "0" } }, { "type": "le", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "4" } } ] } ] }, { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "2" } }, { "type": "gt", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "0" } } ] }, { "type": "ne", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "4" } } ] }, { "type": "ge", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "7" } } ] }, { "type": "le", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "0" } } ] } ] }, { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "a" } }, { "type": "le", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "zzzz" } } ] }, { "type": "ge", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "foo" } } ] }, { "type": "and", "childNodes": [ { "type": "le", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "bar" } }, { "type": "eq", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "x" } } ] } ] }, { "type": "gt", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "a" } } ] }, { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "A" } }, { "type": "le", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "0" } } ] }, { "type": "lt", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "!" } } ] }, { "type": "eq", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "*.txt" } } ] } ] }, { "type": "and", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "@*oops" } }, { "type": "ne", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "avoid" } } ] } ] }, { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "lt", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2030-01-01" } }, { "type": "gt", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2030-01-01" } } ] }, { "type": "and", "childNodes": [ { "type": "ne", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2042-07-22" } }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2029-12-31" } }, { "type": "le", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2030-10-10" } } ] } ] } ] }, { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } }, { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } } ] }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } }, { "type": "le", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } } ] } ] }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } }, { "type": "le", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } } ] } ] }, { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } } ] }, { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } } ] } ] }';
        JsonPayload := '{ "fieldPayload": { "Tax_Identification_Type": { "alName": "Tax Identification Type", "edmType": "Edm.String", }, "AdjCustProfit": { "alName": "AdjCustProfit", "edmType": "Edm.Decimal", }, "Name": { "alName": "Name", "edmType": "Edm.String", }, "Last_Date_Modified": { "alName": "Last Date Modified", "edmType": "Edm.DateTimeOffset", }, "Privacy_Blocked": { "alName": "Privacy Blocked", "edmType": "Edm.Boolean", } } }';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [Then] Creating Workbook finishes successfully and downloads .xslx file
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");
        EditInExcel.EditPageInExcel('Edit in Excel', Page::"Edit in Excel List", EditinExcelFilters);
    end;

    procedure GetServiceName(): Text[240]
    begin
        exit(EventServiceName);
    end;

    local procedure Init()
    begin
        if IsInitialized then
            exit;

        LibraryAssert.IsTrue(BindSubscription(EditInExcelTest), 'Could not bind events');
        IsInitialized := true;
    end;

    local procedure InsertTenantWebService(PageId: Integer; ServiceName: Text[240]; ExcludeFieldsOutsideRepeater: Boolean; ExcludeNonEditableFlowFields: Boolean; Publish: Boolean)
    var
        TenantWebService: Record "Tenant Web Service";
    begin
        TenantWebService.Validate("Object Type", TenantWebService."Object Type"::Page);
        TenantWebService.Validate("Object ID", PageId);
        TenantWebService.Validate(ExcludeFieldsOutsideRepeater, ExcludeFieldsOutsideRepeater);
        TenantWebService.Validate(ExcludeNonEditableFlowFields, ExcludeNonEditableFlowFields);
        TenantWebService.Validate("Service Name", ServiceName);
        TenantWebService.Validate(Published, Publish);
        TenantWebService.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Edit in Excel", 'OnEditInExcelWithFilters', '', false, false)]
    local procedure OnEditInExcelWithSearch(ServiceName: Text[240])
    begin
        EventServiceName := ServiceName;
    end;

    [Test]
    procedure TestEditInExcelFourOrFiltersOnNumberField()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
        NumberKey: Text;
        ExpectedFilter: Text;
        FieldFilter: DotNet FilterCollectionNode;
    begin
        // [Scenario] Edit in Excel is called with invalid json filter object
        Init();

        // [Given] Invalid json filter object (missing last bracket)
        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"or","childNodes":[{"type":"or","childNodes":' +
                        '[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant",' +
                        '"value":"10000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},' +
                        '"rightNode":{"type":"Edm.String constant","value":"20000"}}]},' +
                        '{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"}' +
                        ',"rightNode":{"type":"Edm.String constant","value":"30000"}},' +
                        '{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":' +
                        '{"type":"Edm.String constant","value":"40000"}}]}]}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';

        FilterJsonObject.ReadFrom(JsonFilter);
        PayloadJsonObject.ReadFrom(JsonPayload);

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);
        NumberKey := 'No';
        LibraryAssert.IsTrue(FieldFilters.TryGetValue(NumberKey, FieldFilter), 'Could not find the "No" key in the filters');
        ExpectedFilter := '((No eq ''10000'') or (No eq ''20000'') or (No eq ''30000'') or (No eq ''40000''))';
        LibraryAssert.AreEqual(ExpectedFilter, FieldFilter.ToString(), 'The actual and expected filters are not equal');
    end;

    [Test]
    procedure TestEditInExcelFilter1ValueForEachField()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
        NumberKey: Text;
        SalesKey: Text;
        ExpectedNumberFilter: Text;
        ExpectedSalesFilter: Text;
        NumberFieldFilter: DotNet FilterCollectionNode;
        SalesFieldFilter: DotNet FilterCollectionNode;
    begin
        // [Scenario] User clicks "Edit in Excel", filters selected have only 1 value for each filter
        // That tests reducing redundant collections
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant",' +
                      '"value":"10000"}},{"type":"eq","leftNode":{"type":"var","name":"Global_Dimension_1_Code"},"rightNode"' +
                      ':{"type":"Edm.String constant","value":"SALES"}}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }, "Global_Dimension_1_Code": {"alName": "Global Dimension 1 Code","validInODataFilter": true, "edmType": "Edm.String" }}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);

        NumberKey := 'No';
        SalesKey := 'Global_Dimension_1_Code';

        LibraryAssert.IsTrue(FieldFilters.TryGetValue(NumberKey, NumberFieldFilter), 'Could not find the "' + NumberKey + '" key in the filters');
        LibraryAssert.IsTrue(FieldFilters.TryGetValue(SalesKey, SalesFieldFilter), 'Could not find the "' + SalesKey + '" key in the filters');

        ExpectedNumberFilter := '((No eq ''10000''))';
        ExpectedSalesFilter := '((Global_Dimension_1_Code eq ''SALES''))';

        // We expect this: ( (No eq '10000') and (Global_Dimension_1_Code eq 'SALES'))
        LibraryAssert.AreEqual(ExpectedNumberFilter, NumberFieldFilter.ToString(), 'The actual and expected filters are not equal');
        LibraryAssert.AreEqual(ExpectedSalesFilter, SalesFieldFilter.ToString(), 'The actual and expected filters are not equal');
    end;

    [Test]
    procedure TestEditInExcel4Or1AndFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        EditinExcelFilters: Codeunit "Edit in Excel Filters";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        FieldFilters: DotNet GenericDictionary2;
        NumberKey: Text;
        CountryRegionCodeKey: Text;
        ExpectedNumberFilter: Text;
        ExpectedCountryRegionCodeFilter: Text;
        NumberFieldFilter: DotNet FilterCollectionNode;
        CountryRegionCodeFieldFilter: DotNet FilterCollectionNode;

    begin
        // [Scenario] User clicks "Edit in Excel" with filter on "No" field - 4 or filters and one other filter
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"or","childNodes":[{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":' +
         '{"type":"Edm.String constant","value":"10000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"20000"}}]},' +
         '{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"30000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"40000"}}]}]},{"type":"eq","leftNode":{"type":"var","name":"Country_Region_Code"},"rightNode":{"type":"Edm.String constant","value":"GB"}}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }, "Country_Region_Code": { "alName": "Country/Region Code", "ValidInODataFilter": true, "edmType": "Edm.String" } }}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] Edit in Excel filters are created
        EditinExcelTestLibrary.ReadFromJsonFilters(EditinExcelFilters, FilterJsonObject, PayloadJsonObject, Page::"Edit in Excel List");

        // [Then] The filters match expectations
        EditinExcelTestLibrary.GetFilters(EditinExcelFilters, FieldFilters);

        NumberKey := 'No';
        CountryRegionCodeKey := 'Country_Region_Code';

        LibraryAssert.IsTrue(FieldFilters.TryGetValue(NumberKey, NumberFieldFilter), 'Could not find the "' + NumberKey + '" key in the filters');
        LibraryAssert.IsTrue(FieldFilters.TryGetValue(CountryRegionCodeKey, CountryRegionCodeFieldFilter), 'Could not find the "' + CountryRegionCodeKey + '" key in the filters');

        // We expect this: (((No eq '10000') or (No eq '20000') or (No eq '30000') or (No eq '40000')) and (Country_Region_Code eq 'GB'))
        ExpectedNumberFilter := '((No eq ''10000'') or (No eq ''20000'') or (No eq ''30000'') or (No eq ''40000''))';
        ExpectedCountryRegionCodeFilter := '((Country_Region_Code eq ''GB''))';

        // We expect this: ( (No eq '10000') and (Global_Dimension_1_Code eq 'SALES'))
        LibraryAssert.AreEqual(ExpectedNumberFilter, NumberFieldFilter.ToString(), 'The actual and expected filters are not equal');
        LibraryAssert.AreEqual(ExpectedCountryRegionCodeFilter, CountryRegionCodeFieldFilter.ToString(), 'The actual and expected filters are not equal');
    end;
}