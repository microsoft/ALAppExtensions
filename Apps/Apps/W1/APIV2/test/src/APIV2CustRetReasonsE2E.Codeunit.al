codeunit 139869 "APIV2 - Cust. Ret. Reasons E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Sales] [Credit Memo]
    end;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        EmptyJSONErr: Label 'JSON should not be empty.';
        ServiceNameTxt: Label 'customerReturnReasons';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetReasonCode()
    var
        ReasonCode: Record "Reason Code";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get a reason code with a GET request to the service.
        Initialize();

        // [GIVEN] A reason code exists in the system.
        CreateReasonCode(ReasonCode);

        // [WHEN] The user makes a GET request for a given reason code.
        TargetURL := LibraryGraphMgt.CreateTargetURL(ReasonCode.SystemId, Page::"APIV2 - Cust. Return Reasons", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the reason code information.
        VerifyProperties(Response, ReasonCode);
    end;

    [Test]
    procedure TestCreateReasonCode()
    var
        ReasonCode: Record "Reason Code";
        TempReasonCode: Record "Reason Code" temporary;
        ReasonCodeJSON: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can create a new reason code through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a reason code JSON object to send to the service.
        CreateReasonCode(TempReasonCode);
        ReasonCodeJSON := GetReasonCodeJSON(TempReasonCode);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Cust. Return Reasons", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, ReasonCodeJSON, Response);

        // [THEN] The reason code has been created in the database with all the details.
        ReasonCode.Get(TempReasonCode.Code);
        VerifyProperties(Response, ReasonCode);
    end;

    [Test]
    procedure TestModifyReasonCode()
    var
        ReasonCode: Record "Reason Code";
        TempReasonCode: Record "Reason Code" temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can modify description in a reason code through a PATCH request.
        Initialize();

        // [GIVEN] A reason code exists with a description.
        CreateReasonCode(ReasonCode);
        TempReasonCode.TransferFields(ReasonCode);
        TempReasonCode.Description := LibraryUtility.GenerateGUID();
        RequestBody := GetReasonCodeJSON(TempReasonCode);

        // [WHEN] The user makes a patch request to the service and specifies description field.
        TargetURL := LibraryGraphMgt.CreateTargetURL(ReasonCode.SystemId, Page::"APIV2 - Cust. Return Reasons", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the new value.
        VerifyProperties(Response, TempReasonCode);

        // [THEN] The reason code in the database contains the updated value.
        ReasonCode.Get(ReasonCode.Code);
        Assert.AreEqual(ReasonCode.Description, TempReasonCode.Description, 'Descriptions should be equal.');
    end;

    [Test]
    procedure TestDeleteReasonCode()
    var
        ReasonCode: Record "Reason Code";
        ReasonCodeCode: Code[10];
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can delete a reason code by making a DELETE request.
        Initialize();

        // [GIVEN] A reason code exists.
        CreateReasonCode(ReasonCode);
        ReasonCodeCode := ReasonCode.Code;

        // [WHEN] The user makes a DELETE request to the endpoint for the reason code.
        TargetURL := LibraryGraphMgt.CreateTargetURL(ReasonCode.SystemId, Page::"APIV2 - Cust. Return Reasons", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The reason code is no longer in the database.
        ReasonCode.SetRange(Code, ReasonCodeCode);
        Assert.IsTrue(ReasonCode.IsEmpty(), 'Reason Code should be deleted.');
    end;

    local procedure GetReasonCodeJSON(var ReasonCode: Record "Reason Code") ReasonCodeJSON: Text
    begin
        ReasonCodeJSON := LibraryGraphMgt.AddPropertytoJSON(ReasonCodeJSON, 'code', ReasonCode.Code);
        ReasonCodeJSON := LibraryGraphMgt.AddPropertytoJSON(ReasonCodeJSON, 'description', ReasonCode.Description);
        exit(ReasonCodeJSON);
    end;

    local procedure VerifyProperties(JSON: Text; ReasonCode: Record "Reason Code")
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJSON(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'code', ReasonCode.Code);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'description', ReasonCode.Description);
    end;

    local procedure CreateReasonCode(var ReasonCode: Record "Reason Code")
    begin
        LibraryERM.CreateReasonCode(ReasonCode);
        Commit();
    end;
}