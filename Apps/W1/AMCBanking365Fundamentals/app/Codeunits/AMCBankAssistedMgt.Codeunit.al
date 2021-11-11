codeunit 20117 "AMC Bank Assisted Mgt."
{
    trigger OnRun()
    begin

    end;

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankServiceRequestMgt: Codeunit "AMC Bank Service Request Mgt.";
        NotCorrectUserLbl: Label 'The Web Service Setup User Name (%1) does not match the License number (%2) or the (%3)', Comment = '%1=UserName, %2=License numnber, %3=DemoUser';
        YouHave2OptionsLbl: Label 'You have two option to change this:';
        UseBCLicenseLbl: Label '1. Please register the User Name (%1) using the Sign-up URL %2', Comment = '%1=User Name, %2=Sign-up URL';
        UseDemoUserLbl: Label '2. Delete the Web Service setup record using the Trash can symbol and reopen the page to use (%1)', Comment = '%1=DemoUser';
        TryLoadErrorLbl: Label 'The web service returned an error message:\';
        EnableSetupNeededNotificationTxt: Label 'To setup AMC Banking, you need to enable it.';
        AssistedSetupNeededNotificationTxt: Label 'The AMC Banking 365 Fundamentals extension needs some information.';
        AssistedSetupNotificationActionTxt: Label 'Do you want to open the AMC Banking Setup page to run the Assisted Setup action?';
        PleaseRunAssistedSetupNotificationActionTxt: Label 'Please run the Assisted setup action to complete the AMC Banking setup.';

        DemoSolutionNotificationTxt: Label 'The AMC Banking 365 Fundamentals extension is in Demo mode.';
        DemoSolutionNotificationActionTxt: Label 'Do you want to open the AMC Banking 365 Fundamentals extension setup page?';
        DemoSolutionNotificationNameTok: Label 'Notify user of AMC Banking Demo solution.';
        DemoSolutionNotificationDescTok: Label 'Show a notification informing the user that AMC Banking is working in Demo solution.';
        DontShowThisAgainMsg: Label 'Don''t show this again.';

        AssistedSetupTxt: Label 'Set up AMC Banking 365 Fundamentals extension';

        AssistedSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2115384', Locked = true;
        AssistedSetupDescriptionTxt: Label 'Connect to an online bank service that can convert bank data from Business Central into the formats of your bank, to make it easier, and more accurate, to send data to your banks.';
        ReturnPathTxt: Label '//return/pack', Locked = true;
        ModuleWebCallTxt: Label 'amcwebservice', locked = true;
        DataExchangeWebCallTxt: Label 'dataExchange', Locked = true;

    procedure GetApplVersion() ApplVersion: Text;
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        ApplVersion := COPYSTR(ApplicationSystemConstants.ApplicationVersion(), STRPOS(ApplicationSystemConstants.ApplicationVersion(), ' ') + 1, STRLEN(ApplicationSystemConstants.ApplicationVersion()));
        ApplVersion := DELCHR(ApplVersion, '=', DELCHR(ApplVersion, '=', '.1234567890'));
        ApplVersion += '_F'; //To know the difference between Fundamentals and other versions

        OnGetApplVersion(ApplVersion); //Other Apps can call this Event to set their own ApplVersion
        exit(ApplVersion);
    end;

    procedure GetBuildNumber() BuildNumber: Text;
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        BuildNumber := ApplicationSystemConstants.ApplicationBuild();
        OnGetBuildNumber(BuildNumber); //Other Apps can call this Event to set their own BuildNumber

        exit(BuildNumber);
    end;

    procedure RunBasisSetupV162(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                            UpdBank: Boolean; UpdPayMeth: Boolean; BankCountryCode: Code[10]; PaymCountryCode: Code[10];
                            UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean; UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                            UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; var TempOnlineBankAccLink: Record "Online Bank Acc. Link"; CallLicenseServer: Boolean): Boolean;
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
        LongTimeout: Integer;
        ShortTimeout: Integer;
        AMCSolution: text;
        AMCSpecificURL: Text;
        AMCSignUpURL: Text;
        AMCSupportURL: Text;
        BasisSetupRanOK: Boolean;
        Error_Text: text;
    begin
        ShortTimeout := 5000;
        LongTimeout := 30000;
        BasisSetupRanOK := true;

        if (NOT AMCBankingSetup.Get()) then begin
            AMCBankingSetup.Init();
            AMCBankingSetup.Insert(true);
            Commit(); //Need to commit, to make sure record exist, if RunBasisSetup at one point is called from Installation/Upgrade CU
        end;

        if ((AMCBankingSetup."User Name" <> AMCBankingSetup.GetDemoUserName()) and
           (AMCBankingSetup."User Name" <> AMCBankingMgt.GetLicenseNumber())) then begin
            Error_Text := StrSubstNo(NotCorrectUserLbl, AMCBankingSetup."User Name", AMCBankingMgt.GetLicenseNumber(), AMCBankingSetup.GetDemoUserName()) + '\\' +
                          YouHave2OptionsLbl + '\\' +
                          StrSubstNo(UseBCLicenseLbl, AMCBankingMgt.GetLicenseNumber(), AMCBankingSetup."Sign-up URL") + '\\' +
                          StrSubstNo(UseDemoUserLbl, AMCBankingSetup.GetDemoUserName());
            error(Error_Text);
        end;

        //if demouser - always return demosolution
        if (AMCBankingSetup.GetUserName() = AMCBankingSetup.GetDemoUserName()) then begin
            AMCSolution := AMCBankingMgt.GetDemoSolutionCode();
            AMCBankingSetup.Solution := CopyStr(AMCSolution, 1, 50);
            AMCBankingMgt.SetURLsToDefault(AMCBankingSetup);
        end
        else
            if (CallLicenseServer) then
                GetModuleInfoFromWebservice(AMCSpecificURL, AMCSignUpURL, AMCSupportURL, AMCSolution, ShortTimeout);

        if (AMCSolution <> '') then begin
            AMCBankingSetup.Solution := CopyStr(AMCSolution, 1, 50);
            AMCBankingSetup.Modify();
            Commit(); //Need to commit, to make sure right solution is used after this point
        end;

        //First we update the URLs
        if (UpdURL) then begin
            if (URLSChanged) then begin
                AMCBankingSetup."Sign-up URL" := SignupURL;
                AMCBankingSetup."Service URL" := LowerCase(ServiceURL);
                AMCBankingSetup."Support URL" := SupportURL;
                AMCBankingSetup.MODIFY();
            end
            else begin
                if (UpperCase(AMCBankingSetup.Solution) <> UpperCase(AMCBankingMgt.GetEnterPriseSolutionCode())) then
                    AMCBankingMgt.SetURLsToDefault(AMCBankingSetup);

                if ((AMCSpecificURL <> '') or (AMCSignUpURL <> '') or (AMCSupportURL <> '')) and (not AMCBankingMgt.IsSolutionSandbox(AMCBankingSetup)) then begin
                    if ((AMCSpecificURL <> '') and (UpperCase(AMCBankingSetup.Solution) <> UpperCase(AMCBankingMgt.GetEnterPriseSolutionCode()))) then
                        AMCBankingSetup."Service URL" := AMCBankingMgt.GetServiceURL(AMCSpecificURL, AMCBankingSetup."Namespace API Version");

                    if (AMCSignUpURL <> '') then
                        AMCBankingSetup."Sign-up URL" := CopyStr(AMCSignUpURL, 1, 250);

                    if (AMCSupportURL <> '') then
                        AMCBankingSetup."Support URL" := CopyStr(AMCSupportURL, 1, 250);

                    AMCBankingSetup.Modify();
                end;
            end;
            commit(); //Need to commit, to make sure right service URL is used after this point
        end;

        if (UpdDataExchDef) then begin
            if (UpdCreditTransfer) then
                CheckCreateDataExchDef(AMCBankingMgt.GetDataExchDef_CT());

            if (UpdateStatementImport) then
                CheckCreateDataExchDef(AMCBankingMgt.GetDataExchDef_STMT());

        end;

        AMCBankingMgt.AMCBankInitializeBaseData();

        if (UpdBank) then
            AMCBankImpBankListHndl.GetBankListFromWebService(false, BankCountryCode, LongTimeout, AMCBankingMgt.GetAppCaller());

        if (UpdBankAccounts) then
            if (not TempOnlineBankAccLink.IsEmpty()) then begin
                TempOnlineBankAccLink.Reset();
                TempOnlineBankAccLink.SetCurrentKey("Automatic Logon Possible");
                TempOnlineBankAccLink.SetRange(TempOnlineBankAccLink."Automatic Logon Possible", true);
                if (TempOnlineBankAccLink.FindSet()) then
                    repeat
                        BankAccount.Reset();
                        if (BankAccount.get(TempOnlineBankAccLink."No.")) then begin
                            if (BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_CT())) then
                                BankAccount."Payment Export Format" := AMCBankingMgt.GetDataExchDef_CT();

                            if (BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_STMT())) then
                                BankAccount."Bank Statement Import Format" := AMCBankingMgt.GetDataExchDef_STMT();

                            if (BankAccount."Credit Transfer Msg. Nos." = '') then
                                BankAccount."Credit Transfer Msg. Nos." := AMCBankingMgt.GetDefaultCreditTransferMsgNo();

                            BankAccount.Modify();
                        end
                    until TempOnlineBankAccLink.Next() = 0
            end
            else begin
                BankAccount.Reset();
                BankAccount.SetRange(Blocked, false);
                if (BankAccount.FindSet()) then
                    repeat
                        if BankAccount."Payment Export Format" = '' then
                            if (BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_CT())) then
                                BankAccount."Payment Export Format" := AMCBankingMgt.GetDataExchDef_CT();

                        if BankAccount."Bank Statement Import Format" = '' then
                            if (BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_STMT())) then
                                BankAccount."Bank Statement Import Format" := AMCBankingMgt.GetDataExchDef_STMT();

                        if BankAccount."Payment Export Format" = AMCBankingMgt.GetDataExchDef_CT() then
                            if (BankAccount."Credit Transfer Msg. Nos." = '') then
                                BankAccount."Credit Transfer Msg. Nos." := AMCBankingMgt.GetDefaultCreditTransferMsgNo();

                        BankAccount.Modify();
                    until BankAccount.Next() = 0;
            end;

        exit(BasisSetupRanOK);
    end;

