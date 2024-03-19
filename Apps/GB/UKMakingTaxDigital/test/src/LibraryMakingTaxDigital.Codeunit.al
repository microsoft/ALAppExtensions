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
        RetrieveLiabilitiesMsg: Label 'Retrieve VAT liabilities successful';
        RetrievePaymentsMsg: Label 'Retrieve VAT payments successful';
        RetrievePeriodsMsg: Label 'Retrieve VAT return periods successful';
        RetrieveReturnsMsg: Label 'Retrieve submitted VAT returns successful';
        ConfirmHeadersMsg: Label 'HMRC requires additional information that will be used to uniquely identify your request. The following fraud prevention headers will be sent:';

    internal procedure EnableFeatureConsent(Enable: Boolean)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup."MTD Enabled" := Enable;
        VATReportSetup.Modify();
    end;

    internal procedure EnableSaaS(Enable: Boolean)
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(Enable);
    end;

    internal procedure SetupDefaultFPHeaders()
    var
        MTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr";
    begin
        MTDDefaultFraudPrevHdr.DeleteAll();
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Device-ID', '', 'beec798b-b366-47fa-b1f8-92cede14a1ce');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Device-ID', '', 'beec798b-b366-47fa-b1f8-92cede14a1ce');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Screens', '', 'width=1920&height=1080&scaling-factor=1&colour-depth=16');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Public-IP', '', '198.51.100.0');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Public-port', '', '12345');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Local-IPs', '', '192.168.1.1');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-MAC-Addresses', '', 'ea%3A43%3A1a%3A5d%3A21%3A45');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Window-Size', '', 'width=640&height=480');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Vendor-Public-IP', '', '203.0.113.6');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Vendor-Forwarded', '', 'by=176.30.57.118&for=203.0.113.6');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Browser-JS-User-Agent', '', 'Mozilla/5.0 (iPad; U; CPU OS 3_2_1 like Mac OS X; en-us)');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Browser-Plugins', '', 'Chromium%20PDF%20Viewer');
        MTDDefaultFraudPrevHdr.SafeInsert('Gov-Client-Browser-Do-Not-Track', '', 'false');

    end;

    internal procedure SetupOAuthAndVATRegNo(EnabledOAuth: Boolean; URL: Text; VATRegNo: Text)
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

    internal procedure CreateOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"; NewStatus: Option; URLPath: Text; AccessTokenDueDateTime: DateTime)
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

    internal procedure MockVATPayment(var MTDPayment: Record "MTD Payment"; StartDate: Date; EndDate: Date; EntryNo: Integer; ReceivedDate: Date; NewAmount: Decimal)
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

    internal procedure MockVATLiability(var MTDLiability: Record "MTD Liability"; StartDate: Date; EndDate: Date; NewType: Option; OriginalAmount: Decimal; OutstandingAmount: Decimal; DueDate: Date)
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

    internal procedure MockVATReturnPeriod(var VATReturnPeriod: Record "VAT Return Period"; StartDate: Date; EndDate: Date; DueDate: Date; PeriodKey: Code[10]; NewStatus: Option; ReceivedDate: Date)
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

    internal procedure MockVATReturnDetail(var MTDReturnDetails: Record "MTD Return Details"; StartDate: Date; EndDate: Date; PeriodKey: Code[10]; VATDueSales: Decimal; VATDueAcquisitions: Decimal; TotalVATDue: Decimal; VATReclaimedCurrPeriod: Decimal; NetVATDue: Decimal; TotalValueSalesExclVAT: Decimal; TotalValuePurchasesExclVAT: Decimal; TotalValueGoodsSupplExVAT: Decimal; TotalAcquisitionsExclVAT: Decimal; NewFinalised: Boolean)
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

    internal procedure MockLinkedVATReturnHeader(var VATReportHeader: Record "VAT Report Header"; var VATReturnPeriod: Record "VAT Return Period")
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

    internal procedure MockLinkedVATReturnHeader(var VATReportHeader: Record "VAT Report Header"; var VATReturnPeriod: Record "VAT Return Period"; NewStatus: Option)
    begin
        MockLinkedVATReturnHeader(VATReportHeader, VATReturnPeriod);
        VATReportHeader.Status := NewStatus;
        VATReportHeader.Modify();
    end;

    internal procedure MockVATStatementReportLine(VATReportHeader: Record "VAT Report Header"; LineNo: Integer; BoxNo: Text[30]; NewAmount: Decimal)
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

    internal procedure MockVATStatementReportLinesWithRandomValues(VATReportHeader: Record "VAT Report Header")
    var
        i: Integer;
    begin
        for i := 1 to 9 do
            MockVATStatementReportLine(VATReportHeader, i, Format(i), LibraryRandom.RandDecInRange(10000, 20000, 2));
    end;

    internal procedure MockAzureClientToken(ClientToken: Text)
    begin
        LibraryAzureKVMockMgmt.InitMockAzureKeyvaultSecretProvider();
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('UKHMRC-MTDVAT-Sandbox-ClientID', ClientToken);
        LibraryAzureKVMockMgmt.EnsureSecretNameIsAllowed('UKHMRC-MTDVAT-Sandbox-ClientID');
        LibraryAzureKVMockMgmt.UseAzureKeyvaultSecretProvider();
    end;

    internal procedure UpdateCompanyInformation(VATRegNo: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get();
            "VAT Registration No." := CopyStr(VATRegNo, 1, MaxStrLen("VAT Registration No."));
            Modify(true);
        end;
    end;

    internal procedure GetOAuthSandboxSetupCode(): Code[20]
    begin
        exit(CopyStr(OAuthSandboxSetupLbl, 1, 20));
    end;

    internal procedure GetOAuthProdSetupCode(): Code[20]
    begin
        exit(CopyStr(OAuthPRODSetupLbl, 1, 20));
    end;

    internal procedure GetResonLbl(): Text
    begin
        exit(ReasonLbl);
    end;

    internal procedure GetIncludingLbl(): Text
    begin
        exit(IncludingLbl);
    end;

    internal procedure GetInvokeRequestLbl(Method: Text): Text
    begin
        exit(StrSubstNo(InvokeRequestLbl, Method));
    end;

    internal procedure GetVATStatementReportLineAmount(VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30]): Decimal
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        FindVATStatementReportLine(VATStatementReportLine, VATReportHeader, BoxNo);
        exit(VATStatementReportLine.Amount);
    end;

    internal procedure FindVATStatementReportLine(var VATStatementReportLine: Record "VAT Statement Report Line"; VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30])
    begin
        with VATStatementReportLine do begin
            SetRange("VAT Report No.", VATReportHeader."No.");
            SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
            SetRange("Box No.", BoxNo);
            FindFirst();
        end;
    end;

    internal procedure GetVATReportSubmissionText(VATReportHeader: Record "VAT Report Header"): Text
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

    internal procedure GetVATReportResponseText(VATReportHeader: Record "VAT Report Header"): Text
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

    internal procedure GetLatestHttpLogText(): Text
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

    internal procedure HttpStartDate(): Date
    begin
        exit(20200101D);
    end;

    internal procedure HttpEndDate(): Date
    begin
        exit(20200331D);
    end;

    internal procedure HttpDueDate(): Date
    begin
        exit(20200507D);
    end;

    internal procedure HttpReceivedDate(): Date
    begin
        exit(20200504D);
    end;

    internal procedure HttpPeriodKey(): Code[10]
    begin
        exit('20A1');
    end;

    internal procedure HttpAmount1(): Decimal
    begin
        exit(1234.56);
    end;

    internal procedure HttpAmount2(): Decimal
    begin
        exit(2345.67);
    end;

    local procedure SetOAuthSetupTestTokens(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        ClientIdText: Text;
        ClientSecretText: Text;
        AccessTokenText: Text;
        RefreshTokenText: Text;
    begin
        ClientIdText := 'Dummy Test Client ID';
        ClientSecretText := 'Dummy Test Client Secret';
        AccessTokenText := 'Dummy Test Access Token';
        RefreshTokenText := 'Dummy Test Refresh Token';

        OAuth20Setup.SetToken(OAuth20Setup."Client ID", ClientIdText);
        OAuth20Setup.SetToken(OAuth20Setup."Client Secret", ClientSecretText);
        OAuth20Setup.SetToken(OAuth20Setup."Access Token", AccessTokenText);
        OAuth20Setup.SetToken(OAuth20Setup."Refresh Token", RefreshTokenText);
    end;

    internal procedure SetOAuthSetupSandbox(IsSandbox: Boolean)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        with VATReportSetup do begin
            Get();
            if IsSandbox then
                Validate("MTD OAuth Setup Option", "MTD OAuth Setup Option"::Sandbox)
            else
                Validate("MTD OAuth Setup Option", "MTD OAuth Setup Option"::Production);
            "MTD FP Public IP Service URL" := 'dummy';
            Modify(true);
        end;
    end;

    internal procedure FormatValue(VariantValue: Variant): Text
    begin
        exit(Format(VariantValue, 0, 9));
    end;

    internal procedure ParseVATReturnDetailsJson(var MTDReturnDetails: Record "MTD Return Details"; JsonString: Text)
    var
        RecordRef: RecordRef;
        JToken: JsonToken;
    begin
        Assert.IsTrue(JToken.ReadFrom(JsonString), 'JToken.ReadFrom()');

        RecordRef.GetTable(MTDReturnDetails);
        with MTDReturnDetails do begin
            ReadJsonValueToRecRef(RecordRef, JToken, 'periodKey', FieldNo("Period Key"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'vatDueSales', FieldNo("VAT Due Sales"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'vatDueAcquisitions', FieldNo("VAT Due Acquisitions"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'totalVatDue', FieldNo("Total VAT Due"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'vatReclaimedCurrPeriod', FieldNo("VAT Reclaimed Curr Period"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'netVatDue', FieldNo("Net VAT Due"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'totalValueSalesExVAT', FieldNo("Total Value Sales Excl. VAT"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'totalValuePurchasesExVAT', FieldNo("Total Value Purchases Excl.VAT"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'totalValueGoodsSuppliedExVAT', FieldNo("Total Value Goods Suppl. ExVAT"));
            ReadJsonValueToRecRef(RecordRef, JToken, 'totalAcquisitionsExVAT', FieldNo("Total Acquisitions Excl. VAT"));
        end;
        RecordRef.SetTable(MTDReturnDetails);
    end;

    internal procedure VerifyLatestHttpLogForSandbox(ExpectedResult: Boolean; ExpectedDescription: Text; ExpectedMessage: Text; HasDetails: Boolean)
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

    internal procedure VerifyRequestJson(ExpectedMethod: Text; ExpectedURLRequestPath: Text; ContentType: Boolean)
    var
        JToken: JsonToken;
    begin
        JToken.ReadFrom(GetLatestHttpLogText());
        JToken.SelectToken('Request', JToken);
        Assert.ExpectedMessage(ExpectedMethod, ReadJsonValue(JToken, 'Method'));
        Assert.ExpectedMessage(ExpectedURLRequestPath, ReadJsonValue(JToken, 'URLRequestPath'));
        Assert.ExpectedMessage('application/vnd.hmrc.1.0+json', ReadJsonValue(JToken, 'Accept'));
        if ContentType then
            Assert.ExpectedMessage('application/json', ReadJsonValue(JToken, 'Content-Type'))
        else
            AssertBlankedJsonValue(JToken, 'Content-Type');
        Assert.ExpectedMessage('***', ReadJsonValue(JToken, 'Header.Authorization'));
    end;

    internal procedure ReadJsonValue(JToken: JsonToken; Path: Text) Result: Text
    begin
        if JToken.SelectToken(Path, JToken) then
            if JToken.IsValue() then
                exit(JToken.AsValue().AsText())
            else
                JToken.WriteTo(Result);
    end;

    internal procedure AssertBlankedJsonValue(JToken: JsonToken; Path: Text)
    var
        ErrText: Text;
    begin
        if JToken.SelectToken(Path, JToken) then begin
            ErrText := StrSubstNo('Json value for the path ''%1'' should be blanked.', Path);
            Error(ErrText);
        end;
    end;

    local procedure ReadJsonValueToRecRef(RecordRef: RecordRef; JToken: JsonToken; KeyValue: Text; FieldNo: Integer) Result: Boolean
    var
        FieldRef: FieldRef;
        GuidValue: Guid;
    begin
        Result := JToken.SelectToken(KeyValue, JToken);
        if Result then begin
            FieldRef := RecordRef.Field(FieldNo);
            case FieldRef.Type() of
                FieldType::Integer:
                    FieldRef.Value(JToken.AsValue().AsInteger());
                FieldType::Decimal:
                    FieldRef.Value(JToken.AsValue().AsDecimal());
                FieldType::Date:
                    FieldRef.Value(JToken.AsValue().AsDate());
                FieldType::Time:
                    FieldRef.Value(JToken.AsValue().AsTime());
                FieldType::DateTime:
                    FieldRef.Value(JToken.AsValue().AsDateTime());
                FieldType::Boolean:
                    FieldRef.Value(JToken.AsValue().AsBoolean());
                FieldType::GUID:
                    begin
                        Result := Evaluate(GuidValue, JToken.AsValue().AsText());
                        FieldRef.Value(GuidValue);
                    end;
                FieldType::Text:
                    FieldRef.Value(CopyStr(JToken.AsValue().AsText(), 1, FieldRef.Length()));
                FieldType::Code:
                    FieldRef.Value(CopyStr(JToken.AsValue().AsCode(), 1, FieldRef.Length()));
            end;
        end;
    end;

    internal procedure GetRetrieveLiabilitiesMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrieveLiabilitiesMsg, StrSubstNo(IncludingLbl, NewCount, ModifiedCount)));
    end;

    internal procedure GetRetrievePaymentsMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrievePaymentsMsg, StrSubstNo(IncludingLbl, NewCount, ModifiedCount)));
    end;

    internal procedure GetRetrievePeriodsMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrievePeriodsMsg, StrSubstNo(IncludingLbl, NewCount, ModifiedCount)));
    end;

    internal procedure GetRetrieveReturnMsg(NewCount: Integer; ModifiedCount: Integer): Text
    begin
        exit(StrSubstNo('%1,\%2', RetrieveReturnsMsg, StrSubstNo(IncludingLbl, NewCount, ModifiedCount)));
    end;

    internal procedure VerifyFraudPreventionConfirmMsg(var LibraryVariableStorage: Codeunit "Library - Variable Storage");
    begin
        Assert.ExpectedMessage(ConfirmHeadersMsg, LibraryVariableStorage.DequeueText());
    end;
}
