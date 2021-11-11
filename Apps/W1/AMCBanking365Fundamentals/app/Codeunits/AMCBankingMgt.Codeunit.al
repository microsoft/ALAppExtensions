codeunit 20105 "AMC Banking Mgt."
{
    Permissions = TableData "AMC Banking Setup" = r;

    trigger OnRun()
    begin
    end;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        MissingCredentialsQst: Label 'The %1 is missing the user name or password. Do you want to open the %2 page?', comment = '%1=Tablename, %2=Pagename';
        MissingCredentialsErr: Label 'The user name and password must be filled in %1 page.', comment = '%1=Pagename';
        ApiVersionTxt: Label 'api04', Locked = true; //V17.5
        ClientCodeTxt: Label 'amcbanking fundamentals bc', Locked = true;
        DemoSolutionTxt: Label 'demo', Locked = true;
        EnterpriseSolutionTxt: Label 'ENTERPRISE', Locked = true;
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
        LicenserverNameTxt: Label 'https://license.amcbanking.com', Locked = true;
        LicenseRegisterTagTxt: Label '/api/v1/register/customer', Locked = true;

        FileExtTxt: Label '.txt';

    procedure InitDefaultURLs(var AMCBankingSetup: Record "AMC Banking Setup")
    begin

        AMCBankingSetup."Sign-up URL" := GetLicenseServerName() + GetLicenseRegisterTag();
        if ((AMCBankingSetup.Solution = GetDemoSolutionCode()) or
            (AMCBankingSetup.Solution = '')) then
            AMCBankingSetup."Service URL" := GetServiceURL('https://demoxtl.amcbanking.com/', ApiVersion())
        else
            AMCBankingSetup."Service URL" := GetServiceURL('https://nav.amcbanking.com/', ApiVersion());

        //Always set to DemoUrl if it is a sandbox and solution is NOT Enterprise, to avoid payment to be made to real Bankaccounts
        if (IsSolutionSandbox(AMCBankingSetup)) then
            AMCBankingSetup."Service URL" := GetServiceURL('https://demoxtl.amcbanking.com/', ApiVersion());

        AMCBankingSetup."Support URL" := 'https://amcbanking.com/landing365bc/help/';
        AMCBankingSetup."Namespace API Version" := ApiVersion();
    end;

    procedure SetURLsToDefault(var AMCBankingSetup: Record "AMC Banking Setup")
    begin
        InitDefaultURLs(AMCBankingSetup);
        AMCBankingSetup.Modify();
    end;

    procedure GetNamespace(): Text
    begin
        exit('http://' + ApiVersion() + '.soap.xml.link.amc.dk/');
    end;

    procedure GetLicenseServerName(): Text
    begin
        exit(LicenserverNameTxt);
    end;

    procedure GetLicenseRegisterTag(): Text
    begin
        exit(LicenseRegisterTagTxt);
    end;

    procedure IsSolutionSandbox(AMCBankingSetup: Record "AMC Banking Setup"): Boolean
    var
    begin
        if ((UpperCase(AMCBankingSetup.Solution) <> UpperCase(GetEnterPriseSolutionCode())) and
            (EnvironmentInformation.IsSandbox())) then
            exit(true)
        else
            exit(false)
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


        if (SupportXmlDoc.SelectSingleNode(AMCBankServiceRequestMgt.GetConvertlogXPath(), SysLogXmlNode)) then
            SupportURL := AMCBankServiceRequestMgt.getNodeValue(SysLogXmlNode, './url');

        IF SupportURL <> '' THEN
            EXIT(SupportURL);

        AMCBankingSetup.GET();
        EXIT(AMCBankingSetup."Support URL");
    end;

    procedure CheckCredentials()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not AMCBankingSetup.Get() or (not AMCBankingSetup.HasPassword()) or (not AMCBankingSetup.HasUserName())
        then begin
            if CompanyInformationMgt.IsDemoCompany() then begin
                AMCBankingSetup.DeleteAll(true);
                AMCBankingSetup.Init();
                AMCBankingSetup.Insert(true);
            end else
                if Confirm(StrSubstNo(MissingCredentialsQst, AMCBankingSetup.TableCaption(), AMCBankingSetup.TableCaption()), true) then begin
                    Commit();
                    PAGE.RunModal(PAGE::"AMC Banking Setup", AMCBankingSetup);
                end;

            if not AMCBankingSetup.Get() or not AMCBankingSetup.HasPassword() then
                Error(MissingCredentialsErr, AMCBankingSetup.TableCaption());
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
#if not CLEAN20
    [Obsolete('This method will change to local', '20.0')]
    procedure HandleBankDataConvRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
#else
    local procedure HandleBankDataConvRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
#endif
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        RecordRef: RecordRef;
    begin
        if not AMCBankingSetup.Get() then
            AMCBankingSetup.Insert(true);
        RecordRef.GetTable(AMCBankingSetup);

        ServiceConnection.Status := ServiceConnection.Status::Enabled;
        with AMCBankingSetup do begin
            if "Service URL" = '' then
                ServiceConnection.Status := ServiceConnection.Status::Disabled;

            ServiceConnection.InsertServiceConnection(
              ServiceConnection, RecordRef.RecordId(), TableCaption(), "Service URL", PAGE::"AMC Banking Setup");
        end;
    end;

    procedure ApiVersion(): Text[10]
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if AMCBankingSetup.Get() then
            if AMCBankingSetup."Namespace API Version" <> '' then
                exit(AMCBankingSetup."Namespace API Version");

        exit(ApiVersionTxt);
    end;

    internal procedure GetCurrentApiVersion(): Text[10]
    begin
        exit(ApiVersionTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure AMCOnClearCompanyConfiguration(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then
            if (IsSolutionSandbox(AMCBankingSetup)) then
                SetURLsToDefault(AMCBankingSetup);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure AMCHandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then
            if (IsSolutionSandbox(AMCBankingSetup)) then
                SetURLsToDefault(AMCBankingSetup);
    end;


    // To substitute code in Codeunit 2 "Company-Initialize"
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
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

    local procedure InsertPaymentMethod(AMCBankingPmtType: Text[50]; PaymentCode: Code[10])
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
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        with AMCBankingSetup do begin
            if not Get() then begin
                Init();
                Insert(true);
            end;
            if "Sign-up URL" <> GetLicenseServerName() + GetLicenseRegisterTag() then begin
                "Sign-up URL" := GetLicenseServerName() + GetLicenseRegisterTag();
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
        AzureADTenant: Codeunit "Azure AD Tenant";
        LicenseNumber: Text[40];
    begin
        if (EnvironmentInformation.IsSaaS()) then begin
            LicenseNumber := CopyStr(AzureADTenant.GetAadTenantId(), 1, 40);
            if (LicenseNumber = '') then
                LicenseNumber := 'common';
        end
        else begin
            LicenseNumber := CopyStr(DELCHR(SerialNumber(), '<', ' '), 1, 40);
            LicenseNumber := CopyStr(DELCHR(SerialNumber(), '>', ' '), 1, 40);
        end;

        exit(CopyStr('BC' + LicenseNumber, 1, 40))

    end;

    internal procedure IsAMCBusinessInstalled(): Boolean
    var
        AppInfo: ModuleInfo;
    begin
        if (NavApp.GetModuleInfo('b7a9d320-4dac-4e5b-b35f-adcb8626bfe2', AppInfo)) then
            if (AppInfo.Name = 'AMC Banking 365 Business') then
                exit(true);

        exit(false);
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetModulePostFix(var PostFixValue: Text; AMCBankingSetup: Record "AMC Banking Setup")
    begin
    end;


    procedure GetDemoSolutionCode(): Text[50];
    begin
        exit(DemoSolutionTxt);
    end;

    procedure GetEnterPriseSolutionCode(): Text[50];
    begin
        exit(EnterpriseSolutionTxt);
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
        FileManagement: Codeunit "File Management";
    begin
        ActivityLog.CALCFIELDS(ActivityLog."Detailed Info");
        IF NOT ActivityLog."Detailed Info".HASVALUE() THEN BEGIN
            MESSAGE(NoDetailsMsg);
            EXIT;
        END;

        IF DefaultFileName = '' THEN
            DefaultFileName := 'Log.xml';

        TempBlob.FromRecord(ActivityLog, ActivityLog.FieldNo("Detailed Info"));

        EXIT(FileManagement.BLOBExport(TempBlob, DefaultFileName, ShowFileDialog));
    end;

    procedure GetAppCaller(): Text[30]
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(CopyStr(AppInfo.Name(), 1, 30));
    end;

    internal procedure SetFieldValue(var RecordRef: RecordRef; FieldId: Integer; XmlValueVariant: Variant; AppendToValue: Boolean; UseValidate: Boolean)
    var
        TypeHelper: Codeunit "Type Helper";
        TempBlob: Codeunit "Temp Blob";
        FieldRef: FieldRef;
        OutStream: OutStream;
        CurrentLength: Integer;
        ValueVariant: Variant;
        TextValue: Text;
    begin

        FieldRef := RecordRef.Field(FieldId);

        case FieldRef.Type of
            FieldType::Text,
            FieldType::Code:
                begin
                    CurrentLength := StrLen(Format(FieldRef.Value));
                    if (FieldRef.Length = CurrentLength) and (AppendToValue) then
                        exit;
                    if (CurrentLength = 0) or not AppendToValue then
                        updateValue(FieldRef, CopyStr(XmlValueVariant, 1, FieldRef.Length), UseValidate)
                    else
                        updateValue(FieldRef, Format(FieldRef.Value) + ' ' + CopyStr(XmlValueVariant, 1, FieldRef.Length - CurrentLength - 1), UseValidate);

                end;
            FieldType::Date,
            FieldType::Decimal:
                begin
                    TextValue := format(XmlValueVariant, 0, 9);
                    if (TextValue <> '') then begin
                        ValueVariant := FieldRef.Value;
                        if TypeHelper.Evaluate(ValueVariant, TextValue, '', '') then;
                        updateValue(FieldRef, ValueVariant, UseValidate);
                    end;
                end;
            FieldType::Integer:
                updateValue(FieldRef, XmlValueVariant, UseValidate);
            FieldType::Option:
                begin
                    TextValue := CopyStr(XmlValueVariant, 1, FieldRef.Length);
                    updateValue(FieldRef, TypeHelper.GetOptionNoFromTableField(TextValue, RecordRef.Number, FieldId), UseValidate);
                end;
            FieldType::BLOB:
                begin
                    TempBlob.CreateOutStream(OutStream, TEXTENCODING::Windows);
                    OutStream.WriteText(XmlValueVariant);
                    TempBlob.ToRecordRef(RecordRef, FieldRef.Number);
                end;
        end;
    end;

    internal procedure updateValue(var fieldref: FieldRef; ValueVariant: Variant; UseValidate: Boolean)
    var
    begin
        if (UseValidate) then
            fieldref.Validate(ValueVariant)
        else
            fieldref.Value(ValueVariant);

    end;

    internal procedure GetFieldValue(RecordRef: RecordRef; FieldNo: Integer): Text;
    var
        TypeHelper: Codeunit "Type Helper";
        FieldRef: FieldRef;
        DateVariant: Variant;
        DateTimeValue: DateTime;
        TransformedValue: Text;
    begin

        FieldRef := RecordRef.Field(FieldNo);
        case FieldRef.Type of
            FieldType::Text,
                FieldType::Code:
                TransformedValue := FieldRef.Value();
            FieldType::Date:
                begin
                    DateVariant := FieldRef.Value();
                    EVALUATE(DateTimeValue, FORMAT(DateVariant, 0, 9), 9);
                    DateVariant := DateTimeValue;
                    TransformedValue := FORMAT(DateVariant, 0, 9);
                end;
            FieldType::Decimal:
                TransformedValue := FORMAT(FieldRef.Value(), 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces());
            FieldType::Option:
                TransformedValue := FieldRef.Value();
            FieldType::BLOB:
                TransformedValue := FieldRef.Value();
        end;

        exit(TransformedValue)
    end;

    internal procedure GetBankFileName(BankAccount: Record "Bank Account"): Text[250]
    var

    begin

        if (BankAccount."AMC Bank File Name" <> '') then begin
            if (StrPos(BankAccount."AMC Bank File Name", '%1') <> 0) then
                exit(StrSubstNo(BankAccount."AMC Bank File Name", Format(CreateDateTime(Today(), Time()), 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Second,2>')))
            else
                exit(BankAccount."AMC Bank File Name");
        end
        else
            exit(BankAccount."AMC Bank Name" + FileExtTxt);
    end;
}

