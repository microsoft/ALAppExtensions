codeunit 139717 "APIV1 - CashFlow Statement E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Cash Flow Statement]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'cashFlowStatement';

    [Test]
    procedure TestGetCashFlowRecords()
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve Cash Flow Statement Report information from the cashFlowStatement API.
        Initialize();

        // [WHEN] A GET request is made to the cashFlowStatement API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Cash Flow Statement", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response is empty.
        Assert.AreNotEqual('', ResponseText, 'GET response must not be empty.');
    end;

    [Test]
    procedure TestCreateCashFlowRecord()
    var
        TempAccScheduleLineEntity: Record "Acc. Schedule Line Entity" temporary;
        IncomeStatementEntityBufferJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a cashFlowStatement record through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a cashFlowStatement JSON object to send to the service.
        IncomeStatementEntityBufferJSON := GetIncomeStatementJSON(TempAccScheduleLineEntity);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Cash Flow Statement", ServiceNameTxt);
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, IncomeStatementEntityBufferJSON, ResponseText);

        // [THEN] The response is empty.
        Assert.AreEqual('', ResponseText, 'CREATE response must be empty.');
    end;

    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        LibraryApplicationArea.EnableFoundationSetup();
        IsInitialized := TRUE;
    end;

    local procedure GetIncomeStatementJSON(var AccScheduleLineEntity: Record "Acc. Schedule Line Entity") IncomeStatementJSON: Text
    var
        JSONManagement: Codeunit "JSON Management";
        "Newtonsoft.Json.Linq.JObject": DotNet JObject;
    begin
        JSONManagement.InitializeEmptyObject();
        JSONManagement.GetJSONObject("Newtonsoft.Json.Linq.JObject");
        if AccScheduleLineEntity."Line No." = 0 then
            AccScheduleLineEntity."Line No." := LibraryRandom.RandIntInRange(1, 10000);
        JSONManagement.AddJPropertyToJObject("Newtonsoft.Json.Linq.JObject", 'lineNumber', AccScheduleLineEntity."Line No.");

        if AccScheduleLineEntity.Description = '' then
            AccScheduleLineEntity.Description := LibraryUtility.GenerateGUID();

        JSONManagement.AddJPropertyToJObject("Newtonsoft.Json.Linq.JObject", 'display', AccScheduleLineEntity.Description);

        IncomeStatementJSON := JSONManagement.WriteObjectToString();
    end;
}






