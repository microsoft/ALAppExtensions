codeunit 139816 "APIV2 - Income Statement E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Income Statement]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'incomeStatement';

    [Test]
    procedure TestGetIncomeStatementRecords()
    var
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] User can retrieve Income Statement Report information from the incomeStatement API.
        Initialize();

        // [WHEN] A GET request is made to the incomeStatement API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Income Statement", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response is empty.
        Assert.AreNotEqual('', ResponseText, 'GET response must not be empty.');
    end;

    [Test]
    procedure TestCreateIncomeStatementRecord()
    var
        TempAccScheduleLineEntity: Record "Acc. Schedule Line Entity" temporary;
        IncomeStatementEntityBufferJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a incomeStatement record through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a incomeStatement JSON object to send to the service.
        IncomeStatementEntityBufferJSON := GetIncomeStatementJSON(TempAccScheduleLineEntity);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Income Statement", ServiceNameTxt);
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

    procedure GetIncomeStatementJSON(var AccScheduleLineEntity: Record "Acc. Schedule Line Entity") IncomeStatementJSON: Text
    begin
        if AccScheduleLineEntity."Line No." = 0 then
            AccScheduleLineEntity."Line No." := LibraryRandom.RandIntInRange(1, 10000);
        if AccScheduleLineEntity.Description = '' then
            AccScheduleLineEntity.Description := LibraryUtility.GenerateGUID();

        IncomeStatementJSON := LibraryGraphMgt.AddPropertytoJSON('', 'lineNumber', AccScheduleLineEntity."Line No.");
        IncomeStatementJSON := LibraryGraphMgt.AddPropertytoJSON(IncomeStatementJSON, 'display', AccScheduleLineEntity.Description);
    end;
}