#if not CLEAN20
    [Obsolete('This method is obsolete, there is no replacement. It will be removed in future release', '20.0')]
    procedure GetDataExchDefsFromWebservice(DataExchDefFilter: Text; ApplVersion: Text; BuildNumber: Text; Timeout: Integer; AppCaller: Text[30]): Boolean;
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        if (SendDataExchRequestToWebService(TempBlob, true, Timeout, ApplVersion, BuildNumber, AppCaller)) then
            exit(GetDataExchangeData(TempBlob, DataExchDefFilter))
        else
            exit(false)
    end;
#endif
    local procedure CheckCreateDataExchDef(DataExchDefCode: Code[20])
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        if (DataExchDef.Get(DataExchDefCode)) then
            DataExchDef.Delete(true);

        CASE DataExchDefCode OF
            AMCBankingMgt.GetDataExchDef_CT():
                begin
                    DataExchDef.Init();
                    DataExchDef.Validate(Code, DataExchDefCode);
                    DataExchDef.Validate(Name, AMCBankingMgt.GetAppCaller() + ' - Credit Transfer');
                    DataExchDef.Validate(Type, DataExchDef.Type::"Payment Export");
                    DataExchDef.Validate("Data Handling Codeunit", 0);
                    DataExchDef.Validate("Validation Codeunit", Codeunit::"AMC Bank Exp. CT Valid.");
                    DataExchDef.Validate("Reading/Writing Codeunit", CODEUNIT::"AMC Bank Exp. CT Write");
                    DataExchDef.Validate("Ext. Data Handling Codeunit", Codeunit::"AMC Bank Exp. CT Hndl");
                    DataExchDef.Validate("Reading/Writing XMLport", Xmlport::"AMC Bank Export CT");
                    DataExchDef.Validate("User Feedback Codeunit", Codeunit::"AMC Bank Exp. CT Feedback");
                    DataExchDef.Insert();

                    if (not DataExchLineDef.Get(DataExchDefCode)) then
                        DataExchLineDef.InsertRec(DataExchDefCode, DataExchDefCode, DataExchDefCode, 0);

                    if (not DataExchMapping.get(DataExchDefCode)) then begin
                        DataExchMapping.Init();
                        DataExchMapping.Validate("Data Exch. Def Code", DataExchDefCode);
                        DataExchMapping.Validate("Data Exch. Line Def Code", DataExchDefCode);
                        DataExchMapping.Validate("Table ID", Database::"Payment Export Data");
                        DataExchMapping.Validate(Name, DataExchDef.Name);
                        DataExchMapping.Validate("Pre-Mapping Codeunit", 0);
                        DataExchMapping.Validate("Mapping Codeunit", Codeunit::"AMC Bank Exp. CT Pre-Map");
                        DataExchMapping.Validate("Post-Mapping Codeunit", 0);
                        DataExchMapping.Insert();
                    end;

                    if DataExchDef.GET(DataExchDefCode) then
                        InsertUpdateBankExportImport(DataExchDefCode, DataExchDef.Name);
                end;
            AMCBankingMgt.GetDataExchDef_STMT():
                BEGIN
                    DataExchDef.Init();
                    DataExchDef.Validate(Code, DataExchDefCode);
                    DataExchDef.Validate(Name, AMCBankingMgt.GetAppCaller() + ' - Bank Statement');
                    DataExchDef.Validate(Type, DataExchDef.Type::"Bank Statement Import");
                    DataExchDef.Validate("Data Handling Codeunit", 0);
                    DataExchDef.Validate("Validation Codeunit", 0);
                    DataExchDef.Validate("Reading/Writing Codeunit", CODEUNIT::"AMC Bank Import Statement");
                    DataExchDef.Validate("Ext. Data Handling Codeunit", Codeunit::"AMC Bank Imp.STMT. Hndl");
                    DataExchDef.Validate("Reading/Writing XMLport", 0);
                    DataExchDef.Validate("User Feedback Codeunit", 0);
                    DataExchDef.Insert();

                    if (not DataExchLineDef.Get(DataExchDefCode)) then
                        DataExchLineDef.InsertRec(DataExchDefCode, DataExchDefCode, DataExchDefCode, 0);

                    if (not DataExchMapping.get(DataExchDefCode)) then begin
                        DataExchMapping.Init();
                        DataExchMapping.Validate("Data Exch. Def Code", DataExchDefCode);
                        DataExchMapping.Validate("Data Exch. Line Def Code", DataExchDefCode);
                        DataExchMapping.Validate("Table ID", Database::"Bank Acc. Reconciliation Line");
                        DataExchMapping.Validate(Name, DataExchDef.Name);
                        DataExchMapping.Validate("Pre-Mapping Codeunit", Codeunit::"AMC Bank Imp.-Pre-Process");
                        DataExchMapping.Validate("Mapping Codeunit", Codeunit::"AMC Bank Process Statement");
                        DataExchMapping.Validate("Post-Mapping Codeunit", Codeunit::"AMC Bank Imp.-Post-Process");
                        DataExchMapping.Insert();
                    end;

                    if DataExchDef.GET(DataExchDefCode) then
                        InsertUpdateBankExportImport(DataExchDefCode, DataExchDef.Name);

                END;
        END;
    end;

    procedure GetModuleInfoFromWebservice(Var XTLUrl: Text; Var SignUpUrl: Text; var SupportUrl: Text; Var Solution: Text; Timeout: Integer): Boolean;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ModuleTempBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Handled: Boolean;
        webcall: text;
    begin

        webcall := ModuleWebCallTxt;
        AMCBankingMgt.CheckCredentials();
        AMCBankingSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(HttpRequestMessage, AMCBankingMgt.GetLicenseServerName() + '/' + AMCBankingMgt.GetLicenseXmlApi(), 'POST');

        PrepareSOAPRequestBodyModuleCreate(HttpRequestMessage);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(HttpRequestMessage);

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.OnBeforeExecuteWebServiceRequest(Handled, HttpRequestMessage, HttpResponseMessage, webcall, AMCBankingMgt.GetAppCaller()); //For mockup testing
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, HttpRequestMessage, HttpResponseMessage, webcall, AMCBankingMgt.GetAppCaller(), true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(HttpResponseMessage, ModuleTempBlob, webcall, false);
        exit(GetModuleInfoData(ModuleTempBlob, XTLUrl, SignUpUrl, SupportUrl, Solution, AMCBankingMgt.GetAppCaller())); //Get reponse and XTLUrl and Solution
    end;

    local procedure SendDataExchRequestToWebService(var TempBlob: Codeunit "Temp Blob"; EnableUI: Boolean; Timeout: Integer; ApplVersion: Text; BuildNumber: Text; AppCaller: Text[30]): Boolean
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        webcall: text;
        Handled: Boolean;
        Result: Text;
    begin
        webcall := DataExchangeWebCallTxt;
        AMCBankingMgt.CheckCredentials();
        AMCBankingSetup.Get();

        AMCBankServiceRequestMgt.InitializeHttp(HttpRequestMessage, AMCBankingSetup."Service URL", 'POST');

        PrepareSOAPRequestBodyDataExchangeDef(HttpRequestMessage, ApplVersion, BuildNumber);

        //Set Content-Type header
        AMCBankServiceRequestMgt.SetHttpContentsDefaults(HttpRequestMessage);

        if not EnableUI then
            AMCBankServiceRequestMgt.DisableProgressDialog();

        //Send Request to webservice
        Handled := false;
        AMCBankServiceRequestMgt.SetTimeout(Timeout);
        AMCBankServiceRequestMgt.OnBeforeExecuteWebServiceRequest(Handled, HttpRequestMessage, HttpResponseMessage, webcall, AppCaller); //For mockup testing
        AMCBankServiceRequestMgt.ExecuteWebServiceRequest(Handled, HttpRequestMessage, HttpResponseMessage, webcall, AppCaller, true);
        AMCBankServiceRequestMgt.GetWebServiceResponse(HttpResponseMessage, TempBlob, webcall + AMCBankServiceRequestMgt.GetResponseTag(), true);
        if (AMCBankServiceRequestMgt.HasResponseErrors(TempBlob, AMCBankServiceRequestMgt.GetHeaderXPath(), webcall + AMCBankServiceRequestMgt.GetResponseTag(), Result, AppCaller)) then begin
            if (EnableUI) then
                AMCBankServiceRequestMgt.ShowResponseError(Result);

            exit(false)
        end
        else
            exit(true);
    end;

    [NonDebuggable]
    local procedure PrepareSOAPRequestBodyModuleCreate(var HttpRequestMessage: HttpRequestMessage);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        contentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        AmcWebServiceXMLElement: XmlElement;
        FunctionXmlElement: XmlElement;
        TempXmlDocText: Text;
        EncodPos: Integer;
        Application1: Text;
        Application1patch: Text;
        Application1Version: Text;
        Command: Text;
        Password: Text;
        Serialnumber: Text;
        System: Text;
    begin

        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankingSetup.Get();
        AmcWebServiceXMLElement := XmlElement.Create(ModuleWebCallTxt);
        AmcWebServiceXMLElement.SetAttribute('webservice', '1.0');

        Application1 := 'AMC-Banking';
        Application1patch := 'XXX';
        Application1Version := 'XXX';
        Command := 'module';
        Password := AMCBankingSetup.GetPassword();
        Serialnumber := CopyStr(AMCBankingMgt.GetLicenseNumber(), 1, 50);
        System := 'Business Central';

        OnPrepareSOAPRequestBodyModuleCreate(Application1, Application1patch, Application1Version,
                                             Command, Password, Serialnumber, System);

        FunctionXmlElement := XmlElement.Create('function');
        FunctionXmlElement.SetAttribute('application1', Application1);
        FunctionXmlElement.SetAttribute('application1patch', Application1patch);
        FunctionXmlElement.SetAttribute('application1version', Application1Version);
        FunctionXmlElement.SetAttribute('command', Command);
        FunctionXmlElement.SetAttribute('password', Password);
        FunctionXmlElement.SetAttribute('serialnumber', Serialnumber);
        FunctionXmlElement.SetAttribute('system', System);

        AmcWebServiceXMLElement.Add(FunctionXmlElement);
        BodyContentXmlDoc.Add(AmcWebServiceXMLElement);
        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        //Licenseserver can not parse ' standalone="No"'
        EncodPos := StrPos(TempXmlDocText, ' standalone="No"');
        if (EncodPos > 0) THEN
            TempXmlDocText := DelStr(TempXmlDocText, EncodPos, STRLEN(' standalone="No"'));

        contentHttpContent.WriteFrom(TempXmlDocText);
        HttpRequestMessage.Content(contentHttpContent);

    end;

    [IntegrationEvent(false, false)]
    procedure OnPrepareSOAPRequestBodyModuleCreate(var Application1: Text; var Application1patch: Text; var Application1Version: Text;
                                                   var Command: Text; var Password: Text; var Serialnumber: Text; var System: Text)
    begin
    end;

    local procedure GetModuleInfoData(TempBlob: Codeunit "Temp Blob"; Var XTLUrl: Text; Var SignupUrl: Text; Var SupportUrl: Text; Var Solution: Text; Appcaller: Text[30]): Boolean;
    var
        ResponseHttpContent: HttpContent;
        XMLDocOut: XmlDocument;
        ModuleXMLNodeList: XmlNodeList;
        ModuleXMLNodeCount: Integer;
        ModuleIdXMLNode: XmlNode;
        ResultXMLNode: XmlNode;
        DataXMLAttributeCollection: XMLAttributeCollection;
        DataXmlAttribute: XmlAttribute;
        AttribCounter: Integer;
        ResponseInStream: InStream;
        XPath: Text;
        XResultPath: Text;
        ModuleName: Text;
        Erp: Text;
        Result: Text;
        ResultText: Text;
        ResultUrl: Text;
    begin

        TempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, XMLDocOut);
        ResponseHttpContent.WriteFrom(ResponseInStream);

        XResultPath := 'amcwebservice//functionfeedback/header/answer';
        if (XMLDocOut.SelectSingleNode(XResultPath, ResultXMLNode)) then
            if (ResultXMLNode.AsXmlElement().HasAttributes()) then begin
                DataXMLAttributeCollection := ResultXMLNode.AsXmlElement().Attributes();
                for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                    DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                    if (DataXmlAttribute.Name() = 'result') then
                        Result += DataXmlAttribute.Value();
                end;
            end;
        if (Result <> 'ok') then begin
            ResultText := TryLoadErrorLbl;
            XResultPath := 'amcwebservice//functionfeedback/body/syslog';
            XMLDocOut.selectNodes(XResultPath, ModuleXMLNodeList);
            FOR ModuleXMLNodeCount := 1 TO ModuleXMLNodeList.Count() DO BEGIN
                ModuleXMLNodeList.Get(ModuleXMLNodeCount, ResultXMLNode);
                if (ResultXMLNode.AsXmlElement().HasAttributes()) then begin
                    DataXMLAttributeCollection := ResultXMLNode.AsXmlElement().Attributes();
                    for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                        DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                        if (DataXmlAttribute.Name() = 'errortext') then
                            if (ResultText <> '') then
                                ResultText += '\' + DataXmlAttribute.Value()
                            else
                                ResultText := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'url') then
                            if (ResultUrl <> '') then
                                ResultUrl += '\' + DataXmlAttribute.Value()
                            else
                                ResultUrl := DataXmlAttribute.Value();
                    end;
                end;
            end;
            AMCBankServiceRequestMgt.LogHttpActivity('amcwebservice', AppCaller, ResultText, '', ResultUrl, ResponseHttpContent, Result);
            error(ResultText);
        end;

        XPath := 'amcwebservice//functionfeedback/body/package/sysusertable';
        XMLDocOut.selectNodes(XPath, ModuleXMLNodeList);
        IF ModuleXMLNodeList.Count() > 0 THEN
            FOR ModuleXMLNodeCount := 1 TO ModuleXMLNodeList.Count() DO BEGIN
                ModuleXMLNodeList.Get(ModuleXMLNodeCount, ModuleIdXMLNode);
                if (ModuleIdXMLNode.AsXmlElement().HasAttributes()) then begin
                    DataXMLAttributeCollection := ModuleIdXMLNode.AsXmlElement().Attributes();
                    for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                        DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                        if (DataXmlAttribute.Name() = 'item') then
                            ModuleName := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'xtlurl') then
                            XTLUrl := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'signupurl') then
                            SignupUrl := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'supporturl') then
                            SupportUrl := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'solution') then
                            Solution := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'erp') then
                            Erp := DataXmlAttribute.Value();
                    end;
                end;
                AMCBankServiceRequestMgt.LogHttpActivity('amcwebservice', AppCaller, Result, '', '', ResponseHttpContent, Result);
                if ((LowerCase(ModuleName) = LowerCase('AMC-Banking')) and
                    (LowerCase(Erp) = LowerCase('Dyn. NAV'))) then
                    exit(true)
                else begin
                    ModuleName := '';
                    XTLUrl := '';
                    SignupUrl := '';
                    SupportUrl := '';
                    Solution := AMCBankingMgt.GetDemoSolutionCode();
                    Erp := '';
                end;
            end;

        exit(false);
    end;

    [NonDebuggable]
    local procedure PrepareSOAPRequestBodyDataExchangeDef(var HttpRequestMessage: HttpRequestMessage; ApplVersion: Text; BuildNumber: Text);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        contentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        EnvelopeXMLElement: XmlElement;
        BodyXMLElement: XMLElement;
        OperationXmlNode: XMLElement;
        ChildXmlElement: XmlElement;
        TempXmlDocText: Text;
    begin
        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankingSetup.Get();
        AMCBankServiceRequestMgt.CreateEnvelope(BodyContentXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');
        AMCBankServiceRequestMgt.AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
        AMCBankServiceRequestMgt.AddElement(BodyXMLElement, AMCBankingMgt.GetNamespace(), 'dataExchange', '', OperationXmlNode, '', '', '');

        if (ApplVersion <> '') then begin
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'appl', ApplVersion, ChildXmlElement, '', '', '');
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'build', BuildNumber, ChildXmlElement, '', '', '');
        end
        else begin
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'appl', GetApplVersion(), ChildXmlElement, '', '', '');
            AMCBankServiceRequestMgt.AddElement(OperationXmlNode, '', 'build', GetBuildNumber(), ChildXmlElement, '', '', '');
        end;

        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        AMCBankServiceRequestMgt.RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        HttpRequestMessage.Content(contentHttpContent);
    end;

    local procedure GetDataExchangeData(TempBlob: Codeunit "Temp Blob"; DataExchDefFilter: Text): Boolean;
    var
        DataTempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        XMLDocOut: XmlDocument;
        DataExchXMLNodeList: XmlNodeList;
        DataExchXMLNodeCount: Integer;
        ResponseInStream: InStream;
        OutStream: OutStream;
        ChildNode: XmlNode;

        DataExchDefCode: Code[20];
        Base64String: Text;
    begin
        TempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, XMLDocOut);

        if (XMLDocOut.selectNodes(ReturnPathTxt, DataExchXMLNodeList)) then //V17.5
            IF DataExchXMLNodeList.Count() > 0 THEN
                FOR DataExchXMLNodeCount := 1 TO DataExchXMLNodeList.Count() DO begin
                    DataExchXMLNodeList.Get(DataExchXMLNodeCount, ChildNode);
                    CLEAR(DataExchDefCode);
                    CLEAR(DataTempBlob);
                    DataExchDefCode := COPYSTR(AMCBankServiceRequestMgt.getNodeValue(ChildNode, './type'), 1, 20);
                    Base64String := AMCBankServiceRequestMgt.getNodeValue(ChildNode, './data');
                    DataTempBlob.CreateOutStream(OutStream);
                    Base64Convert.FromBase64(Base64String, OutStream);
                    //READ DATA INTO DataTempBlob
                    if ((DataTempBlob.HasValue()) and (DataExchDefCode <> '') and
                        (StrPos(DataExchDefFilter, DataExchDefCode) <> 0)) then
                        ImportDataExchDef(DataExchDefCode, DataTempBlob);

                end;
        exit(true);
    end;

    local procedure ImportDataExchDef(DataExchCode: Code[20]; TempBlob: Codeunit "Temp Blob");
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchDefInStream: InStream;
    begin

        if DataExchDef.GET(DataExchCode) then
            DataExchDef.DELETE(true);

        CLEAR(DataExchDef);
        TempBlob.CREATEINSTREAM(DataExchDefInStream);
        XMLPORT.IMPORT(XMLPORT::"Imp / Exp Data Exch Def & Map", DataExchDefInStream);

        CLEAR(DataExchDef);
        if DataExchDef.GET(DataExchCode) then
            InsertUpdateBankExportImport(DataExchCode, DataExchDef.Name);
    end;

    local procedure InsertUpdateBankExportImport(DataExchDefCode: Code[20]; DefName: Text[100])
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (BankExportImportSetup.GET(DataExchDefCode)) then
            BankExportImportSetup.Delete();

        CASE DataExchDefCode OF
            AMCBankingMgt.GetDataExchDef_CT():
                WITH BankExportImportSetup DO BEGIN
                    INIT();
                    Code := DataExchDefCode;
                    Name := DefName;
                    Direction := BankExportImportSetup.Direction::Export;
                    "Processing Codeunit ID" := CODEUNIT::"AMC Bank Exp. CT Launcher";
                    "Processing XMLport ID" := 0;
                    "Check Export Codeunit" := 0;
                    "Preserve Non-Latin Characters" := TRUE;
                    "Data Exch. Def. Code" := AMCBankingMgt.GetDataExchDef_CT();
                    BankExportImportSetup.Insert();
                END;
            AMCBankingMgt.GetDataExchDef_STMT():
                WITH BankExportImportSetup DO BEGIN
                    INIT();
                    Code := DataExchDefCode;
                    Name := DefName;
                    Direction := BankExportImportSetup.Direction::Import;
                    "Processing Codeunit ID" := CODEUNIT::"AMC Bank Exp. CT Launcher";
                    "Processing XMLport ID" := 0;
                    "Check Export Codeunit" := 0;
                    "Preserve Non-Latin Characters" := TRUE;
                    "Data Exch. Def. Code" := AMCBankingMgt.GetDataExchDef_STMT();
                    BankExportImportSetup.Insert();
                END;
        END
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetApplVersion(var ApplVersion: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetBuildNumber(var BuildNumber: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnOpenAssistedSetupPage(var BankDataConvServPPVisible: Boolean; var BankDataConvServCREMVisible: Boolean; var UpdPayMethVisible: Boolean; var UpdBankClearStdVisible: Boolean)
    begin
    end;

#if not CLEAN20    
    [IntegrationEvent(false, false)]
    [Obsolete('This IntegrationEvent is obsolete. A new OnAfterRunBasisSetupV19 IntegrationEvent is available, with the an extra parameters (var BasisSetupRanOK) to control if setup ran ok.', '20.0')]
    procedure OnAfterRunBasisSetupV16(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                                   UpdBank: Boolean; UpdPayMeth: Boolean; BankCountryCode: Code[10]; PaymCountryCode: Code[10];
                                   UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean;
                                   UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                                   UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; var TempOnlineBankAccLink: Record "Online Bank Acc. Link"; CallLicenseServer: Boolean)
    begin
    end;
#endif
    [IntegrationEvent(false, false)]
    procedure OnAfterRunBasisSetupV19(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                                   UpdBank: Boolean; UpdPayMeth: Boolean; BankCountryCode: Code[10]; PaymCountryCode: Code[10];
                                   UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean;
                                   UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                                   UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; var TempOnlineBankAccLink: Record "Online Bank Acc. Link"; CallLicenseServer: Boolean; var BasisSetupRanOK: Boolean)
    begin
    end;

    procedure DisplayAssistedSetupWizard(AssistedSetupNotification: Notification)
    var
        AMCBankAssistedSetup: Page "AMC Bank Assisted Setup";
    begin
        AMCBankAssistedSetup.Run();
    end;

    procedure DisplayAMCBankSetup(AssistedSetupNotification: Notification)
    var
        AMCBankingSetup: Page "AMC Banking Setup";
    begin
        AMCBankingSetup.Run();
    end;

    procedure UpgradeNotificationIsNeeded(DataExchDefCode: Code[20]): Boolean
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (BankExportImportSetup.Get(DataExchDefCode)) then begin
            if (BankExportImportSetup."Processing Codeunit ID" = Codeunit::"AMC Bank Upg. Notification") then
                exit(true);
        end
        else
            exit(true);

        exit(false);
    end;

    procedure GetBankExportNotificationId(DataExchDefCode: Code[20]): Guid
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (BankExportImportSetup.Get(DataExchDefCode)) then
            exit(BankExportImportSetup.SystemId);

        exit(CreateGuid());
    end;

    local procedure CallAssistedSetupNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        Notification.Id := NotificationId;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Message := AssistedSetupNeededNotificationTxt;
        Notification.AddAction(AssistedSetupNotificationActionTxt, Codeunit::"AMC Bank Assisted Mgt.", 'DisplayAssistedSetupWizard');
        Notification.Send();
    end;

    local procedure CallAMCEnabledAssistedSetupNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        Notification.Id := NotificationId;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Message := PleaseRunAssistedSetupNotificationActionTxt;
        Notification.Send();
    end;

    local procedure CallAMCEnabledSetupNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        Notification.Id := NotificationId;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Message := EnableSetupNeededNotificationTxt;
        Notification.Send();
    end;

    local procedure ClearAMCEnabledSetupNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        Notification.Id := NotificationId;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Message := '';
        Notification.Recall();
    end;

    local procedure ClearAssistedSetupNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        Notification.Id := NotificationId;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Message := '';
        Notification.Recall();
    end;

    local procedure CallDemoSolutionNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin
        if IsDemoSolutionNotificationEnabled(NotificationId) then begin
            Notification.Id := NotificationId;
            Notification.Scope := NotificationScope::LocalScope;
            Notification.Message := DemoSolutionNotificationTxt;
            Notification.AddAction(DemoSolutionNotificationActionTxt, Codeunit::"AMC Bank Assisted Mgt.", 'DisplayAMCBankSetup');
            Notification.AddAction(DontShowThisAgainMsg, Codeunit::"AMC Bank Assisted Mgt.", 'DisableDemoSolutionNotification');
            Notification.Send();
        end;
    end;

    procedure IsDemoSolutionNotificationEnabled(NotificationId: GUID): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.Disable(NotificationId) then
            exit(false);

        exit(true);
    end;

    procedure EnableDemoSolutionNotification(NotificationId: GUID)
    var
        MyNotifications: Record "My Notifications";
    begin
        if MyNotifications.Disable(NotificationId) then
            MyNotifications.SetStatus(NotificationId, true);
    end;

    procedure DisableDemoSolutionNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(Notification.Id()) then
            MyNotifications.InsertDefault(Notification.Id(), DemoSolutionNotificationNameTok, DemoSolutionNotificationDescTok, false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"AMC Banking Setup", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationAMCBankingSetup(var Rec: Record "AMC Banking Setup")
    var
    begin
        if (Rec."AMC Enabled") then begin
            if (UpgradeNotificationIsNeeded(AMCBankingMgt.GetDataExchDef_CT()) or
                UpgradeNotificationIsNeeded(AMCBankingMgt.GetDataExchDef_STMT())) then
                CallAMCEnabledAssistedSetupNotification(rec.SystemId)
            else begin
                ClearAssistedSetupNotification(rec.SystemId);
                ClearAMCEnabledSetupNotification(rec.SystemId);
            end
        end
        else
            CallAMCEnabledSetupNotification(Rec.SystemId);
    end;


    [EventSubscriber(ObjectType::Page, Page::"AMC Banking Setup", 'OnBeforeValidateEvent', 'Enabled', true, true)]
    local procedure ShowAssistedSetupNotificationValidateAMCBankingSetup(var Rec: Record "AMC Banking Setup")
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if (rec."AMC Enabled") then begin
            ClearAMCEnabledSetupNotification(rec.SystemId);
            if ((not BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_CT())) or
                 (not BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_STMT())) or
                 ((BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_CT()) and
                  (BankExportImportSetup."Processing Codeunit ID" = Codeunit::"AMC Bank Upg. Notification"))) or
                 ((BankExportImportSetup.Get(AMCBankingMgt.GetDataExchDef_STMT()) and
                  (BankExportImportSetup."Processing Codeunit ID" = Codeunit::"AMC Bank Upg. Notification")))) then
                CallAMCEnabledAssistedSetupNotification(rec.SystemId);
        end
        else begin
            ClearAssistedSetupNotification(rec.SystemId);
            CallAMCEnabledSetupNotification(Rec.SystemId);
        end;
    end;


    [EventSubscriber(ObjectType::Page, Page::"AMC Bank Bank Name List", 'OnOpenPageEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationAMCBankBanks(var rec: Record "AMC Bank Banks")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.get();
        if (AMCBankingSetup."AMC Enabled") then
            if (UpgradeNotificationIsNeeded(AMCBankingMgt.GetDataExchDef_CT()) or
                UpgradeNotificationIsNeeded(AMCBankingMgt.GetDataExchDef_STMT())) then
                CallAssistedSetupNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Journal", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPaymentJournal(var Rec: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then;
        if (AMCBankingSetup."AMC Enabled") then begin
            //Show notification if Assisted setup has to run after upgrade
            if (GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name")) then
                if (GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account") then
                    if (BankAccount.get(GenJournalBatch."Bal. Account No.")) then
                        if (UpgradeNotificationIsNeeded(BankAccount."Payment Export Format")) then begin
                            CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Payment Export Format"));
                            exit;
                        end;

            //Show notification if AMC Banking service is demo solution
            if (not AMCBankingSetup.IsEmpty()) then
                if (GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name")) then
                    if (GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account") then
                        if (BankAccount.get(GenJournalBatch."Bal. Account No.")) then
                            if ((BankAccount."Payment Export Format" = AMCBankingMgt.GetDataExchDef_CT()) and
                               (AMCBankingSetup.Solution = AMCBankingMgt.GetDemoSolutionCode())) then
                                CallDemoSolutionNotification(GetBankExportNotificationId(BankAccount."Payment Export Format"));
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Pmt. Reconciliation Journals", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPmtReconJours(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then;

        if (AMCBankingSetup."AMC Enabled") then begin
            //Show notification if Assisted setup has to run after upgrade
            if (BankAccount.get(rec."Bank Account No.")) then
                if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                    CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                    exit;
                end;

            //Show notification if AMC Banking service is demo solution
            if (not AMCBankingSetup.IsEmpty()) then
                if (BankAccount.get(rec."Bank Account No.")) then
                    if ((BankAccount."Bank Statement Import Format" = AMCBankingMgt.GetDataExchDef_STMT()) and
                        (AMCBankingSetup.Solution = AMCBankingMgt.GetDemoSolutionCode())) then
                        CallDemoSolutionNotification(AMCBankingSetup.SystemId);
        end;
    end;


    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPaymntReconJour(var Rec: Record "Bank Acc. Reconciliation Line")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then;
        if (AMCBankingSetup."AMC Enabled") then begin
            //Show notification if Assisted setup has to run after upgrade
            if (BankAccount.get(rec."Bank Account No.")) then
                if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                    CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                    exit;
                end;
            //Show notification if AMC Banking service is demo solution
            if (AMCBankingSetup.Get()) then
                if (BankAccount.get(rec."Bank Account No.")) then
                    if ((BankAccount."Bank Statement Import Format" = AMCBankingMgt.GetDataExchDef_STMT()) and
                       (AMCBankingSetup.Solution = AMCBankingMgt.GetDemoSolutionCode())) then
                        CallDemoSolutionNotification(AMCBankingSetup.SystemId);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Acc. Reconciliation List", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankAccReconList(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then;
        if (AMCBankingSetup."AMC Enabled") then begin
            //Show notification if Assisted setup has to run after upgrade
            if (BankAccount.get(rec."Bank Account No.")) then
                if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                    CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                    exit;
                end;

            //Show notification if AMC Banking service is demo solution
            if (not AMCBankingSetup.IsEmpty) then
                if (BankAccount.get(rec."Bank Account No.")) then
                    if ((BankAccount."Bank Statement Import Format" = AMCBankingMgt.GetDataExchDef_STMT()) and
                       (AMCBankingSetup.Solution = AMCBankingMgt.GetDemoSolutionCode())) then
                        CallDemoSolutionNotification(AMCBankingSetup.SystemId);
        end
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Acc. Reconciliation", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankAccRecon(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then;
        if (AMCBankingSetup."AMC Enabled") then begin
            //Show notification if Assisted setup has to run after upgrade
            if (BankAccount.get(rec."Bank Account No.")) then
                if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                    CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                    exit;
                end;

            //Show notification if AMC Banking service is demo solution
            if (not AMCBankingSetup.IsEmpty()) then
                if (BankAccount.get(rec."Bank Account No.")) then
                    if ((BankAccount."Bank Statement Import Format" = AMCBankingMgt.GetDataExchDef_STMT()) and
                       (AMCBankingSetup.Solution = AMCBankingMgt.GetDemoSolutionCode())) then
                        CallDemoSolutionNotification(AMCBankingSetup.SystemId);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Export/Import Setup", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankExportImportSetup(var Rec: Record "Bank Export/Import Setup")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if (AMCBankingSetup.Get()) then;
        //Show notification if Assisted setup has to run after upgrade
        if (AMCBankingSetup."AMC Enabled") then
            if (UpgradeNotificationIsNeeded(Rec.Code)) then
                CallAssistedSetupNotification(Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"AMC Bank Assisted Setup", AssistedSetupGroup::ReadyForBusiness,
                                            '', VideoCategory::ReadyForBusiness, AssistedSetupHelpTxt);

        if AMCBankingSetup.Get() then
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"AMC Bank Assisted Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnAfterRunAssistedSetup', '', true, true)]
    local procedure UpdateAssistedSetupStatus(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        GuidedExperience: Codeunit "Guided Experience";
        BaseAppID: Codeunit "BaseApp ID";
    begin
        if ExtensionId <> BaseAppID.Get() then
            exit;
        if ObjectID <> Page::"AMC Bank Assisted Setup" then
            exit;
        if AMCBankingSetup.Get() then
            GuidedExperience.CompleteAssistedSetup(ObjectType, ObjectID);
    end;

}
