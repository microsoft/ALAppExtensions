// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration;

using System.Utilities;
using System.Xml;

codeunit 31031 "SOAP WS Request Management CZL"
{
    var
        ResponseHttpResponseMessage: HttpResponseMessage;
        ResponseContentXmlDocument: XmlDocument;
        GlobalBasicUsername, GlobalBasicPassword, GlobalSoapAction, GlobalContentType : Text;
        GlobalStreamEncoding: TextEncoding;
        GlobalTimeout: Integer;
        GlobalSkipCheckHttps: Boolean;
        BodyPathTxt: Label '/soap:Envelope/soap:Body', Locked = true;
        EnvelopePathTxt: Label '/soap:Envelope', Locked = true;
        SchemaNamespaceTxt: Label 'http://www.w3.org/2001/XMLSchema', Locked = true;
        SchemaInstanceNamespaceTxt: Label 'http://www.w3.org/2001/XMLSchema-instance', Locked = true;
        SecurityUtilityNamespaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd', Locked = true;
        SecurityExtensionNamespaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', Locked = true;
        SoapNamespaceTxt: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        UsernameTokenNamepsaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText', Locked = true;

    [TryFunction]
    procedure SendRequestToWebService(ServiceUrl: Text; RequestContentInStream: InStream)
    var
        RequestTempBlob: Codeunit "Temp Blob";
        WebRequestHelper: Codeunit "Web Request Helper";
        WSHttpClient: HttpClient;
        RequestHttpContent: HttpContent;
        RequestContentHttpHeaders: HttpHeaders;
        RequestHttpHeaders: HttpHeaders;
        RequestHttpRequestMessage: HttpRequestMessage;
        RequestInStream: InStream;
        RequestOutStream: OutStream;
        ContentTypeTok: Label 'text/xml; charset=utf-8', Locked = true;
        Xml: Text;
    begin
        ClearLastError();
        Clear(ResponseHttpResponseMessage);
        Clear(ResponseContentXmlDocument);
        RequestTempBlob.CreateInStream(RequestInStream);
        RequestTempBlob.CreateOutStream(RequestOutStream);

        if GlobalSkipCheckHttps then
            WebRequestHelper.IsValidUri(ServiceUrl)
        else
            WebRequestHelper.IsSecureHttpUrl(ServiceUrl);

        RequestHttpRequestMessage.Method := 'POST';
        RequestHttpRequestMessage.SetRequestUri := ServiceUrl;
        RequestHttpRequestMessage.GetHeaders(RequestHttpHeaders);
        if GlobalSoapAction <> '' then
            RequestHttpHeaders.Add('SOAPAction', GlobalSoapAction);

        CreateSoapRequest(RequestContentInStream, RequestOutStream, GlobalBasicUsername, GlobalBasicPassword);
        RequestHttpContent.WriteFrom(RequestInStream);
        RequestInStream.Read(Xml);
        RequestHttpContent.GetHeaders(RequestContentHttpHeaders);
        RequestContentHttpHeaders.Remove('Content-Type');
        if GlobalContentType = '' then
            RequestContentHttpHeaders.Add('Content-Type', ContentTypeTok)
        else
            RequestContentHttpHeaders.Add('Content-Type', GlobalContentType);

        RequestHttpRequestMessage.Content := RequestHttpContent;
        if GlobalTimeout = 0 then
            WSHttpClient.Timeout := 60000
        else
            WSHttpClient.Timeout := GlobalTimeout;
        WSHttpClient.Send(RequestHttpRequestMessage, ResponseHttpResponseMessage);
        ResponseContentXmlDocument := ExtractContentFromResponse(ResponseHttpResponseMessage);
    end;

    [TryFunction]
    procedure SendRequestToWebService(ServiceUrl: Text; RequestContentXmlDocument: XmlDocument)
    var
        RequestContentTempBlob: Codeunit "Temp Blob";
        RequestContentInStream: InStream;
        RequestContentOutStream: OutStream;
    begin
        RequestContentTempBlob.CreateInStream(RequestContentInStream);
        RequestContentTempBlob.CreateOutStream(RequestContentOutStream);

        RequestContentXmlDocument.WriteTo(RequestContentOutStream);
        SendRequestToWebService(ServiceUrl, RequestContentInStream);
    end;

    local procedure CreateSoapRequest(RequestContentInStream: InStream; RequestOutStream: OutStream; Username: Text; Password: Text)
    var
        EnvelopeXmlDocument: XmlDocument;
        EnvelopeBodyXmlNode: XmlNode;
    begin
        if HasEnvelope(RequestContentInStream) then begin
            CopyStreamWithoutWhitespace(RequestContentInStream, RequestOutStream);
            exit;
        end;

        CreateEnvelope(EnvelopeXmlDocument, EnvelopeBodyXmlNode, Username, Password);
        AddContentToEnvelope(EnvelopeBodyXmlNode, RequestContentInStream);
        WriteXmlDocumentToStream(EnvelopeXmlDocument, RequestOutStream);
    end;

    local procedure CreateEnvelope(var EnvelopeXmlDocument: XmlDocument; var BodyXmlNode: XmlNode; Username: Text; Password: Text)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        EnvelopeXmlNode: XmlNode;
        HeaderXmlNode: XmlNode;
        SecurityXmlNode: XmlNode;
        UsernameTokenXmlNode: XmlNode;
        UsernameXmlNode: XmlNode;
        PasswordXmlNode: XmlNode;
    begin
        EnvelopeXmlDocument := XmlDocument.Create();
        XMLDOMManagement.AddRootElementWithPrefix(EnvelopeXmlDocument, 'Envelope', 'soap', SoapNamespaceTxt, EnvelopeXmlNode);
        XMLDOMManagement.AddElementWithPrefix(EnvelopeXmlNode, 'Header', '', 'soap', SoapNamespaceTxt, HeaderXmlNode);

        if (Username <> '') or (Password <> '') then begin
            XMLDOMManagement.AddElementWithPrefix(HeaderXmlNode, 'Security', '', 'wsse', SecurityExtensionNamespaceTxt, SecurityXmlNode);
            XMLDOMManagement.AddNamespaceDeclaration(SecurityXmlNode, 'wsu', SecurityUtilityNamespaceTxt);
            XMLDOMManagement.AddAttributeWithPrefix(SecurityXmlNode, 'mustUnderstand', 'soap', SoapNamespaceTxt, '1');

            XMLDOMManagement.AddElementWithPrefix(SecurityXmlNode, 'UsernameToken', '', 'wsse', SecurityExtensionNamespaceTxt, UsernameTokenXmlNode);
            XMLDOMManagement.AddAttributeWithPrefix(UsernameTokenXmlNode, 'Id', 'wsu', SecurityUtilityNamespaceTxt, CreateUUID());

            XMLDOMManagement.AddElementWithPrefix(UsernameTokenXmlNode, 'Username', Username, 'wsse', SecurityExtensionNamespaceTxt, UsernameXmlNode);
            XMLDOMManagement.AddElementWithPrefix(UsernameTokenXmlNode, 'Password', Password, 'wsse', SecurityExtensionNamespaceTxt, PasswordXmlNode);
            XMLDOMManagement.AddAttribute(PasswordXmlNode, 'Type', UsernameTokenNamepsaceTxt);
        end;

        XMLDOMManagement.AddElementWithPrefix(EnvelopeXmlNode, 'Body', '', 'soap', SoapNamespaceTxt, BodyXmlNode);
        XMLDOMManagement.AddNamespaceDeclaration(BodyXmlNode, 'xsi', SchemaInstanceNamespaceTxt);
        XMLDOMManagement.AddNamespaceDeclaration(BodyXmlNode, 'xsd', SchemaNamespaceTxt);
    end;

    local procedure CreateUUID(): Text
    begin
        exit('uuid-' + DelChr(LowerCase(Format(CreateGuid())), '=', '{}'));
    end;

    local procedure AddContentToEnvelope(var BodyXmlNode: XmlNode; RequestContentInStream: InStream)
    var
        RequestContentXmlDocument: XmlDocument;
        RequestContentXmlElement: XmlElement;
    begin
        XmlDocument.ReadFrom(RequestContentInStream, RequestContentXmlDocument);
        RequestContentXmlDocument.GetRoot(RequestContentXmlElement);
        BodyXmlNode.AsXmlElement().Add(RequestContentXmlElement);
    end;

    local procedure CopyStreamWithoutWhitespace(DataInStream: InStream; DataOutStream: OutStream)
    var
        DotNetXmlDocument: Codeunit DotNet_XmlDocument;
    begin
        DotNetXmlDocument.InitXmlDocument();
        DotNetXmlDocument.Load(DataInStream);
        DataOutStream.WriteText(DotNetXmlDocument.OuterXml());
    end;

    local procedure WriteXmlDocumentToStream(DataXmlDocument: XmlDocument; DataOutStream: OutStream)
    var
        XmlTempBlob: Codeunit "Temp Blob";
        XmlInStream: InStream;
        XmlOutStream: OutStream;
    begin
        XmlTempBlob.CreateInStream(XmlInStream);
        XmlTempBlob.CreateOutStream(XmlOutStream);
        DataXmlDocument.WriteTo(XmlOutStream);
        CopyStreamWithoutWhitespace(XmlInStream, DataOutStream);
    end;

    local procedure HasEnvelope(ContentInStream: InStream): Boolean
    var
        ContentXmlDocument: XmlDocument;
    begin
        XmlDocument.ReadFrom(ContentInStream, ContentXmlDocument);
        exit(HasEnvelope(ContentXmlDocument));
    end;

    local procedure HasEnvelope(ContentXmlDocument: XmlDocument): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ContentXmlElement: XmlElement;
        EnvelopeXmlNode: XmlNode;
    begin
        ContentXmlDocument.GetRoot(ContentXmlElement);
        exit(XMLDOMManagement.FindNodeWithNamespace(ContentXmlElement.AsXmlNode(), EnvelopePathTxt, 'soap', SoapNamespaceTxt, EnvelopeXmlNode));
    end;

    procedure GetResponseAsText(): Text
    var
        ResponseText: Text;
    begin
        ResponseHttpResponseMessage.Content().ReadAs(ResponseText);
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

    procedure GetResponseContent(var ResponseContentTempBlob: Codeunit "Temp Blob")
    var
        ResponseOutStream: OutStream;
    begin
        Clear(ResponseContentTempBlob);
        ResponseContentTempBlob.CreateOutStream(ResponseOutStream, GlobalStreamEncoding);
        ResponseContentXmlDocument.WriteTo(ResponseOutStream);
    end;

    local procedure ExtractContentFromResponse(ResponseHttpResponseMessage: HttpResponseMessage): XmlDocument
    var
        BodyXmlNode: XmlNode;
        ContentXmlDocument: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        ResponseContentText: Text;
        SoapXmlDocument: XmlDocument;
    begin
        ResponseHttpResponseMessage.Content().ReadAs(ResponseContentText);
        XmlDocument.ReadFrom(ResponseContentText, SoapXmlDocument);
        NamespaceManager.NameTable(SoapXmlDocument.NameTable());
        NamespaceManager.AddNamespace('soap', SoapNamespaceTxt);
        SoapXmlDocument.SelectSingleNode(BodyPathTxt, NamespaceManager, BodyXmlNode);
        XmlDocument.ReadFrom(BodyXmlNode.AsXmlElement().InnerXml(), ContentXmlDocument);
        exit(ContentXmlDocument);
    end;

    procedure GetHttpStatusCode(): Integer
    begin
        exit(ResponseHttpResponseMessage.HttpStatusCode());
    end;

    procedure ProcessFaultResponse()
    var
        ResponseContentFault: Text;
        ServiceStatusErr: Label 'Web service returned error message.\\Status Code: %1\Description: %2', Comment = '%1 = HTTP error status, %2 = HTTP error description';
        ResponseContentFaultErr: Label 'Web service returned error message.\\%1', Comment = '%1 = fault from response content';
    begin
        if not ResponseHttpResponseMessage.IsSuccessStatusCode() then
            Error(ServiceStatusErr, GetHttpStatusCode(), GetLastErrorText());
        ResponseContentFault := GetResponseContentFault();
        if ResponseContentFault <> '' then
            Error(ResponseContentFaultErr, ResponseContentFault);
    end;

    procedure HasResponseContentFault(): Boolean
    begin
        exit(GetResponseContentFault() <> '');
    end;

    procedure GetResponseContentFault(): Text
    var
        ErrorText: Text;
        ResponseContent: Text;
    begin
        GetResponseContent(ResponseContent);
        OnGetResponseContentFault(ResponseContent, ErrorText);
        exit(ErrorText);
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

    [IntegrationEvent(false, false)]
    local procedure OnGetResponseContentFault(ResponseContent: Text; var ErrorText: Text)
    begin
    end;
}
