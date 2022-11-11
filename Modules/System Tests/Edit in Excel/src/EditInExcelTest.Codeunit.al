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
        WebServiceHasBeenDisabledErr: Label 'You can''t edit this page in Excel because it''s not set up for it. To use the Edit in Excel feature, you must publish the web service called ''%1''. Contact your system administrator for help.', Comment = '%1 = Web service name';

    [Test]
    procedure TestEditInExcelCreatesWebService()
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
    procedure TestEditInExcelDisabledWebService()
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

    [Test]
    procedure TestEditInExcelReuseWebService()
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

    [Test]
    procedure TestEditInExcelReuseSpecificWebService()
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

    // Bug 445200 Test succeeds locally but fails to publish due to a strange compilation error that is being investigated. Will be enabled after the issue is resolved
    // [Test]
    // procedure TestEditInExcelInvalidFilterObject()
    // var
    //     EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
    //     JsonFilter: Text;
    //     JsonPayload: Text;
    //     FilterJsonObject: JsonObject;
    //     PayloadJsonObject: JsonObject;
    //     EntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     FieldFilterGroupingOperator: Dictionary of [Text, Text];
    // begin
    //     // [Scenario] Edit in Excel is called with invalid json filter object
    //     Init();

    //     // [Given] Invalid json filter object (missing last bracket)
    //     JsonFilter := '{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"01121212"}';
    //     JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';

    //     LibraryAssert.IsFalse(FilterJsonObject.ReadFrom(JsonFilter), 'Json filter should not be readable');
    //     LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

    //     // [When] A FilterCollectionNode is created
    //     TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
    //     TestedEntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ConvertStructuredFiltersToEntityFilterCollection(FilterJsonObject, PayloadJsonObject, TestedEntityFilterCollectionNode, FieldFilterGroupingOperator, 132526);
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(TestedEntityFilterCollectionNode);

    //     // [Then] It should be equal to an empty filter
    //     EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
    //     EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(EntityFilterCollectionNode);

    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');

    // end;

    [Test]
    procedure TestEditInExcelStructuredFilter()
    var
        TenantWebService: Record "Tenant Web Service";
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        ServiceName: Text[100];
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
        ServiceName := 'EditinExcelList_Excel';
        InsertTenantWebService(Page::"Edit in Excel List", ServiceName, true, true, true);
        JsonFilter := '{ "type": "and", "childNodes": [ { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Legal Entity" } }, { "type": "and", "childNodes": [ { "type": "or", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Legal Entity" } }, { "type": "eq", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Natural Person" } } ] } ] } ] }, { "type": "ge", "leftNode": { "type": "var", "name": "Tax_Identification_Type" }, "rightNode": { "type": "text constant", "value": "Natural Person" } } ] }, { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "lt", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "1" } }, { "type": "eq", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "3" } } ] }, { "type": "le", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "-2" } } ] }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "0" } }, { "type": "le", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "4" } } ] } ] }, { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "2" } }, { "type": "gt", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "0" } } ] }, { "type": "ne", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "4" } } ] }, { "type": "ge", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "7" } } ] }, { "type": "le", "leftNode": { "type": "var", "name": "AdjCustProfit" }, "rightNode": { "type": "integer constant", "value": "0" } } ] } ] }, { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "a" } }, { "type": "le", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "zzzz" } } ] }, { "type": "ge", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "foo" } } ] }, { "type": "and", "childNodes": [ { "type": "le", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "bar" } }, { "type": "eq", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "x" } } ] } ] }, { "type": "gt", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "a" } } ] }, { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "A" } }, { "type": "le", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "0" } } ] }, { "type": "lt", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "!" } } ] }, { "type": "eq", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "*.txt" } } ] } ] }, { "type": "and", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "@*oops" } }, { "type": "ne", "leftNode": { "type": "var", "name": "Name" }, "rightNode": { "type": "text constant", "value": "avoid" } } ] } ] }, { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "lt", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2030-01-01" } }, { "type": "gt", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2030-01-01" } } ] }, { "type": "and", "childNodes": [ { "type": "ne", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2042-07-22" } }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2029-12-31" } }, { "type": "le", "leftNode": { "type": "var", "name": "Last_Date_Modified" }, "rightNode": { "type": "datetime constant", "value": "2030-10-10" } } ] } ] } ] }, { "type": "or", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "and", "childNodes": [ { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } }, { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } } ] }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } }, { "type": "le", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } } ] } ] }, { "type": "and", "childNodes": [ { "type": "ge", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } }, { "type": "le", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } } ] } ] }, { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "true" } } ] }, { "type": "eq", "leftNode": { "type": "var", "name": "Privacy_Blocked" }, "rightNode": { "type": "boolean constant", "value": "false" } } ] } ] }';
        JsonPayload := '{ "fieldPayload": { "Tax_Identification_Type": { "alName": "Tax Identification Type", "edmType": "Edm.String", }, "AdjCustProfit": { "alName": "AdjCustProfit", "edmType": "Edm.Decimal", }, "Name": { "alName": "Name", "edmType": "Edm.String", }, "Last_Date_Modified": { "alName": "Last Date Modified", "edmType": "Edm.DateTimeOffset", }, "Privacy_Blocked": { "alName": "Privacy Blocked", "edmType": "Edm.Boolean", } } }';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [Then] Creating Workbook finishes successfully and downloads .xslx file
        EditinExcelTestLibrary.GetEndPointAndCreateWorkbookWStructuredFilter(ServiceName, FilterJsonObject, PayloadJsonObject, '');
    end;

    // Bug 445200 Test succeeds locally but fails to publish due to a strange compilation error that is being investigated. Will be enabled after the issue is resolved
    // [Test]
    // procedure TestEditInExcelStructuredFilterDefaultFilter()
    // var
    //     EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
    //     JsonFilter: Text;
    //     JsonPayload: Text;
    //     FilterJsonObject: JsonObject;
    //     PayloadJsonObject: JsonObject;
    //     EntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     FieldFilterGroupingOperator: Dictionary of [Text, Text];

    // begin
    //     // [Scenario] User clicks "Edit in Excel" without choosing additional filters. BC sends the default date filter
    //     Init();

    //     // [Given] A Json Structured filter and Payload, TenantWebservice exist and is enabled
    //     JsonFilter := '{"type":"and","childNodes":[{"type":"and","childNodes":[{"type":"ge","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"0001-01-01T00:00:00"}},{"type":"le","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"2024-01-25T00:00:00"}}]}]}';
    //     JsonPayload := '{ "fieldPayload": {"Date_Filter": {"alName": "Date Filter","validInODataFilter": true,"edmType": "Edm.DateTimeOffset"}}}';
    //     LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
    //     LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

    //     // [When] The FilterCollectionNode is created
    //     TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
    //     TestedEntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ConvertStructuredFiltersToEntityFilterCollection(FilterJsonObject, PayloadJsonObject, TestedEntityFilterCollectionNode, FieldFilterGroupingOperator, 132526);
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(TestedEntityFilterCollectionNode);

    //     // [Then] It should be equal to manually created  FilterCollectionNode 
    //     EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
    //     EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");

    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    // end;

    // // Test succeeds locally but fails to publish due to a strange compilation error that is being investigated. Will be enabled after the issue is resolved
    // [Test]
    // procedure TestEditInExcelStructuredFilterOneChosenFilter()
    // var
    //     EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
    //     JsonFilter: Text;
    //     JsonPayload: Text;
    //     FilterJsonObject: JsonObject;
    //     PayloadJsonObject: JsonObject;
    //     EntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     FieldFilterGroupingOperator: Dictionary of [Text, Text];
    // begin
    //     // [Scenario] User chooses one filter, with BC appending the default date filter as well

    //     Init();

    //     // [Given] Filter and Payload JSON Objects, containing the date filter and the filter chosen by the user
    //     JsonFilter := '{"type":"and","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"01121212"}},{"type":"and","childNodes":[{"type":"ge","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"0001-01-01T00:00:00"}},{"type":"le","leftNode":{"type":"var","name":"Date_Filter"},"rightNode":{"type":"Edm.DateTimeOffset constant","value":"2024-01-25T00:00:00"}}]}]}';
    //     JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }, "Date_Filter": { "alName": "Date Filter", "validInODataFilter": true, "edmType": "Edm.DateTimeOffset" }}}';
    //     LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
    //     LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

    //     // [When] The FilterCollectionNode is created
    //     TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
    //     TestedEntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ConvertStructuredFiltersToEntityFilterCollection(FilterJsonObject, PayloadJsonObject, TestedEntityFilterCollectionNode, FieldFilterGroupingOperator, 132526);
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(TestedEntityFilterCollectionNode);

    //     // [Then] It should be equal to manually created  FilterCollectionNode 
    //     EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
    //     EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");

    //     AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '01121212', 'No', 'Edm.String');
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(EntityFilterCollectionNode);

    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equals');
    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    // end;

    // [Test]
    // procedure TestEditInExcelStructuredFilterSingleFilter()
    // var
    //     EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
    //     JsonFilter: Text;
    //     JsonPayload: Text;
    //     FilterJsonObject: JsonObject;
    //     PayloadJsonObject: JsonObject;
    //     EntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     FieldFilterGroupingOperator: Dictionary of [Text, Text];
    // begin
    //     // [Scenario] Edit in Excel API is called with only a single filter passed
    //     Init();

    //     // [Given] A Filter object with one filter, Payload object
    //     JsonFilter := '{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"01121212"}}';
    //     JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';
    //     LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
    //     LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

    //     // [When] FilterCollectionNode is created
    //     TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
    //     TestedEntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ConvertStructuredFiltersToEntityFilterCollection(FilterJsonObject, PayloadJsonObject, TestedEntityFilterCollectionNode, FieldFilterGroupingOperator, 132526);
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(TestedEntityFilterCollectionNode);

    //     // [Then] The created FilterCollectionNode is equal to manually created filter
    //     EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
    //     EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '01121212', 'No', 'Edm.String');
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(EntityFilterCollectionNode);

    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    // end;

    // [Test]
    // procedure TestEditInExcelStructuredFilterNoFilter()
    // var
    //     EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
    //     JsonFilter: Text;
    //     JsonPayload: Text;
    //     FilterJsonObject: JsonObject;
    //     PayloadJsonObject: JsonObject;
    //     EntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     FieldFilterGroupingOperator: Dictionary of [Text, Text];
    // begin
    //     // [Scenario] Empty JSON filter object is passed when calling Edit in Excel
    //     Init();

    //     // [Given] An empty object is passed in filter and payload
    //     JsonFilter := '{}';
    //     JsonPayload := '{}';
    //     LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
    //     LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

    //     // [When] FilterCollectionNode is created
    //     TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
    //     TestedEntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ConvertStructuredFiltersToEntityFilterCollection(FilterJsonObject, PayloadJsonObject, TestedEntityFilterCollectionNode, FieldFilterGroupingOperator, 132526);
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(TestedEntityFilterCollectionNode);

    //     // [Then] The created FilterCollectionNode is equal to manually created filter
    //     EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
    //     EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(EntityFilterCollectionNode);

    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    // end;

    // [Test]
    // procedure TestEditInExcelStructuredFilterIllegalFilter()
    // var
    //     EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
    //     JsonFilter: Text;
    //     JsonPayload: Text;
    //     FilterJsonObject: JsonObject;
    //     PayloadJsonObject: JsonObject;
    //     EntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;
    //     FieldFilterGroupingOperator: Dictionary of [Text, Text];
    // begin
    //     // [Scenario] API is called with a json filter that contains bor "OR" and "AND" operators, which is not supported by OData
    //     Init();

    //     // [Given] A Json filter with both or and and operator on the Date field, Json Payload
    //     JsonFilter := '{"type":"and","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"1000"}},{"type":"or","childNodes":[{"type":"ge","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"0"}},{"type":"le","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"100"}}]}]}';
    //     JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';
    //     LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
    //     LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

    //     // [When] The FilterCollectionNode is Created
    //     TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
    //     TestedEntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     EditinExcelTestLibrary.ConvertStructuredFiltersToEntityFilterCollection(FilterJsonObject, PayloadJsonObject, TestedEntityFilterCollectionNode, FieldFilterGroupingOperator, 132526);
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(TestedEntityFilterCollectionNode);

    //     // [Then] The created Node is equal to manually created FilterCollectionNode, which ignores the additional illegal filters
    //     EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
    //     EntityFilterCollectionNode.Operator := format("Excel Filter Node Type"::"and");
    //     AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '1000', 'No', 'Edm.String');
    //     EditinExcelTestLibrary.ReduceRedundantFilterCollectionNodes(EntityFilterCollectionNode);

    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equals');
    //     LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    // end;

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

    local procedure AppendFilterBinaryNode(EntityFilterCollectionNode: DotNet FilterCollectionNode; Operator: Text; RightNodeVal: Text; LeftOperandField: Text; LeftOperandType: Text)
    var
        FilterBinaryNode: DotNet FilterBinaryNode;
        FilterLeftOperand: DotNet FilterLeftOperand;
    begin
        FilterBinaryNode := FilterBinaryNode.FilterBinaryNode();
        FilterLeftOperand := FilterLeftOperand.FilterLeftOperand();

        FilterBinaryNode.Operator := Operator;
        FilterLeftOperand.Field := LeftOperandField;
        FilterLeftOperand.Type := LeftOperandType;
        FilterBinaryNode.Left := FilterLeftOperand;
        FilterBinaryNode.Right := RightNodeVal;
        EntityFilterCollectionNode.Collection.Add(FilterBinaryNode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Edit in Excel", 'OnEditInExcel', '', false, false)]
    local procedure OnEditInExcelWithSearch(ServiceName: Text[240])
    begin
        EventServiceName := ServiceName;
    end;
}

