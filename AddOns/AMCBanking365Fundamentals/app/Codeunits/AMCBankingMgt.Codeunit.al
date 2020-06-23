codeunit 20105 "AMC Banking Mgt."
{
    Permissions = TableData "AMC Banking Setup" = r;

    trigger OnRun()
    begin
    end;

    var
        MissingCredentialsQst: Label 'The %1 is missing the user name or password. Do you want to open the %2 page?', comment = '%1=Tablename, %2=Pagename';
        MissingCredentialsErr: Label 'The user name and password must be filled in %1 page.', comment = '%1=Pagename';
        ApiVersionTxt: Label 'nav03', Locked = true;
        ClientCodeTxt: Label 'amcbanking fundamentals bc', Locked = true;
        DemoSolutionTxt: Label 'demo', Locked = true;
        LicenseXmlApiTxt: Label 'amcxml', Locked = true;
        ModuleInfoWebCallTxt: Label 'amcwebservice', Locked = true;
        DataExchNameCtTxt: Label 'BANKDATACONVSERVCT', Locked = true;
        DataExchNameStmtTxt: Label 'BANKDATACONVSERVSTMT', Locked = true;
        DataExchNamePPTxt: Label 'BANKDATACONVSERVPP', Locked = true;
        DataExchNameCremTxt: Label 'BANKDATACONVSERVCREM', Locked = true;
        CreditTransMsgNoTxt: Label 'CT-MSG', locked = true;
        CreditTransMsgNameTxt: Label 'Credit Transfer Msg. ID';
        AMCBankingPmtTypeCode1Tok: Label 'IntAcc2Acc', Locked = true;
        AMCBankingPmtTypeDesc1Txt: Label 'International account to account transfer (standard)';
        AMCBankingPmtTypeCode2Tok: Label 'IntAcc2AccExp', Locked = true;
        AMCBankingPmtTypeDesc2Txt: Label 'International account to account transfer (express)';
        AMCBankingPmtTypeCode3Tok: Label 'IntAcc2AccFoFa', Locked = true;
        AMCBankingPmtTypeDesc3Txt: Label 'International account to account transfer';
        AMCBankingPmtTypeCode4Tok: Label 'IntAcc2AccHighVal', Locked = true;
        AMCBankingPmtTypeDesc4Txt: Label 'International account to account transfer (high value)';
        AMCBankingPmtTypeCode5Tok: Label 'IntAcc2AccInterComp', Locked = true;
        AMCBankingPmtTypeDesc5Txt: Label 'International account to account transfer (inter company)';
        AMCBankingPmtTypeCode6Tok: Label 'DomAcc2Acc', Locked = true;
        AMCBankingPmtTypeDesc6Txt: Label 'Domestic account to account transfer';
        AMCBankingPmtTypeCode7Tok: Label 'DomAcc2AccHighVal', Locked = true;
        AMCBankingPmtTypeDesc7Txt: Label 'Domestic account to account transfer (high value)';
        AMCBankingPmtTypeCode8Tok: Label 'DomAcc2AccInterComp', Locked = true;
        AMCBankingPmtTypeDesc8Txt: Label 'Domestic account to account transfer (inter company)';
        AMCBankingPmtTypeCode9Tok: Label 'EurAcc2AccSepa', Locked = true;
        AMCBankingPmtTypeDesc9Txt: Label 'SEPA credit transfer';
        NoDetailsMsg: Label 'The log does not contain any more details.';
        ResultPathTxt: Label '/amc:%1/return/syslog[syslogtype[text()="error"]]', Locked = true;
        FinstaPathTxt: Label '/amc:%1/return/finsta/statement/finstatransus', Locked = true;
        HeaderErrPathTxt: Label '/amc:%1/return/header/result[text()="error"]', Locked = true;
        ConvErrPathTxt: Label '/amc:%1/return/pack/convertlog[syslogtype[text()="error"]]', Locked = true;
        DataPathTxt: Label '/amc:%1/return/pack/data/text()', Locked = true;

    procedure InitDefaultURLs(var AMCBankServiceSetup: Record "AMC Banking Setup")
    begin

        AMCBankServiceSetup."Sign-up URL" := 'https://license.amcbanking.com/register';
        if ((AMCBankServiceSetup.Solution = GetDemoSolutionCode()) or
            (AMCBankServiceSetup.Solution = '')) then
            AMCBankServiceSetup."Service URL" := GetServiceURL('https://demoxtl.amcbanking.com/', ApiVersion())
        else
            AMCBankServiceSetup."Service URL" := GetServiceURL('https://nav.amcbanking.com/', ApiVersion());

        AMCBankServiceSetup."Support URL" := 'https://amcbanking.com/landing365bc/help/';
        AMCBankServiceSetup."Namespace API Version" := ApiVersion();
    end;

    procedure SetURLsToDefault(var AMCBankServiceSetup: Record "AMC Banking Setup")
    begin
        InitDefaultURLs(AMCBankServiceSetup);
        AMCBankServiceSetup.Modify();
    end;

    procedure GetNamespace(): Text
    begin
        exit('http://' + ApiVersion() + '.soap.xml.link.amc.dk/');
    end;

    [Scope('OnPrem')]
    [Obsolete('This method is obsolete. A new GetSupportURL overload is available, which is called with an XmlDocument instead of a XmlNode object', '16.2')]
    procedure GetSupportURL(XmlNode: XmlNode): Text
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        SupportXmlDoc: XmlDocument;
    begin
        if (XmlNode.GetDocument(SupportXmlDoc)) then
            exit(GetSupportURL(SupportXmlDoc))
        else begin
            AMCBankingSetup.GET();
            EXIT(AMCBankingSetup."Support URL");
        end;
    end;

    procedure GetSupportURL(SupportXmlDoc: XmlDocument): Text;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        SysLogXmlNode: XmlNode;
        SupportURL: Text;
    begin
        if (SupportXmlDoc.SelectSingleNode(AMCBankServiceRequestMgt.GetSyslogXPath(), SysLogXmlNode)) then
            SupportURL := AMCBankServiceRequestMgt.getNodeValue(SysLogXmlNode, './url');

        IF SupportURL <> '' THEN
            EXIT(SupportURL);

        AMCBankingSetup.GET();
        EXIT(AMCBankingSetup."Support URL");
    end;

    procedure CheckCredentials()
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not AMCBankServiceSetup.Get() or (not AMCBankServiceSetup.HasPassword()) or (not AMCBankServiceSetup.HasUserName())
        then begin
            if CompanyInformationMgt.IsDemoCompany() then begin
                AMCBankServiceSetup.DeleteAll(true);
                AMCBankServiceSetup.Init();
                AMCBankServiceSetup.Insert(true);
            end else
                if Confirm(StrSubstNo(MissingCredentialsQst, AMCBankServiceSetup.TableCaption(), AMCBankServiceSetup.TableCaption()), true) then begin
                    Commit();
                    PAGE.RunModal(PAGE::"AMC Banking Setup", AMCBankServiceSetup);
                end;

            if not AMCBankServiceSetup.Get() or not AMCBankServiceSetup.HasPassword() then
                Error(MissingCredentialsErr, AMCBankServiceSetup.TableCaption());
        end;
    end;

    [Obsolete('This method is obsolete and it will be removed.', '16.2')]
    procedure GetErrorXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(ResultPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. A new version is avalable in AMCBankingServiceRequest.', '16.2')]
    procedure GetFinstaXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(FinstaPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed.', '16.2')]
    procedure GetHeaderErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(HeaderErrPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. A new version is avalable in AMCBankingServiceRequest.', '16.2')]
    procedure GetConvErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(ConvErrPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. A new version is avalable in AMCBankingServiceRequest.', '16.2')]
    procedure GetDataXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(DataPathTxt, ResponseNode));
    end;

    [EventSubscriber(ObjectType::Table, 1400, 'OnRegisterServiceConnection', '', false, false)]
    procedure HandleBankDataConvRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        RecRef: RecordRef;
    begin
        if not AMCBankServiceSetup.Get() then
            AMCBankServiceSetup.Insert(true);
        RecRef.GetTable(AMCBankServiceSetup);

        ServiceConnection.Status := ServiceConnection.Status::Enabled;
        with AMCBankServiceSetup do begin
            if "Service URL" = '' then
                ServiceConnection.Status := ServiceConnection.Status::Disabled;

            ServiceConnection.InsertServiceConnection(
              ServiceConnection, RecRef.RecordId(), TableCaption(), "Service URL", PAGE::"AMC Banking Setup");
        end;
    end;

    procedure ApiVersion(): Text[10]
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
    begin
        if AMCBankServiceSetup.Get() then
            if AMCBankServiceSetup."Namespace API Version" <> '' then
                exit(AMCBankServiceSetup."Namespace API Version");

        exit(ApiVersionTxt);
    end;

    // To substitute code in Codeunit 2 "Company-Initialize"
    [EventSubscriber(ObjectType::Codeunit, 2, 'OnCompanyInitialize', '', false, false)]
    local procedure AMCBankOnCompanyInitialize();
    var
    begin
        AMCBankInitializeBaseData();
        InitBankDataConvServiceSetup();
    end;

    procedure AMCBankInitializeBaseData();
    begin
        InitAMCBankingPmtTypes();
        InitPaymentMethods();
        InitBankClearingStandard();
        DefaultCreditTransferMsgNo();
    end;

    local procedure InitAMCBankingPmtTypes()
    var
        AMCBankPmtType: Record "AMC Bank Pmt. Type";
    begin
        if AMCBankPmtType.IsEmpty() then begin
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode1Tok, AMCBankingPmtTypeDesc1Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode2Tok, AMCBankingPmtTypeDesc2Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode3Tok, AMCBankingPmtTypeDesc3Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode4Tok, AMCBankingPmtTypeDesc4Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode5Tok, AMCBankingPmtTypeDesc5Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode6Tok, AMCBankingPmtTypeDesc6Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode7Tok, AMCBankingPmtTypeDesc7Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode8Tok, AMCBankingPmtTypeDesc8Txt);
            InsertAMCBankingPmtType(AMCBankingPmtTypeCode9Tok, AMCBankingPmtTypeDesc9Txt);
        end;
    end;

    local procedure InitPaymentMethods()
    var
        BNKDOMACC_Txt: Label 'BNKCONVDOM', Locked = true;
        BNKINTACC_Txt: Label 'BNKCONVINT', Locked = true;
    begin
        InsertPaymentMethod(AMCBankingPmtTypeCode1Tok, BNKINTACC_Txt);
        InsertPaymentMethod(AMCBankingPmtTypeCode6Tok, BNKDOMACC_Txt);
    end;

    local procedure InsertPaymentMethod(AMCBankingPmtType: Text[50]; PaymentCode: Code[10]) Exists: Boolean;
    var
        AMCBankPmtType: Record "AMC Bank Pmt. Type";
        PaymentMethod: Record "Payment Method";
        DataExchDef: Record "Data Exch. Def";

    begin
        if (DataExchDef.Get(GetDataExchDef_CT())) then
            if (AMCBankPmtType.GET(AMCBankingPmtType)) then begin
                CLEAR(PaymentMethod);
                PaymentMethod.INIT();
                PaymentMethod.Code := PaymentCode;
                PaymentMethod.Description := AMCBankPmtType.Description;
                PaymentMethod."Pmt. Export Line Definition" := DataExchDef.Code;
                PaymentMethod."AMC Bank Pmt. Type" := AMCBankPmtType.Code;
                if not PaymentMethod.Insert() then
                    PaymentMethod.Modify()
            end;
    end;

    local procedure InitBankClearingStandard()
    var
        BankClearingStandardCode1Tok: Label 'AustrianBankleitzahl', Locked = true;
        BankClearingStandardDesc1Txt: Label 'Austrian BLZ number';
        BankClearingStandardCode2Tok: Label 'CanadianPaymentsARN', Locked = true;
        BankClearingStandardDesc2Txt: Label 'Canadian ARN number';
        BankClearingStandardCode3Tok: Label 'CHIPSParticipant', Locked = true;
        BankClearingStandardDesc3Txt: Label 'American CHIPS number';
        BankClearingStandardCode4Tok: Label 'CHIPSUniversal', Locked = true;
        BankClearingStandardDesc4Txt: Label 'American CHIPS universal number';
        BankClearingStandardCode5Tok: Label 'ExtensiveBranchNetwork', Locked = true;
        BankClearingStandardDesc5Txt: Label 'Extensive branch network number';
        BankClearingStandardCode6Tok: Label 'FedwireRoutingNumber', Locked = true;
        BankClearingStandardDesc6Txt: Label 'American Fedwire/ABA routing number';
        BankClearingStandardCode7Tok: Label 'GermanBankleitzahl', Locked = true;
        BankClearingStandardDesc7Txt: Label 'German BLZ number';
        BankClearingStandardCode8Tok: Label 'HongKongBank', Locked = true;
        BankClearingStandardDesc8Txt: Label 'Hong Kong branch number';
        BankClearingStandardCode9Tok: Label 'IrishNSC', Locked = true;
        BankClearingStandardDesc9Txt: Label 'Irish NSC number';
        BankClearingStandardCode10Tok: Label 'ItalianDomestic', Locked = true;
        BankClearingStandardDesc10Txt: Label 'Italian domestic code';
        BankClearingStandardCode11Tok: Label 'NewZealandNCC', Locked = true;
        BankClearingStandardDesc11Txt: Label 'New Zealand NCC number';
        BankClearingStandardCode12Tok: Label 'PortugueseNCC', Locked = true;
        BankClearingStandardDesc12Txt: Label 'Portuguese NCC number';
        BankClearingStandardCode13Tok: Label 'RussianCentralBankIdentificationCode', Locked = true;
        BankClearingStandardDesc13Txt: Label 'Russian CBI code';
        BankClearingStandardCode14Tok: Label 'SouthAfricanNCC', Locked = true;
        BankClearingStandardDesc14Txt: Label 'South African NCC number';
        BankClearingStandardCode15Tok: Label 'SpanishDomesticInterbanking', Locked = true;
        BankClearingStandardDesc15Txt: Label 'Spanish domestic interbanking number';
        BankClearingStandardCode16Tok: Label 'SwissBC', Locked = true;
        BankClearingStandardDesc16Txt: Label 'Swiss BC number';
        BankClearingStandardCode17Tok: Label 'SwissSIC', Locked = true;
        BankClearingStandardDesc17Txt: Label 'Swiss SIC number';
        BankClearingStandardCode18Tok: Label 'UKDomesticSortCode', Locked = true;
        BankClearingStandardDesc18Txt: Label 'British sorting code';
    begin
        InsertBankClearingStandard(BankClearingStandardCode1Tok, BankClearingStandardDesc1Txt);
        InsertBankClearingStandard(BankClearingStandardCode2Tok, BankClearingStandardDesc2Txt);
        InsertBankClearingStandard(BankClearingStandardCode3Tok, BankClearingStandardDesc3Txt);
        InsertBankClearingStandard(BankClearingStandardCode4Tok, BankClearingStandardDesc4Txt);
        InsertBankClearingStandard(BankClearingStandardCode5Tok, BankClearingStandardDesc5Txt);
        InsertBankClearingStandard(BankClearingStandardCode6Tok, BankClearingStandardDesc6Txt);
        InsertBankClearingStandard(BankClearingStandardCode7Tok, BankClearingStandardDesc7Txt);
        InsertBankClearingStandard(BankClearingStandardCode8Tok, BankClearingStandardDesc8Txt);
        InsertBankClearingStandard(BankClearingStandardCode9Tok, BankClearingStandardDesc9Txt);
        InsertBankClearingStandard(BankClearingStandardCode10Tok, BankClearingStandardDesc10Txt);
        InsertBankClearingStandard(BankClearingStandardCode11Tok, BankClearingStandardDesc11Txt);
        InsertBankClearingStandard(BankClearingStandardCode12Tok, BankClearingStandardDesc12Txt);
        InsertBankClearingStandard(BankClearingStandardCode13Tok, BankClearingStandardDesc13Txt);
        InsertBankClearingStandard(BankClearingStandardCode14Tok, BankClearingStandardDesc14Txt);
        InsertBankClearingStandard(BankClearingStandardCode15Tok, BankClearingStandardDesc15Txt);
        InsertBankClearingStandard(BankClearingStandardCode16Tok, BankClearingStandardDesc16Txt);
        InsertBankClearingStandard(BankClearingStandardCode17Tok, BankClearingStandardDesc17Txt);
        InsertBankClearingStandard(BankClearingStandardCode18Tok, BankClearingStandardDesc18Txt);
    end;

    local procedure InsertBankClearingStandard(CodeText: Text[50]; DescriptionText: Text[80])
    var
        BankClearingStandard: Record "Bank Clearing Standard";
    begin
        if (NOT BankClearingStandard.Get(CodeText)) then
            with BankClearingStandard do begin
                Init();
                Code := CodeText;
                Description := DescriptionText;
                Insert();
            end;
    end;

    local procedure InsertAMCBankingPmtType(CodeText: Text[50]; DescriptionText: Text[80])
    var
        AMCBankPmtType: Record "AMC Bank Pmt. Type";
    begin
        with AMCBankPmtType do begin
            Init();
            Code := CodeText;
            Description := DescriptionText;
            Insert();
        end;
    end;

    local procedure InitBankDataConvServiceSetup()
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
    begin
        with AMCBankServiceSetup do begin
            if not Get() then begin
                Init();
                Insert(true);
            end;
            if "Sign-up URL" <> 'https://license.amcbanking.com/register' then begin
                "Sign-up URL" := 'https://license.amcbanking.com/register';
                Modify();
            end;
        end;
    end;

    procedure GetDefaultCreditTransferMsgNo(): Text[20];
    begin
        exit(DefaultCreditTransferMsgNo());
    end;

    local procedure DefaultCreditTransferMsgNo(): Code[20];
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if (NoSeries.GET(CreditTransMsgNoTxt)) then
            exit(NoSeries.Code)
        else begin //Create No. Series for credittranfers
            NoSeries.INIT();
            NoSeries.Code := CreditTransMsgNoTxt;
            NoSeries.Description := CreditTransMsgNameTxt;
            NoSeries."Default Nos." := TRUE;
            NoSeries.INSERT();

            NoSeriesLine.INIT();
            NoSeriesLine."Series Code" := CreditTransMsgNoTxt;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := '1001';
            NoSeriesLine."Ending No." := '9999';
            NoSeriesLine."Warning No." := '9995';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Open := TRUE;
            NoSeriesLine.INSERT();

            exit(NoSeries.Code);
        end;
    end;

    procedure GetAMCClientCode(): Text;
    begin
        exit(ClientCodeTxt);
    end;

    procedure GetLicenseNumber(): Text[40];
    var
        EnvironmentInfo: Codeunit "Environment Information";
        TenantSettings: Codeunit "Azure AD Tenant";
        LicenseNumber: Text[40];
    begin
        if (EnvironmentInfo.IsSaaS()) then
            LicenseNumber := CopyStr(TenantSettings.GetAadTenantId(), 1, 40)
        else begin
            LicenseNumber := CopyStr(DELCHR(SerialNumber(), '<', ' '), 1, 40);
            LicenseNumber := CopyStr(DELCHR(SerialNumber(), '>', ' '), 1, 40);
        end;

        exit(CopyStr('BC' + LicenseNumber, 1, 40));
    end;

    procedure GetDemoSolutionCode(): Text[50];
    begin
        exit(DemoSolutionTxt);
    end;

    procedure GetLicenseXmlApi(): Text;
    begin
        exit(LicenseXmlApiTxt);
    end;

    procedure GetModuleInfoWebCall(): Text;
    begin
        exit(ModuleInfoWebCallTxt);
    end;

    procedure GetServiceURL(AMCServiceUrl: Text; AMCAPIVersion: Text) URL: Text[250];
    begin
        IF (COPYSTR(AMCServiceUrl, STRLEN(AMCServiceUrl), 1) = '/') THEN
            EXIT(CopyStr(LowerCase(AMCServiceUrl + AMCAPIVersion), 1, 250))
        ELSE
            EXIT(CopyStr(LowerCase(AMCServiceUrl + '/' + AMCAPIVersion), 1, 250));
    end;

    procedure GetDataExchDef_CT(): Code[20];
    begin
        EXIT(DataExchNameCtTxt);
    end;

    procedure GetDataExchDef_STMT(): Code[20];
    begin
        EXIT(DataExchNameStmtTxt);
    end;

    procedure GetDataExchDef_PP(): Code[20];
    begin
        EXIT(DataExchNamePPTxt);
    end;

    procedure GetDataExchDef_CREM(): Code[20];
    begin
        EXIT(DataExchNameCremTxt);
    end;

    procedure ShowDetailedLogInfo(ActivityLog: Record "Activity Log"; DefaultFileName: Text; ShowFileDialog: Boolean): Text;
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        ActivityLog.CALCFIELDS(ActivityLog."Detailed Info");
        IF NOT ActivityLog."Detailed Info".HASVALUE() THEN BEGIN
            MESSAGE(NoDetailsMsg);
            EXIT;
        END;

        IF DefaultFileName = '' THEN
            DefaultFileName := 'Log.xml';

        TempBlob.FromRecord(ActivityLog, ActivityLog.FieldNo("Detailed Info"));

        EXIT(FileMgt.BLOBExport(TempBlob, DefaultFileName, ShowFileDialog));
    end;

    procedure GetAppCaller(): Text[30]
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(CopyStr(AppInfo.Name(), 1, 30));
    end;

}

