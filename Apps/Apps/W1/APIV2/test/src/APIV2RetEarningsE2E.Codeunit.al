codeunit 139821 "APIV2 - Ret. Earnings E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Retained Earnings]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        ServiceNameTxt: Label 'retainedEarningsStatement';
        IsInitialized: Boolean;

    [Test]
    procedure TestRetainedEarningsStatementRecords()
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve Retained Earnings Statement Report information from the retainedEarningsStatement API.
        Initialize();

        // [WHEN] A GET request is made to the retainedEarningsStatement API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Retained Earnings", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response is empty.
        Assert.AreNotEqual('', ResponseText, 'GET response must not be empty.');
    end;

    [Test]
    procedure TestCreateRetainedEarningsStatementRecord()
    var
        TempAccScheduleLineEntity: Record "Acc. Schedule Line Entity" temporary;
        IncomeStatementEntityBufferJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a retainedEarningsStatement record through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a retainedEarningsStatement JSON object to send to the service.
        IncomeStatementEntityBufferJSON := GetIncomeStatementJSON(TempAccScheduleLineEntity);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Retained Earnings", ServiceNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, IncomeStatementEntityBufferJSON, ResponseText);

        // [THEN] The response is empty.
        Assert.AreEqual('', ResponseText, 'CREATE response must be empty.');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibraryApplicationArea.EnableFoundationSetup();
        IsInitialized := true;
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






