codeunit 20117 "AMC Bank Assisted Mgt."
{
    trigger OnRun()
    begin

    end;

    var
        AMCBankServMgt: Codeunit "AMC Banking Mgt.";
        GLBResponsePath: Text;
        AddnlInfoTxt: Label 'For more information, go to %1.';
        NotCorrectUserLbl: Label 'The Web Service Setup User Name (%1) does not match the License number (%2) or the (%3)';
        YouHave2OptionsLbl: Label 'You have two option to change this:';
        UseBCLicenseLbl: Label '1. Please register the User Name (%1) using the Sign-up URL %2';
        UseDemoUserLbl: Label '2. Delete the Web Service setup record using the Trash can symbol and reopen the page to use (%1)';
        DataExchResponseNodeTxt: Label 'dataExchangeResponse', Locked = true;
        TryLoadErrorLbl: Label 'The web service returned an error message:\';
        WebLoadErrorLbl: Label 'Status code: %1';
        AssistedSetupNeededNotificationTxt: Label 'The AMC Banking 365 Foundation extension needs some information.';
        AssistedSetupNotificationActionTxt: Label 'Do you want to open the AMC Banking Setup page to run the Assisted Setup action?';
        DemoSolutionNotificationTxt: Label 'The AMC Banking 365 Foundation extension is in Demo mode.';
        DemoSolutionNotificationActionTxt: Label 'Do you want to open the AMC Banking 365 Foundation extension setup page?';
        AssistedSetupTxt: Label 'Set up AMC Banking 365 Foundation extension';

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

    procedure RunBasisSetup(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                            UpdBank: Boolean; UpdPayMeth: Boolean; CountryCode: Code[10];
                            UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean; UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                            UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; CallLicenseServer: Boolean): Boolean;
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        AMCBankServiceSetup: Record "AMC Banking Setup";
        AMCBankImpBankListHndl: Codeunit "AMC Bank Imp.BankList Hndl";
        LongTimeout: Integer;
        ShortTimeout: Integer;
        AMCBoughtModule: Boolean;
        AMCSolution: text;
        AMCSpecificURL: Text;
        BasisSetupRanOK: Boolean;
        DataExchDef_Filter: Text;
    begin
        ShortTimeout := 5000;
        LongTimeout := 30000;
        BasisSetupRanOK := true;

        if (NOT AMCBankServiceSetup.Get()) then begin
            AMCBankServiceSetup.Init();
            AMCBankServiceSetup.Insert(true);
            Commit(); //Need to commit, to make sure record exist, if RunBasisSetup at one point is called from Installation/Upgrade CU
        end;

        if ((AMCBankServiceSetup."User Name" <> AMCBankServiceSetup.GetDemoUserName()) and
           (AMCBankServiceSetup."User Name" <> AMCBankServMgt.GetLicenseNumber())) then
            error(StrSubstNo(NotCorrectUserLbl, AMCBankServiceSetup."User Name", AMCBankServMgt.GetLicenseNumber(), AMCBankServiceSetup.GetDemoUserName()) + '\\' +
                  YouHave2OptionsLbl + '\\' +
                  StrSubstNo(UseBCLicenseLbl, AMCBankServMgt.GetLicenseNumber(), AMCBankServiceSetup."Sign-up URL") + '\\' +
                  StrSubstNo(UseDemoUserLbl, AMCBankServiceSetup.GetDemoUserName()));

        //if demouser - always return demosolution
        if (AMCBankServiceSetup.GetUserName() = AMCBankServiceSetup.GetDemoUserName()) then begin
            AMCSolution := AMCBankServMgt.GetDemoSolutionCode();
            AMCBankServiceSetup.Solution := CopyStr(AMCSolution, 1, 50);
            AMCBankServMgt.SetURLsToDefault(AMCBankServiceSetup);
        end
        else
            if (CallLicenseServer) then
                AMCBoughtModule := GetModuleInfoFromWebservice(AMCSpecificURL, AMCSolution, ShortTimeout);

        if (AMCSolution <> '') then begin
            AMCBankServiceSetup.Solution := CopyStr(AMCSolution, 1, 50);
            AMCBankServiceSetup.Modify();
            Commit(); //Need to commit, to make sure right solution is used after this point
        end;

        //First we update the URLs
        if (UpdURL) then begin
            if (URLSChanged) then begin
                AMCBankServiceSetup."Sign-up URL" := SignupURL;
                AMCBankServiceSetup."Service URL" := LowerCase(ServiceURL);
                AMCBankServiceSetup."Support URL" := SupportURL;
                AMCBankServiceSetup.MODIFY();
            end
            else begin
                AMCBankServMgt.SetURLsToDefault(AMCBankServiceSetup);

                if (AMCSpecificURL <> '') then begin
                    AMCBankServiceSetup."Service URL" := AMCBankServMgt.GetServiceURL(AMCSpecificURL, AMCBankServiceSetup."Namespace API Version");
                    AMCBankServiceSetup.Modify();
                end;
            end;
            commit(); //Need to commit, to make sure right service URL is used after this point
        end;

        if (UpdDataExchDef) then begin
            if (UpdCreditTransfer) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_CT() + ',';

            if (UpdateStatementImport) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_STMT() + ',';

            if (UpdPositivePay) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_PP() + ',';

            if (UpdCreditAdvice) then
                DataExchDef_Filter += AMCBankServMgt.GetDataExchDef_CREM();

            if (DataExchDef_Filter <> '') then
                BasisSetupRanOK := GetDataExchDefsFromWebservice(DataExchDef_Filter, ApplVer, BuildNo, LongTimeout);
        end;

        AMCBankServMgt.AMCBankInitializeBaseData();

        if (UpdBank) then
            AMCBankImpBankListHndl.GetBankListFromWebService(false, CountryCode, LongTimeout);

        if (UpdBankAccounts) and (BasisSetupRanOK) then begin
            BankAccount.Reset();
            BankAccount.SetRange(Blocked, false);
            if (BankAccount.FindSet()) then
                repeat
                    if BankAccount."Payment Export Format" = '' then
                        if (BankExportImportSetup.Get(AMCBankServMgt.GetDataExchDef_CT())) then
                            BankAccount."Payment Export Format" := AMCBankServMgt.GetDataExchDef_CT();

                    if BankAccount."Bank Statement Import Format" = '' then
                        if (BankExportImportSetup.Get(AMCBankServMgt.GetDataExchDef_STMT())) then
                            BankAccount."Bank Statement Import Format" := AMCBankServMgt.GetDataExchDef_STMT();

                    if BankAccount."Payment Export Format" = AMCBankServMgt.GetDataExchDef_CT() then
                        if (BankAccount."Credit Transfer Msg. Nos." = '') then
                            BankAccount."Credit Transfer Msg. Nos." := AMCBankServMgt.GetDefaultCreditTransferMsgNo();

                    BankAccount.Modify();
                until BankAccount.Next() = 0;
        end;
        exit(BasisSetupRanOK);
    end;

    procedure GetDataExchDefsFromWebservice(DataExchDefFilter: Text; ApplVersion: Text; BuildNumber: Text; Timeout: Integer): Boolean;
    var
        TempBlobRequestBody: Codeunit "Temp Blob";
    begin
        GLBResponsePath := GetDataExchResponseNodeTxt();
        SendRequestToWebService(TempBlobRequestBody, true, Timeout, ApplVersion, BuildNumber);
        exit(GetDataExchangeData(TempBlobRequestBody, DataExchDefFilter));
    end;


    procedure GetModuleInfoFromWebservice(Var XTLUrl: Text; Var Solution: Text; Timeout: Integer): Boolean;
    var
        HeadersClientHttp: HttpHeaders;
        ClientHttp: HttpClient;
        HeadersContentHttp: HttpHeaders;
        ModuleRequestMessage: HttpRequestMessage;
        ModuleResponseMessage: HttpResponseMessage;
    begin

        AMCBankServMgt.CheckCredentials();

        ModuleRequestMessage.Method('POST');
        ModuleRequestMessage.SetRequestUri('https://license.amcbanking.com/' + AMCBankServMgt.GetLicenseXmlApi());
        ModuleRequestMessage.GetHeaders(HeadersClientHttp);

        //Set accept header
        if (HeadersClientHttp.Contains('Accept')) THEN
            HeadersClientHttp.Remove('Accept');

        HeadersClientHttp.Add('Accept', 'text/xml; charset=UTF-8');

        PrepareSOAPRequestBodyModuleCreate(ModuleRequestMessage);

        //Set Content-Type header
        ModuleRequestMessage.Content().GetHeaders(HeadersContentHttp);
        if (HeadersContentHttp.Contains('Content-Type')) THEN
            HeadersContentHttp.Remove('Content-Type');

        HeadersContentHttp.Add('Content-Type', 'text/xml; charset=UTF-8');

        //Send Request to webservice
        ClientHttp.Send(ModuleRequestMessage, ModuleResponseMessage);

        IF (NOT ModuleResponseMessage.IsSuccessStatusCode()) THEN
            ERROR(TryLoadErrorLbl + StrSubstNo(WebLoadErrorLbl, FORMAT(ModuleResponseMessage.HttpStatusCode()) + ' ' + ModuleResponseMessage.ReasonPhrase()));

        //Get reponse and XTLUrl and Solution
        exit(GetModuleInfoData(ModuleResponseMessage, XTLUrl, Solution));
    end;

    local procedure SendRequestToWebService(var TempBlobBody: Codeunit "Temp Blob"; EnableUI: Boolean; Timeout: Integer; ApplVersion: Text; BuildNumber: Text)
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
        ResponseInStream: InStream;
        InStream: InStream;
        ResponseOutStream: OutStream;
    begin
        AMCBankServMgt.CheckCredentials();

        AMCBankServiceSetup.Get();

        PrepareSOAPRequestBodyDataExchangeDef(TempBlobBody, ApplVersion, BuildNumber);

        TempBlobBody.CreateInStream(InStream);
        SOAPWebServiceRequestMgt.SetGlobals(InStream, AMCBankServiceSetup."Service URL", AMCBankServiceSetup.GetUserName(), AMCBankServiceSetup.GetPassword());
        SOAPWebServiceRequestMgt.SetTimeout(Timeout);
        SOAPWebServiceRequestMgt.SetContentType('text/xml; charset=UTF-8');

        if not EnableUI then
            SOAPWebServiceRequestMgt.DisableProgressDialog();

        if SOAPWebServiceRequestMgt.SendRequestToWebService() then begin
            SOAPWebServiceRequestMgt.GetResponseContent(ResponseInStream);

            if EnableUI then
                CheckIfErrorsOccurred(ResponseInStream);

            TempBlobBody.CreateOutStream(ResponseOutStream);
            CopyStream(ResponseOutStream, ResponseInStream);
        end else
            if EnableUI then
                SOAPWebServiceRequestMgt.ProcessFaultResponse(TryLoadErrorLbl);
    end;

    local procedure PrepareSOAPRequestBodyModuleCreate(var BodyRequestMessage: HttpRequestMessage);
    var
        AMCBankServiceSetup: Record "AMC Banking Setup";
        contentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        AmcWebServiceXMLElement: XmlElement;
        FunctionXmlElement: XmlElement;
        TempXmlDocText: Text;
        EncodPos: Integer;
    begin

        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankServiceSetup.Get();
        AmcWebServiceXMLElement := XmlElement.Create('amcwebservice');
        AmcWebServiceXMLElement.SetAttribute('webservice', '1.0');

        FunctionXmlElement := XmlElement.Create('function');
        FunctionXmlElement.SetAttribute('application1', 'AMC-Banking');
        FunctionXmlElement.SetAttribute('application1patch', 'XXX');
        FunctionXmlElement.SetAttribute('application1version', 'XXX');
        FunctionXmlElement.SetAttribute('command', 'module');
        FunctionXmlElement.SetAttribute('login', AMCBankServiceSetup.GetUserName());
        FunctionXmlElement.SetAttribute('password', AMCBankServiceSetup.GetPassword());
        FunctionXmlElement.SetAttribute('serialnumber', COPYSTR(AMCBankServMgt.GetLicenseNumber(), 1, 50));
        FunctionXmlElement.SetAttribute('system', 'Business Central');

        AmcWebServiceXMLElement.Add(FunctionXmlElement);
        BodyContentXmlDoc.Add(AmcWebServiceXMLElement);
        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        //Licenseserver can not parse ' standalone="No"'
        EncodPos := StrPos(TempXmlDocText, ' standalone="No"');
        if (EncodPos > 0) THEN
            TempXmlDocText := DelStr(TempXmlDocText, EncodPos, STRLEN(' standalone="No"'));

        contentHttpContent.WriteFrom(TempXmlDocText);
        BodyRequestMessage.Content(contentHttpContent);

    end;

    local procedure GetModuleInfoData(ResponseMessage: HttpResponseMessage; Var XTLUrl: Text; Var Solution: Text): Boolean;
    var
        TempBlob: Codeunit "Temp Blob";
        ResponseContent: HttpContent;
        XMLDocOut: XmlDocument;
        ModuleXMLNodeList: XmlNodeList;
        ModuleXMLNodeCount: Integer;
        ModuleIdXMLNode: XmlNode;
        ResultXMLNode: XmlNode;
        DataXMLAttributeCollection: XMLAttributeCollection;
        DataXmlAttribute: XmlAttribute;
        AttribCounter: Integer;
        ResponseInStr: InStream;
        XPath: Text;
        XResultPath: Text;
        ModuleName: Text;
        Erp: Text;
        Result: Text;
        ResultText: Text;
    begin

        TempBlob.CreateInStream(ResponseInStr);
        ResponseContent := ResponseMessage.Content();
        ResponseContent.ReadAs(ResponseInStr);
        XmlDocument.ReadFrom(ResponseInStr, XMLDocOut);

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
                            ResultText += '\' + DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'url') then
                            ResultText += '\' + DataXmlAttribute.Value();
                    end;
                end;
            end;
            error(ResultText)
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

                        if (DataXmlAttribute.Name() = 'solution') then
                            Solution := DataXmlAttribute.Value();

                        if (DataXmlAttribute.Name() = 'erp') then
                            Erp := DataXmlAttribute.Value();
                    end;
                end;
                if ((LowerCase(ModuleName) = LowerCase('AMC-Banking')) and
                    (LowerCase(Erp) = LowerCase('Dyn. NAV'))) then
                    exit(true)
                else begin
                    ModuleName := '';
                    XTLUrl := '';
                    Solution := AMCBankServMgt.GetDemoSolutionCode();
                    Erp := '';
                end;
            end;

        exit(false);
    end;

    local procedure PrepareSOAPRequestBodyDataExchangeDef(var TempBlobBody: Codeunit "Temp Blob"; ApplVersion: Text; BuildNumber: Text);
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        BodyContentInputStream: InStream;
        BodyContentOutputStream: OutStream;
        BodyContentXmlDoc: DotNet XmlDocument;
        OperationXmlNode: DotNet XmlNode;
        ElementXmlNode: DotNet XmlNode;
    begin
        TempBlobBody.CreateInStream(BodyContentInputStream);
        BodyContentXmlDoc := BodyContentXmlDoc.XmlDocument();

        XMLDOMMgt.AddRootElementWithPrefix(BodyContentXmlDoc, 'dataExchange', '', AMCBankServMgt.GetNamespace(), OperationXmlNode);
        if (ApplVersion <> '') then begin
            XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'appl', ApplVersion, '', '', ElementXmlNode);
            XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'build', BuildNumber, '', '', ElementXmlNode);
        end
        else begin
            XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'appl', GetApplVersion(), '', '', ElementXmlNode);
            XMLDOMMgt.AddElementWithPrefix(OperationXmlNode, 'build', GetBuildNumber(), '', '', ElementXmlNode);
        end;

        Clear(TempBlobBody);
        TempBlobBody.CreateOutStream(BodyContentOutputStream);
        BodyContentXmlDoc.Save(BodyContentOutputStream);
    end;

    local procedure GetDataExchangeData(TempBlob: Codeunit "Temp Blob"; DataExchDefFilter: Text): Boolean;
    var
        TempBlobData: Codeunit "Temp Blob";
        XMLDOMMgt: Codeunit "XML DOM Management";
        Base64Convert: Codeunit "Base64 Convert";
        XMLDocOut: DotNet XmlDocument;
        DataExchXMLNodeList: DotNet XmlNodeList;
        DataExchXMLNodeCount: Integer;
        InStreamData: InStream;
        Base64OutStreamData: OutStream;
        XPath: Text;
        Found: Boolean;
        ChildCounter: Integer;
        ChildNode: DotNet XmlNode;

        DataExchDefCode: Code[20];
        Base64String: Text;
    begin
        TempBlob.CreateInStream(InStreamData);
        XMLDOMMgt.LoadXMLDocumentFromInStream(InStreamData, XMLDocOut);

        XPath := '/amc:dataExchangeResponse/return/pack';

        Found := XMLDOMMgt.FindNodesWithNamespace(XMLDocOut.DocumentElement(), XPath, 'amc', AMCBankServMgt.GetNamespace(), DataExchXMLNodeList);
        if not Found then
            exit(false);

        IF DataExchXMLNodeList.Count() > 0 THEN
            FOR DataExchXMLNodeCount := 0 TO DataExchXMLNodeList.Count() DO
                if not IsNull(DataExchXMLNodeList.Item(DataExchXMLNodeCount)) then
                    if DataExchXMLNodeList.Item(DataExchXMLNodeCount).HasChildNodes() then begin
                        CLEAR(DataExchDefCode);
                        CLEAR(TempBlobData);
                        for ChildCounter := 0 to DataExchXMLNodeList.Item(DataExchXMLNodeCount).ChildNodes().Count() - 1 do begin
                            ChildNode := DataExchXMLNodeList.Item(DataExchXMLNodeCount).ChildNodes().Item(ChildCounter);
                            case ChildNode.Name() of
                                'type':
                                    EVALUATE(DataExchDefCode, COPYSTR(ChildNode.InnerText(), 1, 20));
                                'data':
                                    begin
                                        Base64String := ChildNode.InnerText();
                                        TempBlobData.CreateOutStream(Base64OutStreamData);
                                        Base64Convert.FromBase64(Base64String, Base64OutStreamData);
                                    end;
                            end;
                        end;
                        //READ DATA INTO TempBlobData
                        if ((TempBlobData.HasValue()) and (DataExchDefCode <> '') and
                            (StrPos(DataExchDefFilter, DataExchDefCode) <> 0)) then
                            ImportDataExchDef(DataExchDefCode, TempBlobData);
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
            AMCBankServMgt.GetDataExchDef_CT():
                WITH BankExportImportSetup DO BEGIN
                    INIT();
                    Code := DataExchDefCode;
                    Name := DefName;
                    Direction := BankExportImportSetup.Direction::Export;
                    "Processing Codeunit ID" := CODEUNIT::"AMC Bank Exp. CT Launcher";
                    "Processing XMLport ID" := 0;
                    "Check Export Codeunit" := 0;
                    "Preserve Non-Latin Characters" := TRUE;
                    "Data Exch. Def. Code" := AMCBankServMgt.GetDataExchDef_CT();
                    BankExportImportSetup.Insert();
                END;
            AMCBankServMgt.GetDataExchDef_STMT():
                WITH BankExportImportSetup DO BEGIN
                    INIT();
                    Code := DataExchDefCode;
                    Name := DefName;
                    Direction := BankExportImportSetup.Direction::Import;
                    "Processing Codeunit ID" := CODEUNIT::"AMC Bank Exp. CT Launcher";
                    "Processing XMLport ID" := 0;
                    "Check Export Codeunit" := 0;
                    "Preserve Non-Latin Characters" := TRUE;
                    "Data Exch. Def. Code" := AMCBankServMgt.GetDataExchDef_STMT();
                    BankExportImportSetup.Insert();
                END;
        END
    end;

    local procedure GetDataExchResponseNodeTxt(): Text;
    begin
        exit(DataExchResponseNodeTxt);
    end;

    local procedure CheckIfErrorsOccurred(var ResponseInStream: InStream)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ResponseXmlDoc: DotNet XmlDocument;
    begin
        XMLDOMManagement.LoadXMLDocumentFromInStream(ResponseInStream, ResponseXmlDoc);

        if ResponseHasErrors(ResponseXmlDoc) then
            DisplayErrorFromResponse(ResponseXmlDoc);
    end;

    local procedure ResponseHasErrors(ResponseXmlDoc: DotNet XmlDocument): Boolean
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XmlNode: DotNet XmlNode;
    begin
        exit(XMLDOMMgt.FindNodeWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetErrorXPath(GLBResponsePath), 'amc', AMCBankServMgt.GetNamespace(), XmlNode));
    end;

    local procedure DisplayErrorFromResponse(ResponseXmlDoc: DotNet XmlDocument)
    var
        XMLDOMMgt: Codeunit "XML DOM Management";
        XMLNodeList: DotNet XmlNodeList;
        Found: Boolean;
        ErrorText: Text;
        i: Integer;
    begin
        Found := XMLDOMMgt.FindNodesWithNamespace(ResponseXmlDoc.DocumentElement(),
            AMCBankServMgt.GetErrorXPath(GLBResponsePath), 'amc', AMCBankServMgt.GetNamespace(), XMLNodeList);
        if Found then begin
            ErrorText := TryLoadErrorLbl;
            for i := 1 to XMLNodeList.Count() do
                ErrorText += '\\' + XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'text') + '\' +
                  XMLDOMMgt.FindNodeText(XMLNodeList.Item(i - 1), 'hinttext') + '\\' +
                  StrSubstNo(AddnlInfoTxt, AMCBankServMgt.GetSupportURL(XMLNodeList.Item(i - 1)));

            Error(ErrorText);
        end;
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

    [IntegrationEvent(false, false)]
    //To update extra things that standard does not.
    procedure OnAfterRunBasisSetup(UpdURL: Boolean; URLSChanged: Boolean; SignupURL: Text[250]; ServiceURL: Text[250]; SupportURL: Text[250];
                                   UpdBank: Boolean; UpdPayMeth: Boolean; CountryCode: Code[10];
                                   UpdDataExchDef: Boolean; UpdCreditTransfer: Boolean; UpdPositivePay: Boolean; UpdateStatementImport: Boolean;
                                   UpdCreditAdvice: Boolean; ApplVer: Text; BuildNo: Text;
                                   UpdBankClearStd: Boolean; UpdBankAccounts: Boolean; CallLicenseServer: Boolean)
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
        if (BankExportImportSetup.Get(DataExchDefCode)) then
            if (BankExportImportSetup."Processing Codeunit ID" = Codeunit::"AMC Bank Upg. Notification") then
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

    local procedure CallDemoSolutionNotification(NotificationId: GUID)
    var
        Notification: Notification;
    begin

        Notification.Id := NotificationId;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Message := DemoSolutionNotificationTxt;
        Notification.AddAction(DemoSolutionNotificationActionTxt, Codeunit::"AMC Bank Assisted Mgt.", 'DisplayAMCBankSetup');
        Notification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"AMC Banking Setup", 'OnOpenPageEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationAMCBankingSetup(var rec: Record "AMC Banking Setup")
    var

    begin
        if (UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_CT()) or
            UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_STMT())) then
            CallAssistedSetupNotification(rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"AMC Bank Bank Name List", 'OnOpenPageEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationAMCBankBanks(var rec: Record "AMC Bank Banks")
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.get();
        if (UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_CT()) or
            UpgradeNotificationIsNeeded(AMCBankServMgt.GetDataExchDef_STMT())) then
            CallAssistedSetupNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Journal", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPaymentJournal(var Rec: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name")) then
            if (GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account") then
                if (BankAccount.get(GenJournalBatch."Bal. Account No.")) then
                    if (UpgradeNotificationIsNeeded(BankAccount."Payment Export Format")) then begin
                        CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Payment Export Format"));
                        exit;
                    end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (GenJournalBatch.Get(Rec."Journal Template Name", rec."Journal Batch Name")) then
                if (GenJournalBatch."Bal. Account Type" = GenJournalBatch."Bal. Account Type"::"Bank Account") then
                    if (BankAccount.get(GenJournalBatch."Bal. Account No.")) then
                        if ((BankAccount."Payment Export Format" = AMCBankServMgt.GetDataExchDef_CT()) and
                           (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                            CallDemoSolutionNotification(GetBankExportNotificationId(BankAccount."Payment Export Format"));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Pmt. Reconciliation Journals", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPmtReconJours(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                    (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;


    [EventSubscriber(ObjectType::Page, Page::"Payment Reconciliation Journal", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationPaymntReconJour(var Rec: Record "Bank Acc. Reconciliation Line")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;
        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Payment Export Format" = AMCBankServMgt.GetDataExchDef_CT()) or
                   (BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                   (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Acc. Reconciliation List", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankAccReconList(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Payment Export Format" = AMCBankServMgt.GetDataExchDef_CT()) or
                   (BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                   (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Acc. Reconciliation", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankAccRecon(var Rec: Record "Bank Acc. Reconciliation")
    var
        BankAccount: Record "Bank Account";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (BankAccount.get(rec."Bank Account No.")) then
            if (UpgradeNotificationIsNeeded(BankAccount."Bank Statement Import Format")) then begin
                CallAssistedSetupNotification(GetBankExportNotificationId(BankAccount."Bank Statement Import Format"));
                exit;
            end;

        //Show notification if AMC Banking service is demo solution
        if (AMCBankingSetup.Get()) then
            if (BankAccount.get(rec."Bank Account No.")) then
                if ((BankAccount."Payment Export Format" = AMCBankServMgt.GetDataExchDef_CT()) or
                   (BankAccount."Bank Statement Import Format" = AMCBankServMgt.GetDataExchDef_STMT()) and
                   (AMCBankingSetup.Solution = AMCBankServMgt.GetDemoSolutionCode())) then
                    CallDemoSolutionNotification(AMCBankingSetup.SystemId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Export/Import Setup", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure ShowAssistedSetupNotificationBankExportImportSetup(var Rec: Record "Bank Export/Import Setup")
    var
    begin
        //Show notification if Assisted setup has to run after upgrade
        if (UpgradeNotificationIsNeeded(Rec.Code)) then
            CallAssistedSetupNotification(Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        AmcBankingSetup: Record "AMC Banking Setup";
        BaseAppID: Codeunit "BaseApp ID";
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(BaseAppID.Get(), Page::"AMC Bank Assisted Setup", AssistedSetupTxt, AssistedSetupGroup::Uncategorized);
        if AmcBankingSetup.Get() then
            AssistedSetup.Complete(BaseAppID.Get(), Page::"AMC Bank Assisted Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnAfterRun', '', true, true)]
    local procedure UpdateAssistedSetupStatus(ExtensionID: Guid; PageID: Integer)
    var
        AmcBankingSetup: Record "AMC Banking Setup";
        AssistedSetup: Codeunit "Assisted Setup";
        BaseAppID: Codeunit "BaseApp ID";
    begin
        if ExtensionId <> BaseAppID.Get() then
            exit;
        if PageID <> Page::"AMC Bank Assisted Setup" then
            exit;
        if AmcBankingSetup.Get() then
            AssistedSetup.Complete(ExtensionID, PageID);
    end;
}
