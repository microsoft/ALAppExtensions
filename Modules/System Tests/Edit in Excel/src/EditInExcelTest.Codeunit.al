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
        // JSON filters and payloads are passed from platform, in order to retreive them, an AL extension is needed.
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

    [Test]
    procedure TestEditInExcelInvalidFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

    begin
        // [Scenario] Invalid json filter is passed
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '"type":"and","childNodes":[{"type":"or","childNodes":[{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"10000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"20000"}}]},{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"30000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"40000"}}]}]}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';
        LibraryAssert.IsFalse(FilterJsonObject.ReadFrom(JsonFilter), 'JSON filter should not be read - invalid');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"or");

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;

    [Test]
    procedure TestEditInExcel4OrFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

    begin
        // [Scenario] User clicks "Edit in Excel" with filter on "No" field - 4 or filters
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"or","childNodes":[{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"10000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"20000"}}]},{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"30000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"40000"}}]}]}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"or");
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '10000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '20000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '30000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '40000', 'No', 'Edm.String');

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;



    [Test]
    procedure TestEditInExcelAndOrFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

    begin
        // [Scenario] User clicks "Edit in Excel" with filtering on "No" field
        // Desired filter by user: (((No eq '10000') or (No eq '20000')) and ((No eq '30000') or (No eq '40000')))
        // Since this is invalid in BC, the two latter filters (30000 and 40000) are cut off
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"or","childNodes":[{"type":"or","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},' +
        '"rightNode":{"type":"Edm.String constant","value":"10000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"20000"}}]},' +
        '{"type":"and","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"30000"}},{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"40000"}}]}]}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"or");
        // Sinche the 3rd and 4th filter are marked with "and" instead of "or", they will be omitted
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '10000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '20000', 'No', 'Edm.String');

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;

    [Test]
    procedure TestEditInExcel4Or1AndFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        EntityFilterNumberCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

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

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        // We expect this: (((No eq '10000') or (No eq '20000') or (No eq '30000') or (No eq '40000')) and (Country_Region_Code eq 'GB'))
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"and");

        EntityFilterNumberCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterNumberCollectionNode.Operator := format("Excel Filter Node Type Test"::"or");
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '10000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '20000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '30000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '40000', 'No', 'Edm.String');
        EntityFilterCollectionNode.Collection.Add(EntityFilterNumberCollectionNode);

        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', 'GB', 'Country_Region_Code', 'Edm.String');

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;

    [Test]
    procedure TestEditInExcel4Or1DimensionFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        EntityFilterNumberCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

    begin
        // [Scenario] User clicks "Edit in Excel" with filter on "No" field - 4 or filters along with other one-dimensional filters
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"or","childNodes":[{"type":"or","childNodes":[{"type":"eq","leftNode":' +
                      '{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"10000"}},{"type":"eq","leftNode"' +
                      ':{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"20000"}}]},{"type":"or",' +
                      '"childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"30000"}},' +
                      '{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"40000"}}]}]},{"type":' +
                      '"eq","leftNode":{"type":"var","name":"Global_Dimension_1_Code"},"rightNode":{"type":"Edm.String constant","value":"SALES"}}]}';
        JsonPayload := '{ "fieldPayload": { "No": { "alName": "No.", "validInODataFilter": true, "edmType": "Edm.String" }, "Global_Dimension_1_Code": {"alName": "Global Dimension 1 Code","validInODataFilter": true, "edmType": "Edm.String" }}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        // We expect this: (((No eq '10000') or (No eq '20000') or (No eq '30000') or (No eq '40000')) and (Country_Region_Code eq 'GB'))
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"and");

        EntityFilterNumberCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterNumberCollectionNode.Operator := format("Excel Filter Node Type Test"::"or");
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '10000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '20000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '30000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterNumberCollectionNode, 'eq', '40000', 'No', 'Edm.String');
        EntityFilterCollectionNode.Collection.Add(EntityFilterNumberCollectionNode);

        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', 'SALES', 'Global_Dimension_1_Code', 'Edm.String');

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;

    [Test]
    procedure TestEditInExcelFilter1ValueForEachField()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

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

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        // We expect this: ( (No eq '10000') and (Global_Dimension_1_Code eq 'SALES'))
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"and");
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', '10000', 'No', 'Edm.String');
        AppendFilterBinaryNode(EntityFilterCollectionNode, 'eq', 'SALES', 'Global_Dimension_1_Code', 'Edm.String');

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;

    [Test]
    procedure TestEditInExcelFilterDefaultNoFields()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

    begin
        // [Scenario] An empty filter is passed, date_filter is selected on the page (not passed from platform)
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[]}';
        JsonPayload := '{ "fieldPayload": {}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        // We expect this: ((No eq '10000'))
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"and");

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;


    [Test]
    procedure TestEditInExcelFilter1Field()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

    begin
        // [Scenario] User clicks "Edit in Excel" with one selected filter with one value
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{"type":"and","childNodes":[{"type":"eq","leftNode":{"type":"var","name":"No"},"rightNode":{"type":"Edm.String constant","value":"10000"}}]}';
        JsonPayload := '{ "fieldPayload": {}}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"and");

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
    end;

    [Test]
    procedure TestEditInExcelFilterNoFilter()
    var
        EditinExcelTestLibrary: Codeunit "Edit in Excel Test Library";
        JsonFilter: Text;
        JsonPayload: Text;
        FilterJsonObject: JsonObject;
        PayloadJsonObject: JsonObject;
        EntityFilterCollectionNode: DotNet FilterCollectionNode;
        TestedEntityFilterCollectionNode: DotNet FilterCollectionNode;

    begin
        // [Scenario] User clicks "Edit in Excel" and empty filter is passed
        Init();

        // [Given] A Json Structured filter and Payload
        JsonFilter := '{}';
        JsonPayload := '{}';
        LibraryAssert.IsTrue(FilterJsonObject.ReadFrom(JsonFilter), 'Could not read json filter');
        LibraryAssert.IsTrue(PayloadJsonObject.ReadFrom(JsonPayload), 'Could not read json payload');

        // [When] The FilterCollectionNode is created
        TestedEntityFilterCollectionNode := TestedEntityFilterCollectionNode.FilterCollectionNode();
        EditinExcelTestLibrary.AssembleFilter(TestedEntityFilterCollectionNode, FilterJsonObject, PayloadJsonObject, 132526);

        // [Then] It should be equal to manually created  FilterCollectionNode 
        EntityFilterCollectionNode := EntityFilterCollectionNode.FilterCollectionNode();
        EntityFilterCollectionNode.Operator := format("Excel Filter Node Type Test"::"and");

        LibraryAssert.AreEqual(EntityFilterCollectionNode.Collection.Count(), TestedEntityFilterCollectionNode.Collection.Count(), 'Size of collections not equal');
        LibraryAssert.AreEqual(EntityFilterCollectionNode.ToString(), TestedEntityFilterCollectionNode.ToString(), 'Filters not Equal');
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

