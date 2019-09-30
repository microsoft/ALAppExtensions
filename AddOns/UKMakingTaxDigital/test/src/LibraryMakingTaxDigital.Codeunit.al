// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148080 "Library - Making Tax Digital"
{
    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [Library]
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        LibraryAzureKVMockMgmt: Codeunit "Library - Azure KV Mock Mgmt.";
        OAuthSandboxSetupLbl: Label 'HMRC VAT Sandbox', Locked = true;
        OAuthPRODSetupLbl: Label 'HMRC VAT', Locked = true;
        IncludingLbl: Label 'including %1 new and %2 modified records.', Comment = '%1, %2 - records count';
        ReasonLbl: Label 'Reason from the HMRC server: ';
        InvokeRequestLbl: Label 'Invoke %1 request.', Locked = true;

    [Scope('OnPrem')]
    procedure DisableFraudPreventionHeaders(DisableFPHeaders: Boolean)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        with VATReportSetup do begin
            Get();
            "MTD Disable FraudPrev. Headers" := DisableFPHeaders;
            Modify();
        end;
    end;

    [Scope('OnPrem')]
    procedure SetupOAuthAndVATRegNo(EnabledOAuth: Boolean; URL: Text; VATRegNo: Text)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        if EnabledOAuth then
            OAuth20Setup.Status := OAuth20Setup.Status::Enabled
        else
            OAuth20Setup.Status := OAuth20Setup.Status::Disabled;
        CreateOAuthSetup(OAuth20Setup, OAuth20Setup.Status, URL, 0DT);
        if VATRegNo <> '' then
            UpdateCompanyInformation(VATRegNo);
    end;

    [Scope('OnPrem')]
    procedure CreateOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"; NewStatus: Option; URLPath: Text; AccessTokenDueDateTime: DateTime)
    begin
        with OAuth20Setup do begin
            if not Get(OAuthSandboxSetupLbl) then begin
                Init();
                Code := OAuthSandboxSetupLbl;
                Insert();
            end;
            Status := NewStatus;
            Description := LibraryUtility.GenerateGUID();
            "Service URL" := 'https://localhost:8080/test-api.service.hmrc.gov.uk';
            if URLPath <> '' then
                "Service URL" += URLPath;
            "Redirect URL" := 'urn:ietf:wg:oauth:2.0:oob';
            Scope := 'write:vat read:vat';
            "Authorization URL Path" := '/oauth/authorize';
            "Access Token URL Path" := '/oauth/token';
            "Refresh Token URL Path" := '/oauth/token';
            "Authorization Response Type" := 'code';
            "Token DataScope" := "Token DataScope"::Company;
            SetOAuthSetupTestTokens(OAuth20Setup);
            "Daily Limit" := 1000;
            "Access Token Due DateTime" := AccessTokenDueDateTime;
            Modify(true);
        end;
    end;

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
    procedure MockLinkedVATReturnHeader(var VATReportHeader: Record "VAT Report Header"; var VATReturnPeriod: Record "VAT Return Period"; NewStatus: Option)
    begin
        MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod);
        VATReportHeader.Status := NewStatus;
        VATReportHeader.Modify();
    end;

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
    procedure MockVATStatementReportLinesWithRandomValues(VATReportHeader: Record "VAT Report Header")
    var
        i: Integer;
    begin
        for i := 1 to 9 do
            MockVATStatementReportLine(VATReportHeader, i, Format(i), LibraryRandom.RandDecInRange(10000, 20000, 2));
    end;

    [Scope('OnPrem')]
    procedure MockAzureClientToken(ClientToken: Text)
    begin
        LibraryAzureKVMockMgmt.InitMockAzureKeyvaultSecretProvider();
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('UKHMRC-MTDVAT-Sandbox-ClientID', ClientToken);
        LibraryAzureKVMockMgmt.EnsureSecretNameIsAllowed('UKHMRC-MTDVAT-Sandbox-ClientID');
        LibraryAzureKVMockMgmt.UseAzureKeyvaultSecretProvider();
    end;

    [Scope('OnPrem')]
    procedure UpdateCompanyInformation(VATRegNo: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get();
            "VAT Registration No." := CopyStr(VATRegNo, 1, MaxStrLen("VAT Registration No."));
            Modify(true);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetOAuthSandboxSetupCode(): Code[20]
    begin
        exit(CopyStr(OAuthSandboxSetupLbl, 1, 20));
    end;

    [Scope('OnPrem')]
    procedure GetOAuthProdSetupCode(): Code[20]
    begin
        exit(CopyStr(OAuthPRODSetupLbl, 1, 20));
    end;

    [Scope('OnPrem')]
    procedure GetResonLbl(): Text
    begin
        exit(ReasonLbl);
    end;

    [Scope('OnPrem')]
    procedure GetIncludingLbl(): Text
    begin
        exit(IncludingLbl);
    end;

    [Scope('OnPrem')]
    procedure GetInvokeRequestLbl(Method: Text): Text
    begin
        exit(StrSubstNo(InvokeRequestLbl, Method));
    end;

    [Scope('OnPrem')]
    procedure GetVATStatementReportLineAmount(VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30]): Decimal
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        FindVATStatementReportLine(VATStatementReportLine, VATReportHeader, BoxNo);
        exit(VATStatementReportLine.Amount);
    end;

    [Scope('OnPrem')]
    procedure FindVATStatementReportLine(var VATStatementReportLine: Record "VAT Statement Report Line"; VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30])
    begin
        with VATStatementReportLine do begin
            SetRange("VAT Report No.", VATReportHeader."No.");
            SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
            SetRange("Box No.", BoxNo);
            FindFirst();
        end;
    end;

    [Scope('OnPrem')]
    procedure GetVATReportSubmissionText(VATReportHeader: Record "VAT Report Header"): Text
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        DummyGUID: Guid;
    begin
        VATReportArchive.Get(VATReportArchive."VAT Report Type"::"VAT Return", VATReportHeader."No.", DummyGUID);
        Assert.IsTrue(VATReportArchive."Submission Message BLOB".HasValue(), 'VATReportArchive."Submission Message BLOB".HasValue');
        VATReportArchive.CalcFields("Submission Message BLOB");
        TempBlob.FromRecord(VATReportArchive, VATReportArchive.FieldNo("Submission Message BLOB"));
        TempBlob.CreateInstream(InStream);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, ''));
    end;

    [Scope('OnPrem')]
    procedure GetVATReportResponseText(VATReportHeader: Record "VAT Report Header"): Text
    var
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
        DummyGUID: Guid;
    begin
        VATReportArchive.Get(VATReportArchive."VAT Report Type"::"VAT Return", VATReportHeader."No.", DummyGUID);
        Assert.IsTrue(VATReportArchive."Response Message BLOB".HasValue(), 'VATReportArchive."Response Message BLOB".HasValue');
        VATReportArchive.CalcFields("Response Message BLOB");
        TempBlob.FromRecord(VATReportArchive, VATReportArchive.FieldNo("Response Message BLOB"));
        TempBlob.CreateInstream(InStream);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, ''));
    end;

    [Scope('OnPrem')]
    procedure GetLatestHttpLogText(): Text
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ActivityLog: Record "Activity Log";
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        OAuth20Setup.Get(OAuthSandboxSetupLbl);
        ActivityLog.Get(OAuth20Setup."Activity Log ID");
        ActivityLog.CalcFields("Detailed Info");
        TempBlob.FromRecord(ActivityLog, ActivityLog.FieldNo("Detailed Info"));
        TempBlob.CreateInStream(InStream);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, ''));
    end;

    [Scope('OnPrem')]
    procedure HttpStartDate(): Date
    begin
        exit(20200101D);
    end;

    [Scope('OnPrem')]
    procedure HttpEndDate(): Date
    begin
        exit(20200331D);
    end;

    [Scope('OnPrem')]
    procedure HttpDueDate(): Date
    begin
        exit(20200507D);
    end;

    [Scope('OnPrem')]
    procedure HttpReceivedDate(): Date
    begin
        exit(20200504D);
    end;

    [Scope('OnPrem')]
    procedure HttpPeriodKey(): Code[10]
    begin
        exit('20A1');
    end;

    [Scope('OnPrem')]
    procedure HttpAmount1(): Decimal
    begin
        exit(1234.56);
    end;

    [Scope('OnPrem')]
    procedure HttpAmount2(): Decimal
    begin
        exit(2345.67);
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

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
    procedure FormatValue(Value: Variant): Text
    begin
        exit(Format(Value, 0, 9));
    end;

    [Scope('OnPrem')]
    procedure ParseVATReturnDetailsJson(var MTDReturnDetails: Record "MTD Return Details"; JsonString: Text)
    var
        JsonMgt: Codeunit "JSON Management";
        RecordRef: RecordRef;
    begin
        Assert.IsTrue(JsonMgt.InitializeFromString(JsonString), 'JsonMgt.InitializeFromString');

        RecordRef.GetTable(MTDReturnDetails);
        with MTDReturnDetails do begin
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
        end;
        RecordRef.SetTable(MTDReturnDetails);
    end;

    [Scope('OnPrem')]
    procedure VerifyLatestHttpLogForSandbox(ExpectedResult: Boolean; ExpectedDescription: Text; ExpectedMessage: Text; HasDetails: Boolean)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ActivityLog: Record "Activity Log";
        ExpectedStatus: Option;
    begin
        OAuth20Setup.Get(OAuthSandboxSetupLbl);
        if ExpectedResult then
            ExpectedStatus := ActivityLog.Status::Success
        else
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

    [Scope('OnPrem')]
    procedure VerifyRequestJson(ExpectedMethod: Text; ExpectedURLRequestPath: Text)
    var
        JSONMgt: Codeunit "JSON Management";
    begin
        JSONMgt.InitializeFromString(GetLatestHttpLogText());
        JSONMgt.InitializeFromString(JSONMgt.GetValue('Request'));
        Assert.ExpectedMessage(ExpectedMethod, JSONMgt.GetValue('Method'));
        Assert.ExpectedMessage(ExpectedURLRequestPath, JSONMgt.GetValue('URLRequestPath'));
        Assert.ExpectedMessage('***', JSONMgt.GetValue('Header.Accept'));
        Assert.ExpectedMessage('***', JSONMgt.GetValue('Header.Content-Type'));
        Assert.ExpectedMessage('***', JSONMgt.GetValue('Header.Authorization'));
    end;
}
