codeunit 139720 "APIV1 - Aged AR E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Aged Report]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'agedAccountsReceivable';

    [Test]
    procedure TestGetAgedARRecords()
    var
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve Aged Accounts Payable Report information from the agedAccountsPayable API.
        Initialize();

        // [WHEN] A GET request is made to the agedAccountsPayable API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Aged AR", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The response is empty.
        Assert.AreNotEqual('', ResponseText, 'GET response must not be empty.');
    end;

    [Test]
    procedure TestCreateAgedARRecord()
    var
        TempAgedReportEntity: Record "Aged Report Entity" temporary;
        AgedReportEntityJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a agedAccountsPayable record through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a agedAccountsPayable JSON object to send to the service.
        AgedReportEntityJSON := GetAgedARJSON(TempAgedReportEntity);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Aged AR", ServiceNameTxt);
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, AgedReportEntityJSON, ResponseText);

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

    local procedure GetAgedARJSON(var AgedReportEntity: Record "Aged Report Entity") AgedReportEntityJSON: Text
    begin
        IF AgedReportEntity."No." = '' THEN
            AgedReportEntity."No." := LibraryUtility.GenerateRandomCode(AgedReportEntity.FIELDNO("No."), DATABASE::"Aged Report Entity");
        AgedReportEntityJSON := LibraryGraphMgt.AddPropertytoJSON('', 'vendorNumber', AgedReportEntity."No.");
    end;
}








