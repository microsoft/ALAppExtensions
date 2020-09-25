codeunit 139815 "APIV2 - Balance Sheet E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Balance Sheet]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        ServiceNameTxt: Label 'balanceSheet';
        IsInitialized: Boolean;

    [Test]
    procedure TestGetBalanceSheetRecords()
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve Balance Sheet Report information from the balanceSheet API.
        Initialize();

        // [WHEN] A GET request is made to the balanceSheet API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Balance Sheet", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response is empty.
        Assert.AreNotEqual('', ResponseText, 'GET response must not be empty.');
    end;

    [Test]
    procedure TestCreateBalanceSheetRecord()
    var
        TempBalanceSheetBuffer: Record "Balance Sheet Buffer" temporary;
        BalanceSheetBufferJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a balanceSheet record through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a balanceSheet JSON object to send to the service.
        BalanceSheetBufferJSON := GetBalanceSheetJSON(TempBalanceSheetBuffer);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Balance Sheet", ServiceNameTxt);
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, BalanceSheetBufferJSON, ResponseText);

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

    local procedure GetBalanceSheetJSON(var BalanceSheetBuffer: Record "Balance Sheet Buffer") BalanceSheetJSON: Text
    begin
        if BalanceSheetBuffer."Line No." = 0 then
            BalanceSheetBuffer."Line No." := LibraryRandom.RandIntInRange(1, 10000);
        if BalanceSheetBuffer.Description = '' then
            BalanceSheetBuffer.Description := LibraryUtility.GenerateGUID();

        BalanceSheetJSON := LibraryGraphMgt.AddPropertytoJSON('', 'lineNumber', BalanceSheetBuffer."Line No.");
        BalanceSheetJSON := LibraryGraphMgt.AddPropertytoJSON(BalanceSheetJSON, 'display', BalanceSheetBuffer.Description);
    end;
}









