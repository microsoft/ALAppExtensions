// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148080 "Library - Making Tax Digital"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [Library]
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        OAuthSandboxSetupLbl: Label 'HMRC VAT Sandbox', Locked = true;
        OAuthPRODSetupLbl: Label 'HMRC VAT', Locked = true;
        IncludingLbl: Label 'including %1 new and %2 modified records.', Comment = '%1, %2 - records count';
        ReasonLbl: Label 'Reason: ';
        InvokeRequestLbl: Label 'Invoke %1 request.', Locked = true;

    procedure CreateEnabledOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        CreateOAuthSetup(OAuth20Setup, OAuth20Setup.Status::Enabled);
    end;

    procedure CreateDisbaledOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        CreateOAuthSetup(OAuth20Setup, OAuth20Setup.Status::Disabled);
    end;

    local procedure CreateOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"; NewStatus: Option)
    begin
        with OAuth20Setup do begin
            if not Get(OAuthSandboxSetupLbl) then begin
                Init();
                Code := OAuthSandboxSetupLbl;
                Insert();
            end;
            Status := NewStatus;
            Description := LibraryUtility.GenerateGUID();
            "Service URL" := 'https://TestServiceURL';
            "Redirect URL" := 'https://TestRedirectURL';
            Scope := LibraryUtility.GenerateGUID();
            "Authorization URL Path" := '/TestAuthorizationURLPath';
            "Access Token URL Path" := '/TestAccessTokenURLPath';
            "Refresh Token URL Path" := '/TestRefreshTokenURLPath';
            "Authorization Response Type" := LibraryUtility.GenerateGUID();
            "Token DataScope" := "Token DataScope"::Company;
            SetOAuthSetupTestTokens(OAuth20Setup);
            Modify(true);
        end;
    end;

    local procedure CreateTestRequestJson(): Text
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        JSONMgt.SetValue('ClientID', 'TestClientID');
        JSONMgt.SetValue('ClientSecret', 'TestClientSecret');
        JSONMgt.SetValue('AccessToken', 'TestAccessToken');
        JSONMgt.SetValue('RefreshToken', 'TestRefreshToken');
        exit(JSONMgt.WriteObjectToString());
    end;

    local procedure CreateAccessTokenResponseJson(): Text
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        JSONMgt.SetValue('access_token', 'NewTestAccessToken');
        JSONMgt.SetValue('refresh_token', 'NewTestRefreshToken');
        exit(JSONMgt.WriteObjectToString());
    end;

    procedure MockVATPayment(var MTDPayment: Record "MTD Payment"; StartDate: Date; EndDate: Date; EntryNo: Integer; ReceivedDate: Date; NewAmount: Decimal)
    begin
        with MTDPayment do begin
            Init();
            "Start Date" := StartDate;
            "End Date" := EndDate;
            "Entry No." := EntryNo;
            "Received Date" := ReceivedDate;
            Amount := NewAmount;
            Insert();
        end;
    end;

    procedure MockVATLiability(var MTDLiability: Record "MTD Liability"; StartDate: Date; EndDate: Date; NewType: Option; OriginalAmount: Decimal; OutstandingAmount: Decimal; DueDate: Date)
    begin
        with MTDLiability do begin
            Init();
            "From Date" := StartDate;
            "To Date" := EndDate;
            Type := NewType;
            "Original Amount" := OriginalAmount;
            "Outstanding Amount" := OutstandingAmount;
            "Due Date" := DueDate;
            Insert();
        end;
    end;

    procedure MockVATReturnPeriod(var VATReturnPeriod: Record "VAT Return Period"; StartDate: Date; EndDate: Date; DueDate: Date; PeriodKey: Code[10]; NewStatus: Option; ReceivedDate: Date)
    begin
        with VATReturnPeriod do begin
            Init();
            "No." := LibraryUtility.GenerateGUID();
            "Start Date" := StartDate;
            "End Date" := EndDate;
            "Due Date" := DueDate;
            "Period Key" := PeriodKey;
            Status := NewStatus;
            "Received Date" := ReceivedDate;
            Insert();
        end;
    end;

    procedure MockVATReturnDetail(var MTDReturnDetails: Record "MTD Return Details"; StartDate: Date; EndDate: Date; PeriodKey: Code[10]; VATDueSales: Decimal; VATDueAcquisitions: Decimal; TotalVATDue: Decimal; VATReclaimedCurrPeriod: Decimal; NetVATDue: Decimal; TotalValueSalesExclVAT: Decimal; TotalValuePurchasesExclVAT: Decimal; TotalValueGoodsSupplExVAT: Decimal; TotalAcquisitionsExclVAT: Decimal; NewFinalised: Boolean)
    begin
        with MTDReturnDetails do begin
            Init();
            "Start Date" := StartDate;
            "End Date" := EndDate;
            "Period Key" := PeriodKey;
            "VAT Due Sales" := VATDueSales;
            "VAT Due Acquisitions" := VATDueAcquisitions;
            "Total VAT Due" := TotalVATDue;
            "VAT Reclaimed Curr Period" := VATReclaimedCurrPeriod;
            "Net VAT Due" := NetVATDue;
            "Total Value Sales Excl. VAT" := TotalValueSalesExclVAT;
            "Total Value Purchases Excl.VAT" := TotalValuePurchasesExclVAT;
            "Total Value Goods Suppl. ExVAT" := TotalValueGoodsSupplExVAT;
            "Total Acquisitions Excl. VAT" := TotalAcquisitionsExclVAT;
            Finalised := NewFinalised;
            Insert();
        end;
    end;

    procedure MockLinkedVATReturnHeader(var VATReportHeader: Record "VAT Report Header"; var VATReturnPeriod: Record "VAT Return Period")
    begin
        with VATReportHeader do begin
            "VAT Report Config. Code" := "VAT Report Config. Code"::"VAT Return";
            "No." := LibraryUtility.GenerateGUID();
            "VAT Report Version" := 'HMRC MTD';
            "Return Period No." := VATReturnPeriod."No.";
            Insert(true);
        end;
        VATReturnPeriod."VAT Return No." := VATReportHeader."No.";
        VATReturnPeriod.Modify();
    end;

    procedure MockLinkedVATReturnHeader(var VATReportHeader: Record "VAT Report Header"; var VATReturnPeriod: Record "VAT Return Period"; NewStatus: Option)
    begin
        MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod);
        VATReportHeader.Status := NewStatus;
        VATReportHeader.Modify();
    end;

    procedure MockVATStatementReportLine(VATReportHeader: Record "VAT Report Header"; LineNo: Integer; BoxNo: Text[30]; NewAmount: Decimal)
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        with VATStatementReportLine do begin
            Init();
            "VAT Report No." := VATReportHeader."No.";
            "VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code";
            "Line No." := LineNo;
            "Box No." := BoxNo;
            Amount := NewAmount;
            Insert();
        end;
    end;

    procedure MockVATStatementReportLinesWithRandomValues(VATReportHeader: Record "VAT Report Header")
    var
        i: Integer;
    begin
        for i := 1 to 9 do
            MockVATStatementReportLine(VATReportHeader, i, Format(i), LibraryRandom.RandDecInRange(10000, 20000, 2));
    end;

    procedure PrepareResponseOnRequestAccessToken(Result: Boolean; HttpError: Text)
    begin
        PrepareCustomResponse(Result, HttpError, CreateAccessTokenResponseJson(), '');
    end;

    procedure PrepareCustomResponse(Result: Boolean; HttpError: Text; ContentJson: Text; ErrorJson: Text)
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        SetNameValueBuffer_Result(Result);
        SetNameValueBuffer_HttpError(HttpError);
        JSONMgt.AddJson('Content', ContentJson);
        if ErrorJson <> '' then
            JSONMgt.AddJson('Error', ErrorJson);
        SetNameValueBuffer_JsonResponse(JSONMgt.WriteObjectToString());
    end;

    procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get();
            "VAT Registration No." := LibraryERM.GenerateVATRegistrationNo(CompanyInformation."Country/Region Code");
            Modify(true);
        end;
    end;

    local procedure SetNameValueBuffer_Result(Result: Boolean)
    begin
        SetNameValueBufferValue('Result', Format(Result));
    end;

    local procedure SetNameValueBuffer_HttpError(HttpError: Text)
    begin
        SetNameValueBufferValue('HttpError', HttpError);
    end;

    local procedure SetNameValueBuffer_JsonResponse(JsonResponse: Text)
    begin
        SetNameValueBufferValue('JsonResponse', JsonResponse);
    end;

    local procedure SetNameValueBuffer_JsonRequest(JsonRequest: Text)
    begin
        SetNameValueBufferValue('JsonRequest', JsonRequest);
    end;

    local procedure SetNameValueBufferValue(NewName: Text; NewValue: Text)
    var
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        with NameValueBuffer do begin
            Init();
            Validate(Name, NewName);
            SetValueWithoutModifying(NewValue);
            Insert(true);
        end;
    end;

    local procedure GetNameValueBuffer_Result() Result: Text
    var
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        with NameValueBuffer do begin
            SetRange(Name, 'Result');
            FindFirst();
            Result := GetValue();
            Delete();
        end;
    end;

    local procedure GetNameValueBuffer_HttpError() Result: Text
    var
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        with NameValueBuffer do begin
            SetRange(Name, 'HttpError');
            FindFirst();
            Result := GetValue();
            Delete();
        end;
    end;

    local procedure GetNameValueBuffer_JsonResponse() Result: Text
    var
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        with NameValueBuffer do begin
            SetRange(Name, 'JsonResponse');
            FindFirst();
            Result := GetValue();
            Delete();
        end;
    end;

    procedure GetNameValueBuffer_JsonRequest() Result: Text
    var
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        with NameValueBuffer do begin
            SetRange(Name, 'JsonRequest');
            FindFirst();
            Result := GetValue();
            Delete();
        end;
    end;

    procedure GetOAuthSandboxSetupCode(): Code[20]
    begin
        exit(CopyStr(OAuthSandboxSetupLbl, 1, 20));
    end;

    procedure GetOAuthProdSetupCode(): Code[20]
    begin
        exit(CopyStr(OAuthPRODSetupLbl, 1, 20));
    end;

    procedure GetResonLbl(): Text
    begin
        exit(ReasonLbl);
    end;

    procedure GetIncludingLbl(): Text
    begin
        exit(IncludingLbl);
    end;

    procedure GetInvokeRequestLbl(Method: Text): Text
    begin
        exit(StrSubstNo(InvokeRequestLbl, Method));
    end;

    procedure GetVATStatementReportLineAmount(VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30]): Decimal
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        with VATStatementReportLine do begin
            SetRange("VAT Report No.", VATReportHeader."No.");
            SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
            SetRange("Box No.", BoxNo);
            FindFirst();
            exit(Amount);
        end;
    end;

    procedure GetVATReportSubmissionText(VATReportHeader: Record "VAT Report Header"): Text
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Record TempBlob;
        DummyGUID: Guid;
    begin
        VATReportArchive.Get(VATReportArchive."VAT Report Type"::"VAT Return", VATReportHeader."No.", DummyGUID);
        Assert.IsTrue(VATReportArchive."Submission Message BLOB".HasValue(), 'VATReportArchive."Submission Message BLOB".HasValue');
        VATReportArchive.CalcFields("Submission Message BLOB");
        TempBlob.Init();
        TempBlob.Blob := VATReportArchive."Submission Message BLOB";
        exit(TempBlob.ReadAsText('', TextEncoding::UTF8));
    end;

    procedure GetVATReportResponseText(VATReportHeader: Record "VAT Report Header"): Text
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Record TempBlob;
        DummyGUID: Guid;
    begin
        VATReportArchive.Get(VATReportArchive."VAT Report Type"::"VAT Return", VATReportHeader."No.", DummyGUID);
        Assert.IsTrue(VATReportArchive."Response Message BLOB".HasValue(), 'VATReportArchive."Response Message BLOB".HasValue');
        VATReportArchive.CalcFields("Response Message BLOB");
        TempBlob.Init();
        TempBlob.Blob := VATReportArchive."Response Message BLOB";
        exit(TempBlob.ReadAsText('', TextEncoding::UTF8));
    end;

    local procedure SetOAuthSetupTestTokens(var OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        with OAuth20Setup do begin
            SetToken("Client ID", 'Dummy Test Client ID');
            SetToken("Client Secret", 'Dummy Test Client Secret');
            SetToken("Access Token", 'Dummy Test Access Token');
            SetToken("Refresh Token", 'Dummy Test Refresh Token');
        end;
    end;

    procedure SetOAuthSetupSandbox(IsSandbox: Boolean)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        with VATReportSetup do begin
            Get();
            if IsSandbox then
                Validate("MTD OAuth Setup Option", "MTD OAuth Setup Option"::Sandbox)
            else
                Validate("MTD OAuth Setup Option", "MTD OAuth Setup Option"::Production);
            Modify(true);
        end;
    end;

    procedure FormatValue(Value: Variant): Text
    begin
        EXIT(Format(Value, 0, 9));
    end;

    procedure ParseVATReturnDetailsJson(var MTDReturnDetails: Record "MTD Return Details"; JsonString: Text)
    var
        JsonMgt: Codeunit "JSON Management";
        RecordRef: RecordRef;
    begin
        Assert.IsTrue(JsonMgt.InitializeFromString(JsonString), 'JsonMgt.InitializeFromString');

        RecordRef.GetTable(MTDReturnDetails);
        WITH MTDReturnDetails DO BEGIN
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'periodKey', FIELDNO("Period Key"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'vatDueSales', FIELDNO("VAT Due Sales"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'vatDueAcquisitions', FIELDNO("VAT Due Acquisitions"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalVatDue', FIELDNO("Total VAT Due"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'vatReclaimedCurrPeriod', FIELDNO("VAT Reclaimed Curr Period"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'netVatDue', FIELDNO("Net VAT Due"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalValueSalesExVAT', FIELDNO("Total Value Sales Excl. VAT"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalValuePurchasesExVAT', FIELDNO("Total Value Purchases Excl.VAT"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalValueGoodsSuppliedExVAT', FIELDNO("Total Value Goods Suppl. ExVAT"));
            JSONMgt.GetValueAndSetToRecFieldNo(RecordRef, 'totalAcquisitionsExVAT', FIELDNO("Total Acquisitions Excl. VAT"));
        END;
        RecordRef.SetTable(MTDReturnDetails);
    end;

    procedure VerifyLatestHttpLogForSandbox(ExpectedResult: Boolean; ExpectedDescription: Text; ExpectedMessage: Text; HasDetails: Boolean)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ActivityLog: Record "Activity Log";
        ExpectedStatus: Option;
    begin
        OAuth20Setup.Get(OAuthSandboxSetupLbl);
        IF ExpectedResult THEN
            ExpectedStatus := ActivityLog.Status::Success
        ELSE
            ExpectedStatus := ActivityLog.Status::Failed;

        with ActivityLog do begin
            get(OAuth20Setup."Activity Log ID");
            TestField(Context, StrSubstNo('OAuth 2.0 %1', OAuth20Setup.Code));
            TestField(Status, ExpectedStatus);
            TestField(Description, CopyStr(ExpectedDescription, 1, MaxStrLen(Description)));
            TestField("Activity Message", CopyStr(ExpectedMessage, 1, MaxStrLen("Activity Message")));
            Assert.AreEqual(HasDetails, "Detailed Info".HasValue(), 'ActivityLog."Detailed Info".HasValue');
        end;
    end;

    procedure VerifyRequestJson(ExpectedMethod: Text; ExpectedURLRequestPath: Text)
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        JSONMgt.InitializeFromString(GetNameValueBuffer_JsonRequest());
        Assert.ExpectedMessage(ExpectedMethod, JSONMgt.GetValue('Method'));
        Assert.ExpectedMessage(ExpectedURLRequestPath, JSONMgt.GetValue('URLRequestPath'));
        Assert.ExpectedMessage('application/vnd.hmrc.1.0+json', JSONMgt.GetValue('Header.Accept'));
        Assert.ExpectedMessage('application/json', JSONMgt.GetValue('Header.Content-Type'));
        Assert.ExpectedMessage('Bearer TestAccessToken', JSONMgt.GetValue('Header.Authorization'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OAuth 2.0 Mgt.", 'OnBeforeCreateJsonRequest', '', true, true)]
    local procedure OnBeforeCreateJsonRequest(var RequestJson: Text)
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        JSONMgt.InitializeObject(RequestJson);
        JSONMgt.AddJson('Test', CreateTestRequestJson());
        RequestJson := JSONMgt.WriteObjectToString();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Http Web Request Mgt.", 'OnBeforeInvokeTestJSONRequest', '', true, true)]
    local procedure OnBeforeInvokeTestJSONRequest(VAR Result: Boolean; RequestJson: Text; VAR ResponseJson: Text; VAR HttpError: Text)
    begin
        SetNameValueBuffer_JsonRequest(RequestJson);
        EVALUATE(Result, GetNameValueBuffer_Result());
        HttpError := GetNameValueBuffer_HttpError();
        ResponseJson := GetNameValueBuffer_JsonResponse();
    end;
}