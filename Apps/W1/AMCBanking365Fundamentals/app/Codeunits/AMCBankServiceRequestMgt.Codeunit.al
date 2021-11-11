codeunit 20118 "AMC Bank Service Request Mgt."
{
    //new procedure for handling http call - as we can't use Codeunit 1290, as functions are missing
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        GlobalProgressDialogEnabled: Boolean;
        GLBEnableErrorException: Boolean;
        GLBHeadersClientHttpClient: HttpHeaders;
        GLBHeadersContentHttp: HttpHeaders;
        GLBResponseErrorText: Text;
        GlobalTimeout: Integer;
        GLBFromId: Integer;
        GLBToId: Integer;
        TryLoadErrorLbl: Label 'The web service returned an error message:\';
        WebLoadErrorLbl: Label 'Status code: %1', Comment = '%1=Http Statuscode';
        ExpectedResponseNotReceivedErrLbl: Label 'The expected data was not received from the web service.';
        ProcessWindowDialogMsg: Label 'Please wait while the server is processing your request.\This may take several minutes.';
        ContentTypeTxt: Label 'text/xml; charset=utf-8', Locked = true;
        FinstaPathTxt: Label '//return/finsta/statement/finstatransus', Locked = true;
        SysErrPathTxt: Label '//return/syslog[syslogtype[text()="error"]]', Locked = true;
        ConvErrPathTxt: Label '//return/pack/convertlog[syslogtype[text()="error"]]', Locked = true;
        DataPathTxt: Label '//return/pack/data', Locked = true;
        BankPathTxt: Label '//return/pack/bank', Locked = true;
        PackPathTxt: Label '//return/pack', Locked = true;
        FeatureConsentErr: Label 'The AMC Banking 365 Fundamentals feature is not enabled. You can enable the feature on the AMC Banking Setup page by turning on the Enabled toggle, or by using the assisted setup guide.';

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
        GLBHeadersClientHttpClient.Clear();
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

    procedure InitializeHttp(Var InitHttpRequestMessage: HttpRequestMessage; URL: Text; MessageMethod: Text[6]);
    begin
        disposeGLBHttpVariable();
        GlobalProgressDialogEnabled := true;
        InitHttpRequestMessage.Method(MessageMethod);
        InitHttpRequestMessage.SetRequestUri(URL);
        InitHttpRequestMessage.GetHeaders(GLBHeadersClientHttpClient);
        SetHttpClientDefaults();
    end;

    local procedure SetHttpClientDefaults();
    var
    begin
        if (GLBHeadersClientHttpClient.Contains('Accept')) THEN
            GLBHeadersClientHttpClient.Remove('Accept');

        GLBHeadersClientHttpClient.Add('Accept', ContentTypeTxt);
    end;

    procedure SetHttpContentsDefaults(Var HeaderHttpRequestMessage: HttpRequestMessage);
    var
    begin
        HeaderHttpRequestMessage.Content().GetHeaders(GLBHeadersContentHttp);

        if (GLBHeadersContentHttp.Contains('Content-Type')) THEN
            GLBHeadersContentHttp.Remove('Content-Type');

        GLBHeadersContentHttp.Add('Content-Type', ContentTypeTxt);

        AddAMCSpecificHttpHeaders(HeaderHttpRequestMessage, GLBHeadersContentHttp);

    end;

    local procedure AddAMCSpecificHttpHeaders(HttpRequestMessage: HttpRequestMessage; var RequestHttpHeaders: HttpHeaders)
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

        HttpRequestMessage.Content().GetHeaders(RequestHttpHeaders);

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

    procedure ExecuteWebServiceRequest(Handled: Boolean; Var WebHttpRequestMessage: HttpRequestMessage; Var HttpResponseMessage: HttpResponseMessage; webCall: Text; AppCaller: text[30]; CheckHttpStatus: Boolean): Boolean;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ClientHttpClient: HttpClient;
        RequestHttpContent: HttpContent;
        ProcessWindowDialog: Dialog;
    begin
        if (Handled) then //Only used for mockup for testautomation
            exit(true);

        AMCBankingSetup.Get();
        if not AMCBankingSetup."AMC Enabled" then
            Error(FeatureConsentErr);

        if GlobalProgressDialogEnabled then
            ProcessWindowDialog.Open(ProcessWindowDialogMsg);

        RequestHttpContent := WebHttpRequestMessage.Content();
        LogHttpActivity(webCall, AppCaller, 'Send', '', '', RequestHttpContent, 'ok');
        if GlobalTimeout <= 0 then
            GlobalTimeout := 600000;
        ClientHttpClient.Send(WebHttpRequestMessage, HttpResponseMessage);

        if GlobalProgressDialogEnabled then
            ProcessWindowDialog.Close();

        if (CheckHttpStatus) then
            exit(CheckHttpCallStatus(webCall, AppCaller, HttpResponseMessage))
        else
            exit(true);
    end;

    procedure CheckHttpCallStatus(webCall: Text; AppCaller: text[30]; Var HttpResponseMessage: HttpResponseMessage): Boolean;
    var
        Error_Text: Text;
    begin
        if (NOT HttpResponseMessage.IsSuccessStatusCode()) then begin
            Error_Text := TryLoadErrorLbl + StrSubstNo(WebLoadErrorLbl, FORMAT(HttpResponseMessage.HttpStatusCode()) + ' ' + HttpResponseMessage.ReasonPhrase());
            LogHttpActivity(webCall, AppCaller, Error_Text, '', '', HttpResponseMessage.Content(), 'error');
            ERROR(Error_Text);
        end;
        exit(TRUE);
    end;

    procedure GetWebServiceResponse(Var HttpResponseMessage: HttpResponseMessage; Var ResponseTempBlob: Codeunit "Temp Blob"; responseXPath: Text; useNamespaces: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        ResponseXMLDoc: XmlDocument;
        RootXmlElement: XmlElement;
        RootXmlNode: XmlNode;
        ResponseBodyXMLNode: XmlNode;
        NameSpaceMgt: XmlNamespaceManager;
        ResponseInStream: InStream;
        ResponseOutStream: OutStream;
        ResponseHttpContent: HttpContent;
        TempXmlDocText: Text;
        Found: Boolean;
    begin

        CLEAR(TempBlob);
        TempBlob.CREATEINSTREAM(ResponseInStream);
        ResponseHttpContent := HttpResponseMessage.Content();
        ResponseHttpContent.ReadAs(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, ResponseXMLDoc);

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
        CLEAR(ResponseInStream);
        ResponseTempBlob.CreateOutStream(ResponseOutStream);
        ResponseXMLDoc.WriteTo(ResponseOutStream);
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

    procedure LogHttpActivity(SoapCall: Text; AppCaller: Text[30]; LogMessage: Text; HintText: Text; SupportUrl: Text; LogHttpContent: HttpContent; ResponseResult: Text) Id: Integer;
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
        CleanSecureContent(LogHttpContent, LogInStream);
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

    procedure ShowServiceLinkPage(ShowPage: Text; IgnoreError: Boolean): Boolean;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        TypeHelper: Codeunit "Type Helper";
        TokenId: Text;
    begin
        AMCBankingSetup.GET();
        TokenId := GetXTLToken(IgnoreError);
        HyperLink(STRSUBSTNO(GetTokenURLData(AMCBankingSetup."Service URL", ShowPage), TypeHelper.UrlEncode(TokenId)));
    end;

    local procedure GetXTLToken(IgnoreError: Boolean) TokenId: Text;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ResponseTempBlob: Codeunit "Temp Blob";
        ResponseInStream: InStream;
        ResponseXMLDoc: XmlDocument;
        Result: Text;
        TokenHttpRequestMessage: HttpRequestMessage;
        TokenHttpResponseMessage: HttpResponseMessage;
        TokenXMLNodeList: XmlNodeList;
        TokenXMLNodeCount: Integer;
        TokenIdXMLNode: XmlNode;
        Handled: Boolean;
    begin
        AMCBankingMgt.CheckCredentials();
        AMCBankingSetup.Get();

        TokenId := '';
        InitializeHttp(TokenHttpRequestMessage, AMCBankingSetup."Service URL", 'POST');
        PrepareSOAPRequestBodyTokenCreate(TokenHttpRequestMessage, GetTokenCreate());

        //Set Content-Type header
        SetHttpContentsDefaults(TokenHttpRequestMessage);

        OnBeforeExecuteWebServiceRequest(Handled, TokenHttpRequestMessage, TokenHttpResponseMessage, GetTokenCreate(), AMCBankingMgt.GetAppCaller()); //For mockup testing
        ExecuteWebServiceRequest(Handled, TokenHttpRequestMessage, TokenHttpResponseMessage, GetTokenCreate(), AMCBankingMgt.GetAppCaller(), true);
        GetWebServiceResponse(TokenHttpResponseMessage, ResponseTempBlob, GetTokenCreate() + GetResponseTag(), true);

        if (not HasResponseErrors(ResponseTempBlob, GetHeaderXPath(), GetTokenCreate() + GetResponseTag(), Result, AMCBankingMgt.GetAppCaller())) then begin
            ResponseTempBlob.CreateInStream(ResponseInStream);
            XmlDocument.ReadFrom(ResponseInStream, ResponseXmlDoc);

            ResponseXMLDoc.selectNodes(STRSUBSTNO(GetTokenIdXPath(), GetTokenCreate() + GetResponseTag()), TokenXMLNodeList);
            FOR TokenXMLNodeCount := 1 TO TokenXMLNodeList.Count() DO BEGIN
                TokenXMLNodeList.Get(TokenXMLNodeCount, TokenIdXMLNode);
                TokenId := COPYSTR(getNodeValue(TokenIdXMLNode, GetTokenXPath()), 1, 50);
            END;
        end
        else
            if (not IgnoreError) then
                ShowResponseError(Result);

        EXIT(TokenId);
    end;

    local procedure PrepareSOAPRequestBodyTokenCreate(var BodyHttpRequestMessage: HttpRequestMessage; soapCall: Text);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        User: Record User;
        ContentHttpContent: HttpContent;
        BodyContentXmlDoc: XmlDocument;
        BodyDeclaration: Xmldeclaration;
        EnvelopeXMLElement: XmlElement;
        BodyXMLElement: XMLElement;
        DataExchXmlElement: XmlElement;
        ChildXmlElement: XmlElement;
        TempXmlDocText: Text;
        AMCGUID: Text;
        AMCName: Text;
        AMCEmail: Text;
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

        BodyContentXmlDoc := XmlDocument.Create();
        BodyDeclaration := XmlDeclaration.Create('1.0', 'UTF-8', 'No');
        BodyContentXmlDoc.SetDeclaration(BodyDeclaration);

        AMCBankingSetup.Get();
        CreateEnvelope(BodyContentXmlDoc, EnvelopeXmlElement, AMCBankingSetup.GetUserName(), AMCBankingSetup.GetPassword(), '');

        AddElement(EnvelopeXMLElement, EnvelopeXMLElement.NamespaceUri(), 'Body', '', BodyXMLElement, '', '', '');
        AddElement(BodyXMLElement, AMCBankingMgt.GetNamespace(), soapCall, '', DataExchXmlElement, '', '', '');

        AddElement(DataExchXmlElement, '', 'language', 'US', ChildXmlElement, '', '', '');
        if (AMCGUID <> '') then
            AddElement(DataExchXmlElement, '', 'guid', AMCGUID, ChildXmlElement, '', '', '');
        if (AMCEmail <> '') then
            AddElement(DataExchXmlElement, '', 'email', AMCEmail, ChildXmlElement, '', '', '');


        BodyContentXmlDoc.WriteTo(TempXmlDocText);
        RemoveUTF16(TempXmlDocText);
        contentHttpContent.WriteFrom(TempXmlDocText);
        BodyHttpRequestMessage.Content(contentHttpContent);
    end;

    local procedure GetTokenURLData(AMCServiceUrl: Text; LoginPage: text): Text;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.GET();
        if (StrPos(AMCServiceUrl, AMCBankingSetup."Namespace API Version") <> 0) then begin
            AMCServiceUrl := COPYSTR(AMCServiceUrl, 1, StrPos(AMCServiceUrl, AMCBankingSetup."Namespace API Version") - 1);
            EXIT(AMCServiceUrl + 'login?token=%1&loginPage=' + LoginPage);
        end
        else
            EXIT(AMCServiceUrl + '/login?token=%1&loginPage=' + LoginPage);
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

    local procedure CleanSecureContent(LogHttpContent: HttpContent; var LogInStream: Instream);
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
        LogHttpContent.ReadAs(CleanInStream);
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
        HttpContent: HttpContent;
        FoundSyslog: Boolean;
    begin
        //Get result of call
        AMCBankingSetup.GET();

        ResponseTempBlob.CreateInStream(ResponseInStream);
        XmlDocument.ReadFrom(ResponseInStream, ResponseXMLDoc);

        ResponseXMLDoc.SelectNodes(HeadXPath, ResultXMLNodeList);
        FOR ResultXMLNodeCount := 1 TO ResultXMLNodeList.Count() DO BEGIN
            ResultXMLNodeList.Get(ResultXMLNodeCount, ResultXmlNode);
            ResponseResult := COPYSTR(GetNodeValue(ResultXmlNode, GetResultXPath()), 1, 50);
        END;

        IF (ResponseResult <> 'ok') THEN BEGIN
            ResponseXMLDoc.SelectNodes(GetSyslogXPath(), SysLogXMLNodeList);
            FOR SysLogXMLNodeCount := 1 TO SysLogXMLNodeList.Count() DO BEGIN
                FoundSyslog := true;
                SysLogXMLNodeList.Get(SysLogXMLNodeCount, SyslogXmlNode);

                GLBResponseErrorText := COPYSTR(GetNodeValue(SyslogXmlNode, GetSyslogTextXPath()), 1, 50);
                ResponseHintText := COPYSTR(GetNodeValue(SyslogXmlNode, GetSyslogHintTextXPath()), 1, 50);
                ResponseURL := COPYSTR(GetNodeValue(SyslogXmlNode, GetSyslogUrlXPath()), 1, 50);
                HttpContent.WriteFrom(ResponseInStream);
                LogId := LogHttpActivity(SoapCallResponse, AppCaller, GLBResponseErrorText, ResponseHintText, ResponseURL, HttpContent, ResponseResult);

                IF (GLBFromId = 0) THEN BEGIN
                    GLBFromId := LogId;
                    GLBToId := LogId;
                END
                ELSE
                    GLBToId := LogId;
            END;
            if (not FoundSyslog) then begin //Look for convertlog if Syslog does not exists
                ResponseXMLDoc.SelectNodes(GetConvertlogXPath(), ConvertLogXMLNodeList);
                FOR ConvertLogXMLNodeCount := 1 TO ConvertLogXMLNodeList.Count() DO BEGIN
                    ConvertLogXMLNodeList.Get(ConvertLogXMLNodeCount, ConvertlogXmlNode);

                    GLBResponseErrorText := COPYSTR(GetNodeValue(ConvertlogXmlNode, GetSyslogTextXPath()), 1, 50);
                    ResponseHintText := COPYSTR(GetNodeValue(ConvertlogXmlNode, GetSyslogHintTextXPath()), 1, 50);
                    ResponseURL := COPYSTR(GetNodeValue(ConvertlogXmlNode, GetSyslogUrlXPath()), 1, 50);
                    HttpContent.WriteFrom(ResponseInStream);
                    LogId := LogHttpActivity(SoapCallResponse, AppCaller, GLBResponseErrorText, ResponseHintText, ResponseURL, HttpContent, ResponseResult);

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
            HttpContent.WriteFrom(ResponseInStream);
            LogHttpActivity(SoapCallResponse, AppCaller, ResponseResult, '', '', HttpContent, ResponseResult);
        end;

        EXIT(FALSE);
    end;

    procedure ShowResponseError(ResponseResult: Text);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ActivityLog: Record "Activity Log";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
    begin
        IF (ResponseResult <> 'ok') THEN BEGIN
            IF (GUIALLOWED()) THEN
                IF ((GLBFromId <> 0) OR (GLBToId <> 0)) THEN
                    IF DataTypeManagement.GetRecordRef(AMCBankingSetup, RecordRef) THEN BEGIN
                        ActivityLog.SETRANGE(ActivityLog."Record ID", RecordRef.RECORDID());
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


        Found := ResponseXmlDoc.SelectSingleNode(GetJournalNoPath(), DataXmlNode); //V19.1
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

    [IntegrationEvent(true, false)] //Used for mockup testing
    procedure OnBeforeExecuteWebServiceRequest(Var Handled: Boolean; Var WebHttpRequestMessage: HttpRequestMessage; Var WebHttpResponseMessage: HttpResponseMessage; webCall: Text; AppCaller: Text[30]);
    begin
    end;

#if not CLEAN20
    [Obsolete('This method is obsolete and it will be removed. Use GetFinstaXPath instead', '20.0')]
    procedure GetFinstaXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(FinstaPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. Use GetSysErrXPath instead', '20.0')]
    procedure GetSysErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(SysErrPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. Use GetConvErrXPath instead', '20.0')]
    procedure GetConvErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(ConvErrPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. Use GetDataXPath instead', '20.0')]
    procedure GetDataXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(DataPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. Use GetBankXPath instead', '20.0')]
    procedure GetBankXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(BankPathTxt, ResponseNode));
    end;

    [Obsolete('This method is obsolete and it will be removed. Use GetJournalNoPath instead', '20.0')]
    procedure GetJournalNoPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(PackPathTxt, ResponseNode));
    end;
#endif
    procedure GetFinstaXPath(): Text
    begin
        exit(FinstaPathTxt);
    end;

    procedure GetSysErrXPath(): Text
    begin
        exit(SysErrPathTxt);
    end;

    procedure GetConvErrXPath(): Text
    begin
        exit(ConvErrPathTxt);
    end;

    procedure GetDataXPath(): Text
    begin
        exit(DataPathTxt);
    end;

    procedure GetBankXPath(): Text
    begin
        exit(BankPathTxt);
    end;

    procedure GetJournalNoPath(): Text
    begin
        exit(PackPathTxt);
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

    procedure GetReportExportTag(): Text;
    begin
        EXIT('reportExport');
    end;

    procedure GetResponseTag(): Text;
    begin
        EXIT('Response');
    end;

    procedure GetConvertlogXPath(): Text;
    begin
        EXIT('//pack/convertlog');
    end;

    procedure GetSyslogReferenceIdXPath(): Text;
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

    procedure GetTokenCreate(): Text;
    begin
        EXIT('tokenCreate');
    end;

    procedure GetTokenIdXPath(): Text;
    begin
        EXIT('//return/token');
    end;

    procedure GetTokenXPath(): Text;
    begin
        EXIT('./token');
    end;
}