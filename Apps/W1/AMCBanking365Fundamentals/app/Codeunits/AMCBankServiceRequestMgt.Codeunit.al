codeunit 20118 "AMC Bank Service Request Mgt."
{
    //new procedure for handling http call - as we can't use Codeunit 1290, as functions are missing
    var
        GlobalProgressDialogEnabled: Boolean;
        GLBEnableErrorException: Boolean;
        GLBHeadersClientHttp: HttpHeaders;
        GLBHeadersContentHttp: HttpHeaders;
        GLBResponseErrorText: Text;
        GlobalTimeout: Integer;
        GLBFromId: Integer;
        GLBToId: Integer;
        TryLoadErrorLbl: Label 'The web service returned an error message:\';
        WebLoadErrorLbl: Label 'Status code: %1', Comment = '%1=Http Statuscode';
        ExpectedResponseNotReceivedErrLbl: Label 'The expected data was not received from the web service.';
        ProcessingWindowMsg: Label 'Please wait while the server is processing your request.\This may take several minutes.';
        ContentTypeTxt: Label 'text/xml; charset=utf-8', Locked = true;
        FinstaPathTxt: Label '//return/finsta/statement/finstatransus', Locked = true;
        SysErrPathTxt: Label '//return/syslog[syslogtype[text()="error"]]', Locked = true;
        ConvErrPathTxt: Label '//return/pack/convertlog[syslogtype[text()="error"]]', Locked = true;
        DataPathTxt: Label '//return/pack/data', Locked = true;
        BankPathTxt: Label '//return/pack/bank', Locked = true;
        PackPathTxt: Label '//return/pack', Locked = true;

    procedure CreateEnvelope(VAR requestDocXML: XmlDocument; VAR EnvXmlElement: XmlElement; Username: Text; Password: Text; UsernameTokenValue: Text);
    var
        HeaderXMLElement: XmlElement;
        SecurityXMLElement: XmlElement;
        TokenXMLElement: XmlElement;
        TokenChildXMLElement: XmlElement;
    begin

        EnvXmlElement := XMLElement.Create('Envelope', GetSoapEnvelopeNamespaceTxt());
        requestDocXML.Add(EnvXmlElement);

        AddElement(EnvXmlElement, EnvXmlElement.NamespaceUri(), 'Header', '', HeaderXMLElement, '', '', '');
        AddElement(HeaderXMLElement, GetWSSSecurityNamespaceUri(), 'Security', '', SecurityXMLElement, '', '', '');
        if (UsernameTokenValue <> '') then
            AddElement(SecurityXMLElement, SecurityXMLElement.NamespaceUri(), 'UsernameToken', '', TokenXMLElement, 'Id', GetWSSSecurityUtilityNamespaceUri(), UsernameTokenValue)
        else
            AddElement(SecurityXMLElement, SecurityXMLElement.NamespaceUri(), 'UsernameToken', '', TokenXMLElement, 'Id', GetWSSSecurityUtilityNamespaceUri(), GetUsernameTokenFixedValue());

        AddElement(TokenXMLElement, SecurityXMLElement.NamespaceUri(), 'Username', Username, TokenChildXMLElement, '', '', '');
        AddElement(TokenXMLElement, SecurityXMLElement.NamespaceUri(), 'Password', Password, TokenChildXMLElement, 'Type', '', GetWSSUsernameTokenNamespaceUri());

    end;

    procedure AddElement(VAR ParentElement: XmlElement; NameSpace: Text; ElementName: Text; ElementValue: Text; VAR CreatedChildElement: XmlElement; AttribName: Text; AttribNameSpace: Text; AttribValue: Text)
    var
    begin
        CLEAR(CreatedChildElement);
        if (ElementValue <> '') then
            CreatedChildElement := XMLElement.Create(ElementName, NameSpace, ElementValue)
        else
            CreatedChildElement := XMLElement.Create(ElementName, NameSpace);

        if (AttribName <> '') then
            if (AttribNameSpace <> '') then
                CreatedChildElement.SetAttribute(AttribName, AttribNameSpace, AttribValue)
            else
                CreatedChildElement.SetAttribute(AttribName, AttribValue);

        ParentElement.Add(CreatedChildElement);
    end;

    local procedure disposeGLBHttpVariable();
    begin
        GLBHeadersClientHttp.Clear();
        GLBHeadersContentHttp.Clear();
        CLEAR(GLBResponseErrorText);
        CLEAR(GLBFromId);
        CLEAR(GLBToId);
    end;

    procedure SetTimeout(NewTimeout: Integer)
    begin
        GlobalTimeout := NewTimeout;
    end;

    procedure DisableProgressDialog()
    begin
        GlobalProgressDialogEnabled := false;
    end;

    procedure InitializeHttp(Var InitRequestMessage: HttpRequestMessage; URL: Text; MessageMethod: Text[6]);
    begin
        disposeGLBHttpVariable();
        GlobalProgressDialogEnabled := true;
        InitRequestMessage.Method(MessageMethod);
        InitRequestMessage.SetRequestUri(URL);
        InitRequestMessage.GetHeaders(GLBHeadersClientHttp);
        SetHttpClientDefaults();
    end;

    local procedure SetHttpClientDefaults();
    var
    begin
        if (GLBHeadersClientHttp.Contains('Accept')) THEN
            GLBHeadersClientHttp.Remove('Accept');

        GLBHeadersClientHttp.Add('Accept', ContentTypeTxt);
    end;

    procedure SetHttpContentsDefaults(Var HeaderRequestMessage: HttpRequestMessage);
    var
    begin
        HeaderRequestMessage.Content().GetHeaders(GLBHeadersContentHttp);

        if (GLBHeadersContentHttp.Contains('Content-Type')) THEN
            GLBHeadersContentHttp.Remove('Content-Type');

        GLBHeadersContentHttp.Add('Content-Type', ContentTypeTxt);

        AddAMCSpecificHttpHeaders(HeaderRequestMessage, GLBHeadersContentHttp);

    end;

    local procedure AddAMCSpecificHttpHeaders(RequestMessage: HttpRequestMessage; var RequestHttpHeaders: HttpHeaders)
    var
        User: Record User;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        AMCName: Text;
        AMCEmail: Text;
        AMCGUID: GUID;
        ContentOutStream: OutStream;
        ContentInStream: InStream;
    begin
        AMCGUID := DelChr(LowerCase(Format(UserSecurityId())), '=', '{}');
        User.SetRange("User Security ID", UserSecurityId());
        if (User.FindFirst()) then begin
            if (User."Full Name" <> '') then
                AMCName := User."Full Name"
            else
                AMCName := User."User Name";

            if (User."Authentication Email" <> '') then
                AMCEmail := User."Authentication Email"
            else
                AMCEmail := User."Contact Email";
        end;

        RequestMessage.Content().GetHeaders(RequestHttpHeaders);

        if (RequestHttpHeaders.Contains('Amcname')) THEN
            RequestHttpHeaders.Remove('Amcname');

        Clear(TempBlob);
        Clear(ContentOutStream);
        Clear(ContentInStream);
        TempBlob.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(AMCName);
        TempBlob.CreateInStream(ContentInStream);
        RequestHttpHeaders.Add('Amcname', Base64Convert.ToBase64(ContentInStream));

        if (RequestHttpHeaders.Contains('Amcemail')) THEN
            RequestHttpHeaders.Remove('Amcemail');

        Clear(TempBlob);
        Clear(ContentOutStream);
        Clear(ContentInStream);
        TempBlob.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(AMCEmail);
        TempBlob.CreateInStream(ContentInStream);
        RequestHttpHeaders.Add('Amcemail', Base64Convert.ToBase64(ContentInStream));

        if (RequestHttpHeaders.Contains('Amcguid')) THEN
            RequestHttpHeaders.Remove('Amcguid');

        RequestHttpHeaders.Add('Amcguid', AMCGUID);

    end;

    procedure ExecuteWebServiceRequest(Var Handled: Boolean; Var WebRequestMessage: HttpRequestMessage; Var ResponseMessage: HttpResponseMessage; webCall: Text; AppCaller: text[30]; CheckHttpStatus: Boolean): Boolean;
    var
        ClientHttp: HttpClient;
        RequestHttpContent: HttpContent;
        ProcessingWindow: Dialog;
    begin
        if (Handled) then //Only used for mockup for testautomation
            exit(true);

        if GlobalProgressDialogEnabled then
            ProcessingWindow.Open(ProcessingWindowMsg);

        RequestHttpContent := WebRequestMessage.Content();
        LogHttpActivity(webCall, AppCaller, 'Send', '', '', RequestHttpContent, 'ok');
        if GlobalTimeout <= 0 then
            GlobalTimeout := 600000;
        ClientHttp.Send(WebRequestMessage, ResponseMessage);

        if GlobalProgressDialogEnabled then
            ProcessingWindow.Close();

        if (CheckHttpStatus) then
            exit(CheckHttpCallStatus(webCall, AppCaller, ResponseMessage))
        else
            exit(true);
    end;

    procedure CheckHttpCallStatus(webCall: Text; AppCaller: text[30]; Var ResponseMessage: HttpResponseMessage): Boolean;
    var
        Error_Text: Text;
    begin
        if (NOT ResponseMessage.IsSuccessStatusCode()) then begin
            Error_Text := TryLoadErrorLbl + StrSubstNo(WebLoadErrorLbl, FORMAT(ResponseMessage.HttpStatusCode()) + ' ' + ResponseMessage.ReasonPhrase());
            LogHttpActivity(webCall, AppCaller, Error_Text, '', '', ResponseMessage.Content(), 'error');
            ERROR(Error_Text);
        end;
        exit(TRUE);
    end;

    procedure GetWebServiceResponse(Var ResponseMessage: HttpResponseMessage; Var ResponseTempBlob: Codeunit "Temp Blob"; responseXPath: Text; useNamespaces: Boolean)
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        TempBlob: Codeunit "Temp Blob";
        ResponseXMLDoc: XmlDocument;
        RootXmlElement: XmlElement;
        RootXmlNode: XmlNode;
        ResponseBodyXMLNode: XmlNode;
        NameSpaceMgt: XmlNamespaceManager;
        ResponseInStr: InStream;
        ResponseOutStr: OutStream;
        ResponseContent: HttpContent;
        TempXmlDocText: Text;
        Found: Boolean;
    begin

        CLEAR(TempBlob);
        TempBlob.CREATEINSTREAM(ResponseInStr);
        ResponseContent := ResponseMessage.Content();
        ResponseContent.ReadAs(ResponseInStr);
        XmlDocument.ReadFrom(ResponseInStr, ResponseXMLDoc);

        ResponseXMLDoc.WriteTo(TempXmlDocText);
        RemoveUTF16(TempXmlDocText);
        XmlDocument.ReadFrom(TempXmlDocText, ResponseXMLDoc);

        if (useNamespaces) then begin
            Found := ResponseXMLDoc.GetRoot(RootXmlElement);

            if (Found) then begin
                found := false;
                RootXmlNode := RootXmlElement.AsXmlNode();
                RootXmlNode.GetDocument(ResponseXMLDoc);
                NameSpaceMgt.NameTable(ResponseXMLDoc.NameTable());
                NameSpaceMgt.AddNamespace('amc', AMCBankingMgt.GetNamespace());
                found := RootXmlNode.SelectSingleNode('//amc:' + responseXPath, NameSpaceMgt, ResponseBodyXMLNode);
            end;

            IF NOT Found THEN
                ERROR(ExpectedResponseNotReceivedErrLbl);

            ResponseXMLDoc.RemoveNodes();
            ResponseXMLDoc.AddFirst(ResponseBodyXMLNode);
        end;

        CLEAR(ResponseTempBlob);
        CLEAR(ResponseInStr);
        ResponseTempBlob.CreateOutStream(ResponseOutStr);
        ResponseXMLDoc.WriteTo(ResponseOutStr);
    end;

    procedure RemoveUTF16(var XmlDocText: Text)
    var
        EncodPos: Integer;
    begin
        //XmlDeclaration DOES NOT WORK Github #630
        //This why we string replace utf-16
        EncodPos := StrPos(XmlDocText, 'utf-16');
        if (EncodPos > 0) THEN BEGIN
            XmlDocText := DelStr(XmlDocText, EncodPos, STRLEN('utf-16'));
            XmlDocText := InsStr(XmlDocText, 'utf-8', EncodPos);
        END;

        //XmlDeclaration DOES NOT WORK Github #630
        //This why we string replace UTF-16
        EncodPos := StrPos(XmlDocText, 'UTF-16');
        if (EncodPos > 0) THEN BEGIN
            XmlDocText := DelStr(XmlDocText, EncodPos, STRLEN('UTF-16'));
            XmlDocText := InsStr(XmlDocText, 'utf-8', EncodPos);
        END;

        //XmlDeclaration DOES NOT WORK
        //Xtllink can not parse ' standalone="No"'
        EncodPos := StrPos(XmlDocText, ' standalone="No"');
        if (EncodPos > 0) THEN
            XmlDocText := DelStr(XmlDocText, EncodPos, STRLEN(' standalone="No"'));
    end;

    procedure LogHttpActivity(SoapCall: Text; AppCaller: Text[30]; LogMessage: Text; HintText: Text; SupportUrl: Text; HttpLogContent: HttpContent; ResponseResult: Text) Id: Integer;
    var
        AMCBankingSetup: record "AMC Banking Setup";
        ActivityLog: Record "Activity Log";
        SubActivityLog: Record "Activity Log";
        TempBlob: CodeUnit "Temp Blob";
        RecordVariant: Variant;
        AMCBankWebLogStatus: Enum AMCBankWebLogStatus;
        LogInStream: InStream;
    begin
        AMCBankWebLogStatus := SetWeblogStatus(ResponseResult);
        AMCBankingSetup.Get();
        RecordVariant := AMCBankingSetup;

        if (AMCBankWebLogStatus = AMCBankWebLogStatus::Failed) then
            ActivityLog.LogActivity(RecordVariant, ActivityLog.Status::Failed, AppCaller, SoapCall, LogMessage)
        else
            ActivityLog.LogActivity(RecordVariant, ActivityLog.Status::Success, AppCaller, SoapCall, LogMessage);
        TempBlob.CreateInStream(LogInStream);
        CleanSecureContent(HttpLogContent, LogInStream);
        ActivityLog.SetDetailedInfoFromStream(LogInStream);
        ActivityLog."AMC Bank WebLog Status" := SetWeblogStatus(ResponseResult);
        ActivityLog.Modify();
        COMMIT();
        IF ((HintText <> '') OR (SupportUrl <> '')) THEN BEGIN
            if (AMCBankWebLogStatus = AMCBankWebLogStatus::Failed) then
                SubActivityLog.LogActivity(ActivityLog, SubActivityLog.Status::Failed, AppCaller, HintText, SupportUrl)
            else
                SubActivityLog.LogActivity(ActivityLog, SubActivityLog.Status::Success, AppCaller, HintText, SupportUrl);

            SubActivityLog."AMC Bank WebLog Status" := AMCBankWebLogStatus;
            SubActivityLog.Modify();
            COMMIT();
        END;

        EXIT(ActivityLog.ID);
    end;

    local procedure SetWeblogStatus(reponseResult: Text): ENUM AMCBankWebLogStatus
    begin
        CASE lowerCase(reponseResult) OF
            'ok':
                exit(AMCBankWebLogStatus::Success);
            'warning':
                exit(AMCBankWebLogStatus::Warning);
            'error':
                exit(AMCBankWebLogStatus::Failed);
        END;
        exit(AMCBankWebLogStatus::Failed);
    end;

    local procedure CleanSecureContent(HttpLogContent: HttpContent; var LogInStream: Instream);
    var
        TempBlob: CodeUnit "Temp Blob";
        LogXMLDoc: XmlDocument;
        LogXmlNodeList: XmlNodeList;
        DataXmlNode: XmlNode;
        ParentXmlElement: XmlElement;
        baseHttpContent: HttpContent;
        CleanInStream: InStream;
        DataXMLAttributeCollection: XMLAttributeCollection;
        DataXmlAttribute: XmlAttribute;
        AttribCounter: Integer;
        LogCounter: Integer;
        LogText: Text;
    begin
        TempBlob.CreateInStream(CleanInStream);
        HttpLogContent.ReadAs(CleanInStream);
        XmlDocument.ReadFrom(CleanInStream, LogXMLDoc);

        LogXmlNodeList := LogXMLDoc.GetDescendantNodes();
        IF LogXmlNodeList.Count() > 0 THEN
            FOR LogCounter := 1 TO LogXmlNodeList.Count() DO BEGIN
                LogXmlNodeList.Get(LogCounter, DataXmlNode);
                if (DataXmlNode.GetParent(ParentXmlElement)) then
                    if ((DataXmlNode.IsXmlText()) or (DataXmlNode.IsXmlCData())) then
                        if ((LowerCase(ParentXmlElement.LocalName()) = 'password') or
                            (LowerCase(ParentXmlElement.LocalName()) = 'signcode')) then begin
                            if (DataXmlNode.IsXmlText()) then
                                DataXmlNode.AsXmlText().Value('**********');

                            if (DataXmlNode.IsXmlCData()) then
                                DataXmlNode.AsXmlCData().Value('**********');
                        end;
            end;

        //Also clean License call, first the send request
        LogCounter := 0;
        LogXMLDoc.selectNodes('amcwebservice//function', LogXmlNodeList);
        FOR LogCounter := 1 TO LogXmlNodeList.Count() DO BEGIN
            LogXmlNodeList.Get(LogCounter, DataXmlNode);
            if (DataXmlNode.AsXmlElement().HasAttributes()) then begin
                DataXMLAttributeCollection := DataXmlNode.AsXmlElement().Attributes();
                for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                    DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                    if (LowerCase(DataXmlAttribute.Name()) = 'password') then
                        DataXmlAttribute.Value('**********')
                end;
            end;
        end;
        //Also clean License call, second the response request
        LogCounter := 0;
        LogXMLDoc.selectNodes('amcwebservice//functionfeedback/body/package/sysusertable', LogXmlNodeList);
        FOR LogCounter := 1 TO LogXmlNodeList.Count() DO BEGIN
            LogXmlNodeList.Get(LogCounter, DataXmlNode);
            if (DataXmlNode.AsXmlElement().HasAttributes()) then begin
                DataXMLAttributeCollection := DataXmlNode.AsXmlElement().Attributes();
                for AttribCounter := 1 to DataXMLAttributeCollection.Count() do begin
                    DataXMLAttributeCollection.Get(AttribCounter, DataXmlAttribute);
                    if (LowerCase(DataXmlAttribute.Name()) = 'password') then
                        DataXmlAttribute.Value('**********')
                end;
            end;
        end;

        LogXMLDoc.WriteTo(LogText);
        baseHttpContent.WriteFrom(LogText);
        baseHttpContent.ReadAs(LogInStream);

    end;

    procedure HasResponseErrors(ResponseTempBlob: Codeunit "Temp Blob"; HeadXPath: Text; SoapCallResponse: Text; Var ResponseResult: Text; AppCaller: Text[30]): Boolean;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ResponseInStream: InStream;
        ResponseHintText: Text;
        ResponseURL: Text;
        LogId: Integer;
        ResponseXMLDoc: XmlDocument;
        ResultXMLNodeList: XmlNodeList;
        ResultXMLNodeCount: Integer;
        ResultXmlNode: XmlNode;
        SysLogXMLNodeList: XmlNodeList;
        SysLogXMLNodeCount: Integer;
        SyslogXmlNode: XmlNode;
        ConvertLogXMLNodeList: XmlNodeList;
        ConvertLogXMLNodeCount: Integer;
        ConvertlogXmlNode: XmlNode;
        HttpContents: HttpContent;
        FoundSyslog: Boolean;
    begin
        //Get result of call
        AMCBankingSetup.GET();

        ResponseTempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, ResponseXMLDoc);

        ResponseXMLDoc.SelectNodes(STRSUBSTNO(HeadXPath, SoapCallResponse), ResultXMLNodeList);
        FOR ResultXMLNodeCount := 1 TO ResultXMLNodeList.Count() DO BEGIN
            ResultXMLNodeList.Get(ResultXMLNodeCount, ResultXmlNode);
            ResponseResult := COPYSTR(GetNodeValue(ResultXmlNode, GetResultXPath()), 1, 50);
        END;

        IF (ResponseResult <> 'ok') THEN BEGIN
            ResponseXMLDoc.SelectNodes(STRSUBSTNO(GetSyslogXPath(), SoapCallResponse), SysLogXMLNodeList);
            FOR SysLogXMLNodeCount := 1 TO SysLogXMLNodeList.Count() DO BEGIN
                FoundSyslog := true;
                SysLogXMLNodeList.Get(SysLogXMLNodeCount, SyslogXmlNode);

                GLBResponseErrorText := COPYSTR(GetNodeValue(SyslogXmlNode, GetSyslogTextXPath()), 1, 50);
                ResponseHintText := COPYSTR(GetNodeValue(SyslogXmlNode, GetSyslogHintTextXPath()), 1, 50);
                ResponseURL := COPYSTR(GetNodeValue(SyslogXmlNode, GetSyslogUrlXPath()), 1, 50);
                HttpContents.WriteFrom(ResponseInStream);
                LogId := LogHttpActivity(SoapCallResponse, AppCaller, GLBResponseErrorText, ResponseHintText, ResponseURL, HttpContents, ResponseResult);

                IF (GLBFromId = 0) THEN BEGIN
                    GLBFromId := LogId;
                    GLBToId := LogId;
                END
                ELSE
                    GLBToId := LogId;
            END;
            if (not FoundSyslog) then begin //Look for convertlog if Syslog does not exists
                ResponseXMLDoc.SelectNodes(STRSUBSTNO(GetConvertlogXPath(), SoapCallResponse), ConvertLogXMLNodeList);
                FOR ConvertLogXMLNodeCount := 1 TO ConvertLogXMLNodeList.Count() DO BEGIN
                    ConvertLogXMLNodeList.Get(ConvertLogXMLNodeCount, ConvertlogXmlNode);

                    GLBResponseErrorText := COPYSTR(GetNodeValue(ConvertlogXmlNode, GetSyslogTextXPath()), 1, 50);
                    ResponseHintText := COPYSTR(GetNodeValue(ConvertlogXmlNode, GetSyslogHintTextXPath()), 1, 50);
                    ResponseURL := COPYSTR(GetNodeValue(ConvertlogXmlNode, GetSyslogUrlXPath()), 1, 50);
                    HttpContents.WriteFrom(ResponseInStream);
                    LogId := LogHttpActivity(SoapCallResponse, AppCaller, GLBResponseErrorText, ResponseHintText, ResponseURL, HttpContents, ResponseResult);

                    IF (GLBFromId = 0) THEN BEGIN
                        GLBFromId := LogId;
                        GLBToId := LogId;
                    END
                    ELSE
                        GLBToId := LogId;
                END;
            end;

            IF (ResponseResult = 'error') THEN
                EXIT(TRUE)
            ELSE
                EXIT(FALSE);
        END
        ELSE begin
            HttpContents.WriteFrom(ResponseInStream);
            LogHttpActivity(SoapCallResponse, AppCaller, ResponseResult, '', '', HttpContents, ResponseResult);
        end;

        EXIT(FALSE);
    end;

    procedure ShowResponseError(ResponseResult: Text);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ActivityLog: Record "Activity Log";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        IF (ResponseResult <> 'ok') THEN BEGIN
            IF (GUIALLOWED()) THEN
                IF ((GLBFromId <> 0) OR (GLBToId <> 0)) THEN
                    IF DataTypeManagement.GetRecordRef(AMCBankingSetup, RecRef) THEN BEGIN
                        ActivityLog.SETRANGE(ActivityLog."Record ID", RecRef.RECORDID());
                        ActivityLog.SETRANGE(ActivityLog.ID, GLBFromId, GLBToId);
                        PAGE.RUN(PAGE::"AMC Bank Webcall Log", ActivityLog);
                    END;

            if (GLBEnableErrorException) then
                error(GLBResponseErrorText);
        END;
    end;


    procedure getNodeValue(ParentXmlNode: XmlNode; Xpath: Text): Text;
    var
        DataXmlNode: XmlNode;
        NodeValue: Text;
    begin
        if (ParentXmlNode.SelectSingleNode(Xpath + '/text()', DataXmlNode)) then begin
            if (DataXmlNode.IsXmlText()) then
                NodeValue := DataXmlNode.AsXmlText().Value();
            if (NodeValue <> '') then
                EXIT(DELCHR(NodeValue, '=', '"'))
            else
                EXIT('');
        end;
        EXIT('');
    end;

    internal procedure SetUsedXTLJournal(var TempBlob: Codeunit "Temp Blob"; DataExchEntryNo: Integer; PaymentExportWebCallTxt: Text)
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        ResponseInStream: InStream;
        DataXmlNode: XmlNode;
        ResponseXmlDoc: XmlDocument;
        Found: Boolean;
        XTLJournalNo: Text[250];
    begin
        TempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, ResponseXmlDoc);


        Found := ResponseXmlDoc.SelectSingleNode(STRSUBSTNO(GetJournalNoPath(PaymentExportWebCallTxt + GetResponseTag())), DataXmlNode);
        if (Found) then begin
            XTLJournalNo := CopyStr(getNodeValue(DataXmlNode, './journalnumber'), 1, 250);
            CreditTransferRegister.SetRange("Data Exch. Entry No.", DataExchEntryNo);
            if (CreditTransferRegister.FindLast()) then begin
                CreditTransferRegister."AMC Bank XTL Journal" := XTLJournalNo;
                CreditTransferRegister.Modify();
            end;
        end;

    end;

    internal procedure GetGlobalFromActivityId(): Integer
    begin
        exit(GLBFromId);
    end;

    internal procedure GetGlobalToActivityId(): Integer
    begin
        exit(GLBToId);
    end;

    procedure GetFinstaXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(FinstaPathTxt, ResponseNode));
    end;

    procedure GetSysErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(SysErrPathTxt, ResponseNode));
    end;

    procedure GetConvErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(ConvErrPathTxt, ResponseNode));
    end;

    procedure GetDataXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(DataPathTxt, ResponseNode));
    end;

    procedure GetBankXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(BankPathTxt, ResponseNode));
    end;


    procedure GetJournalNoPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(PackPathTxt, ResponseNode));
    end;


    procedure GetHeaderXPath(): Text;
    begin
        EXIT('//return/header');
    end;

    //Get result Xpath
    local procedure GetResultXPath(): Text;
    begin
        EXIT('./result');
    end;

    //Xpaths and tags for Syslog in each webcall
    procedure GetSyslogXPath(): Text;
    begin
        EXIT('//syslog');
    end;

    procedure GetResponseTag(): Text;
    begin
        EXIT('Response');
    end;

    procedure GetConvertlogXPath(): Text;
    begin
        EXIT('//pack/convertlog');
    end;

    local procedure GetSyslogReferenceIdXPath(): Text;
    begin
        EXIT('./referenceid');
    end;

    procedure GetSyslogTextXPath(): Text;
    begin
        EXIT('./text');
    end;

    procedure GetSyslogHintTextXPath(): Text;
    begin
        EXIT('./hinttext');
    end;

    local procedure GetSyslogUrlXPath(): Text;
    begin
        EXIT('./url');
    end;

    local procedure GetSoapEnvelopeNamespaceTxt(): Text;
    begin
        EXIT('http://www.w3.org/2003/05/soap-envelope');
    end;

    local procedure GetWSSSecurityNamespaceUri(): Text;
    begin
        EXIT('http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd');
    end;

    local procedure GetWSSSecurityUtilityNamespaceUri(): Text;
    begin
        EXIT('http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd');
    end;

    local procedure GetWSSUsernameTokenNamespaceUri(): Text;
    begin
        EXIT('http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText');
    end;

    local procedure GetUsernameTokenFixedValue(): Text;
    begin
        EXIT('UsernameToken-1');
    end;
}