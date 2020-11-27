codeunit 31031 "SOAP WS Request Management CZL"
{
    var
        ResponseMessage: HttpResponseMessage;
        ResponseContentXmlDocument: XmlDocument;
        GlobalBasicUsername, GlobalBasicPassword, GlobalSoapAction, GlobalContentType : Text;
        GlobalStreamEncoding: TextEncoding;
        GlobalTimeout: Integer;
        GlobalSkipCheckHttps: Boolean;

    [TryFunction]
    procedure SendRequestToWebService(ServiceUrl: Text; ContentXmlDocument: XmlDocument)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        SoapXml: Text;
        SoapXmlDocument: XmlDocument;
        ContentTypeTok: Label 'text/xml; charset=utf-8', Locked = true;
    begin
        ClearLastError();
        Clear(ResponseMessage);
        Clear(ResponseContentXmlDocument);

        if GlobalSkipCheckHttps then
            WebRequestHelper.IsValidUri(ServiceUrl)
        else
            WebRequestHelper.IsSecureHttpUrl(ServiceUrl);

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri := ServiceUrl;
        RequestMessage.GetHeaders(RequestHeaders);
        if GlobalSoapAction <> '' then
            RequestHeaders.Add('SOAPAction', GlobalSoapAction);

        SoapXmlDocument := CreateSoapEnvelope(ContentXmlDocument);
        SoapXmlDocument.WriteTo(SoapXml);
        Content.WriteFrom(SoapXml);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        if GlobalContentType = '' then
            ContentHeaders.Add('Content-Type', ContentTypeTok)
        else
            ContentHeaders.Add('Content-Type', GlobalContentType);

        RequestMessage.Content := Content;
        if GlobalTimeout = 0 then
            Client.Timeout := 60000
        else
            Client.Timeout := GlobalTimeout;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseContentXmlDocument := ExtractContentFromResponse(ResponseMessage);
    end;

    local procedure CreateSoapEnvelope(ContentXmlDocument: XmlDocument): XmlDocument
    var
        BodyXmlNode: XmlNode;
        ContentRootXmlElement: XmlElement;
        NamespaceManager: XmlNamespaceManager;
        SoapXmlDocument: XmlDocument;
    begin
        ContentXmlDocument.GetRoot(ContentRootXmlElement);

        XmlDocument.ReadFrom(GetSoapEnvelopeXml(), SoapXmlDocument);
        SoapXmlDocument.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));
        NamespaceManager.NameTable(SoapXmlDocument.NameTable());
        NamespaceManager.AddNamespace('soap', 'http://schemas.xmlsoap.org/soap/envelope/');
        SoapXmlDocument.SelectSingleNode('//soap:Body', NamespaceManager, BodyXmlNode);
        BodyXmlNode.AsXmlElement().Add(ContentRootXmlElement);
        exit(SoapXmlDocument);
    end;

    local procedure GetSoapEnvelopeXml(): Text
    begin
        exit(
            '<soap:Envelope ' +
                'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
                'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soap:Body>' +
                '</soap:Body>' +
            '</soap:Envelope>'
        );
    end;

    procedure GetResponseAsText(): Text
    var
        ResponseText: Text;
    begin
        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure GetResponseContent(): XmlDocument
    begin
        exit(ResponseContentXmlDocument);
    end;

    procedure GetResponseContent(var ResponseContentText: Text)
    begin
        Clear(ResponseContentText);
        ResponseContentXmlDocument.WriteTo(ResponseContentText);
    end;

    procedure GetResponseContent(var TempBlobResponseContent: Codeunit "Temp Blob")
    var
        OutStr: OutStream;
    begin
        Clear(TempBlobResponseContent);
        TempBlobResponseContent.CreateOutStream(OutStr, GlobalStreamEncoding);
        ResponseContentXmlDocument.WriteTo(OutStr);
    end;

    procedure GetResponseResultValue(): Text
    var
        ResultXmlNode: XmlNode;
        RootXmlElement: XmlElement;
    begin
        ResponseContentXmlDocument.GetRoot(RootXmlElement);
        RootXmlElement.GetDescendantNodes().Get(1, ResultXmlNode);
        exit(ResultXmlNode.AsXmlElement().InnerXml());
    end;

    local procedure ExtractContentFromResponse(ResponseMessage: HttpResponseMessage): XmlDocument
    var
        BodyXmlNode: XmlNode;
        ContentXmlDocument: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        ResponseContentText: Text;
        SoapXmlDocument: XmlDocument;
    begin
        ResponseMessage.Content().ReadAs(ResponseContentText);
        XmlDocument.ReadFrom(ResponseContentText, SoapXmlDocument);
        NamespaceManager.NameTable(SoapXmlDocument.NameTable());
        NamespaceManager.AddNamespace('soap', 'http://schemas.xmlsoap.org/soap/envelope/');
        SoapXmlDocument.SelectSingleNode('//soap:Body', NamespaceManager, BodyXmlNode);
        XmlDocument.ReadFrom(BodyXmlNode.AsXmlElement().InnerXml(), ContentXmlDocument);
        exit(ContentXmlDocument);
    end;

    procedure GetHttpStatusCode(): Integer
    begin
        exit(ResponseMessage.HttpStatusCode());
    end;

    procedure HasResponseFaultResult(): Boolean
    begin
        exit(GetResponseFaultResultText() <> '');
    end;

    procedure ProcessFaultResponse()
    var
        ResponseFaultResultText: Text;
        ServiceStatusErr: Label 'Web service returned error message.\\Status Code: %1\Description: %2', Comment = '%1 = HTTP error status, %2 = HTTP error description';
        ServiceFaultResultErr: Label 'Web service returned error message.\\%1', Comment = '%1 = ResponseFaultResultText';
    begin
        if not ResponseMessage.IsSuccessStatusCode() then
            Error(ServiceStatusErr, GetHttpStatusCode(), GetLastErrorText());

        ResponseFaultResultText := GetResponseFaultResultText();
        if ResponseFaultResultText <> '' then
            Error(ServiceFaultResultErr, ResponseFaultResultText);
    end;

    local procedure GetResponseFaultResultText(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        ResultXmlDocument: XmlDocument;
        RootXmlElement: XmlElement;
        StateXmlAttribute: XmlAttribute;
        TextXmlNode: XmlNode;
        ResultValueText: Text;
    begin
        ResultValueText := GetResponseResultValue();

        if ResultValueText.StartsWith('ERROR:') then
            exit(ResultValueText.Substring(8));

        ResultValueText := TypeHelper.HtmlDecode(ResultValueText);
        if XmlDocument.ReadFrom(ResultValueText, ResultXmlDocument) then
            if ResultXmlDocument.GetRoot(RootXmlElement) then
                if RootXmlElement.Attributes().Get('STATE', StateXmlAttribute) then
                    if StateXmlAttribute.Value() = 'FAIL' then
                        if RootXmlElement.SelectSingleNode('//TEXT', TextXmlNode) then
                            exit(TextXmlNode.AsXmlElement().InnerXml().Substring(8));

        exit('');
    end;

    procedure SetBasicCredentials(Username: Text; Password: Text)
    begin
        GlobalBasicUsername := Username;
        GlobalBasicPassword := Password;
    end;

    procedure SetAction(SoapAction: Text);
    begin
        GlobalSoapAction := SoapAction;
    end;

    procedure SetStreamEncoding(StreamEncoding: TextEncoding);
    begin
        GlobalStreamEncoding := StreamEncoding;
    end;

    procedure SetTimeout(NewTimeout: Integer)
    begin
        GlobalTimeout := NewTimeout;
    end;

    procedure SetContentType(NewContentType: Text)
    begin
        GlobalContentType := NewContentType;
    end;

    procedure DisableHttpsCheck()
    begin
        GlobalSkipCheckHttps := true;
    end;
}
