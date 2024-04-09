// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.Integration;
using System.Security.Encryption;
using System.Utilities;
using System.Xml;

codeunit 31116 "EET Service Management CZL"
{
    Access = Internal;

    var
        TempErrorMessage: Record "Error Message" temporary;
        FIKControlCode: Text;
        ResponseContentError: Text;
        ResponseContentErrorCode: Text;
        VerificationMode: Boolean;
        EETNamespaceTxt: Label 'http://fs.mfcr.cz/eet/schema/v3', Locked = true;
        SoapNamespaceTxt: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        SecurityUtilityNamespaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd', Locked = true;
        SecurityExtensionNamespaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', Locked = true;
        SecurityEncodingTypeBase64BinaryTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary', Locked = true;
        SecurityValueTypeX509V3Txt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3', Locked = true;
        BodyPathTxt: Label '/soap:Envelope/soap:Body', Locked = true;
        BinarySecurityTokenPathTxt: Label '//wsse:BinarySecurityToken', Locked = true;
        SecurityPathTxt: Label '//wsse:Security', Locked = true;
        ErrorPathTxt: Label '//eet:Chyba', Locked = true;
        WarningPathTxt: Label '//eet:Varovani', Locked = true;
        ConfirmationPathTxt: Label '//eet:Potvrzeni', Locked = true;
        HeaderPathTxt: Label '//eet:Hlavicka', Locked = true;
        EETNamespacePrefixTxt: Label 'eet', Locked = true;
        MessageUUIDNotMatchErr: Label 'Message UUID received in response doesn''t match to Message UUID in EET Entry.';
        SecurityCodeNotMatchErr: Label 'Taxpayer''s security code received in response doesn''t match to Taxpayer''s security code in EET Entry.';

    [TryFunction]
    procedure Send(EETEntryCZL: Record "EET Entry CZL")
    var
        IsolatedCertificate: Record "Isolated Certificate";
        RequestXmlDocument: XmlDocument;
        SoapXmlDocument: XmlDocument;
        ResponseContentXmlDocument: XmlDocument;
        ResponseXmlDocument: XmlDocument;
    begin
        Initialize();

        FindValidCertificate(EETEntryCZL.GetCertificateCode(), IsolatedCertificate);
        if not CheckEETEntry(EETEntryCZL, IsolatedCertificate) then
            Error('');

        CreateXmlDocument(EETEntryCZL, RequestXmlDocument);
        CreateSoapRequest(RequestXmlDocument, IsolatedCertificate, SoapXmlDocument);
        SendSoapRequest(SoapXmlDocument, ResponseXmlDocument, ResponseContentXmlDocument);

        if HasResponseContentError(ResponseContentXmlDocument) then
            ProcessResponseContentError(ResponseContentXmlDocument);

        if HasResponseContentWarnings(ResponseContentXmlDocument) then
            ProcessResponseContentWarnings(ResponseContentXmlDocument);

        CheckResponseSecurity(ResponseXmlDocument);
        CheckResponseContentHeader(ResponseContentXmlDocument, EETEntryCZL);
        ProcessResponseContent(ResponseContentXmlDocument);

        if HasErrors() then
            Error('');
    end;

    local procedure CheckEETEntry(EETEntryCZL: Record "EET Entry CZL"; IsolatedCertificate: Record "Isolated Certificate"): Boolean
    var
        CompanyInformation: Record "Company Information";
        CertificateManagement: Codeunit "Certificate Management";
        CertificateSimpleName: Text;
        VATRegistrationErrorTxt: Label 'The certificate was issued to %1 but your VAT Registration No. is %2.', Comment = '%1=VAT Registration Number of certificate, %2=VAT Registration Number of company';
        VATRegistrationWarningTxt: Label 'VAT Registration No. %1 on EET Entry doesn''t match to VAT Registration No. %2 in Company Information.', Comment = '%1=VAT Registration Number of EET Entry, %2=VAT Registration Number of Company Information';
        EmptyBusinessPremisesIdTxt: Label 'Business Premises Id must not be empty.';
        EmptyCashRegisterNoTxt: Label 'Cash Register No. must not be empty.';
        EmptyReceiptSerialNoTxt: Label 'Receipt Serial No. must not be empty.';
    begin
        CompanyInformation.Get();
        if CompanyInformation."VAT Registration No." <> EETEntryCZL."VAT Registration No." then
            LogMessage(TempErrorMessage."Message Type"::Warning, '',
              StrSubstNo(VATRegistrationWarningTxt, EETEntryCZL."VAT Registration No.", CompanyInformation."VAT Registration No."));
        CertificateSimpleName := CertificateManagement.GetCertSimpleName(IsolatedCertificate);
        if CompanyInformation."VAT Registration No." <> CertificateSimpleName then
            LogMessage(TempErrorMessage."Message Type"::Error, '',
              StrSubstNo(VATRegistrationErrorTxt, CertificateSimpleName, CompanyInformation."VAT Registration No."));
        if EETEntryCZL.GetBusinessPremisesId() = '' then
            LogMessage(TempErrorMessage."Message Type"::Error, '', EmptyBusinessPremisesIdTxt);
        if EETEntryCZL."Cash Register Code" = '' then
            LogMessage(TempErrorMessage."Message Type"::Error, '', EmptyCashRegisterNoTxt);
        if EETEntryCZL."Receipt Serial No." = '' then
            LogMessage(TempErrorMessage."Message Type"::Error, '', EmptyReceiptSerialNoTxt);
        exit(not HasErrors());
    end;

    local procedure FindValidCertificate(CertificateCode: Code[20]; var IsolatedCertificate: Record "Isolated Certificate")
    var
        CertificateCodeCZL: Record "Certificate Code CZL";
        CertificateNotExistErr: Label 'There is not valid certificate %1.', Comment = '%1 = certificate code';
    begin
        CertificateCodeCZL.Get(CertificateCode);
        if not CertificateCodeCZL.FindValidCertificate(IsolatedCertificate) then
            Error(CertificateNotExistErr, CertificateCode);
    end;

    local procedure CreateXmlDocument(EETEntryCZL: Record "EET Entry CZL"; var RequestXmlDocument: XmlDocument)
    var
        CompanyInformation: Record "Company Information";
        XMLDOMManagement: Codeunit "XML DOM Management";
        SalesXmlNode: XmlNode;
        HeaderXmlNode: XmlNode;
        DataXmlNode: XmlNode;
        ControlCodesXmlNode: XmlNode;
        SignatureCodeXmlNode: XmlNode;
        SecurityCodeXmlNode: XmlNode;
        SignatureCodeCipherTxt: Label 'RSA2048', Locked = true;
        SignatureCodeDigestTxt: Label 'SHA256', Locked = true;
        SignatureCodeEncodingTxt: Label 'base64', Locked = true;
        SecurityCodeDigestTxt: Label 'SHA1', Locked = true;
        SecurityCodeEncodingTxt: Label 'base16', Locked = true;
    begin
        RequestXmlDocument := XmlDocument.Create();
        XMLDOMManagement.AddRootElementWithPrefix(RequestXmlDocument, 'Trzba', EETNamespacePrefixTxt, EETNamespaceTxt, SalesXmlNode);
        XMLDOMManagement.AddElementWithPrefix(SalesXmlNode, 'Hlavicka', '', EETNamespacePrefixTxt, EETNamespaceTxt, HeaderXmlNode);
        XMLDOMManagement.AddElementWithPrefix(SalesXmlNode, 'Data', '', EETNamespacePrefixTxt, EETNamespaceTxt, DataXmlNode);
        XMLDOMManagement.AddElementWithPrefix(SalesXmlNode, 'KontrolniKody', '', EETNamespacePrefixTxt, EETNamespaceTxt, ControlCodesXmlNode);
        XMLDOMManagement.AddElementWithPrefix(ControlCodesXmlNode, 'pkp',
            EETEntryCZL.GetSignatureCode(), EETNamespacePrefixTxt, EETNamespaceTxt, SignatureCodeXmlNode);
        XMLDOMManagement.AddElementWithPrefix(ControlCodesXmlNode, 'bkp',
            EETEntryCZL."Taxpayer's Security Code", EETNamespacePrefixTxt, EETNamespaceTxt, SecurityCodeXmlNode);

        AddAttribute(HeaderXmlNode, 'uuid_zpravy', EETEntryCZL."Message UUID");
        AddAttribute(HeaderXmlNode, 'dat_odesl', FormatDateTime(CurrentDateTime()));
        AddAttribute(HeaderXmlNode, 'prvni_zaslani', FormatBoolean(EETEntryCZL.IsFirstSending()));
        AddAttribute(HeaderXmlNode, 'overeni', FormatBoolean(VerificationMode));

        CompanyInformation.Get();
        AddAttribute(DataXmlNode, 'dic_popl', CompanyInformation."VAT Registration No.");
        AddAttribute(DataXmlNode, 'dic_poverujiciho', EETEntryCZL."Appointing VAT Reg. No.");
        AddAttribute(DataXmlNode, 'id_provoz', EETEntryCZL.GetBusinessPremisesId());
        AddAttribute(DataXmlNode, 'id_pokl', EETEntryCZL."Cash Register Code");
        AddAttribute(DataXmlNode, 'porad_cis', EETEntryCZL."Receipt Serial No.");
        AddAttribute(DataXmlNode, 'dat_trzby', FormatDateTime(EETEntryCZL."Created At"));
        AddAttribute(DataXmlNode, 'celk_trzba', FormatDecimal(EETEntryCZL."Total Sales Amount"));
        AddAttribute(DataXmlNode, 'zakl_nepodl_dph', FormatDecimal(EETEntryCZL."Amount Exempted From VAT"));
        AddAttribute(DataXmlNode, 'zakl_dan1', FormatDecimal(EETEntryCZL."VAT Base (Basic)"));
        AddAttribute(DataXmlNode, 'dan1', FormatDecimal(EETEntryCZL."VAT Amount (Basic)"));
        AddAttribute(DataXmlNode, 'zakl_dan2', FormatDecimal(EETEntryCZL."VAT Base (Reduced)"));
        AddAttribute(DataXmlNode, 'dan2', FormatDecimal(EETEntryCZL."VAT Amount (Reduced)"));
        AddAttribute(DataXmlNode, 'zakl_dan3', FormatDecimal(EETEntryCZL."VAT Base (Reduced 2)"));
        AddAttribute(DataXmlNode, 'dan3', FormatDecimal(EETEntryCZL."VAT Amount (Reduced 2)"));
        AddAttribute(DataXmlNode, 'cest_sluz', FormatDecimal(EETEntryCZL."Amount - Art.89"));
        AddAttribute(DataXmlNode, 'pouzit_zboz1', FormatDecimal(EETEntryCZL."Amount (Basic) - Art.90"));
        AddAttribute(DataXmlNode, 'pouzit_zboz2', FormatDecimal(EETEntryCZL."Amount (Reduced) - Art.90"));
        AddAttribute(DataXmlNode, 'pouzit_zboz3', FormatDecimal(EETEntryCZL."Amount (Reduced 2) - Art.90"));
        AddAttribute(DataXmlNode, 'urceno_cerp_zuct', FormatDecimal(EETEntryCZL."Amt. For Subseq. Draw/Settle"));
        AddAttribute(DataXmlNode, 'cerp_zuct', FormatDecimal(EETEntryCZL."Amt. Subseq. Drawn/Settled"));
        AddAttribute(DataXmlNode, 'rezim', Format(EETEntryCZL."Sales Regime", 0, 9));

        AddAttribute(SignatureCodeXmlNode, 'cipher', SignatureCodeCipherTxt);
        AddAttribute(SignatureCodeXmlNode, 'digest', SignatureCodeDigestTxt);
        AddAttribute(SignatureCodeXmlNode, 'encoding', SignatureCodeEncodingTxt);

        AddAttribute(SecurityCodeXmlNode, 'digest', SecurityCodeDigestTxt);
        AddAttribute(SecurityCodeXmlNode, 'encoding', SecurityCodeEncodingTxt);
    end;

    local procedure AddAttribute(var ParentXmlNode: XmlNode; Name: Text; NodeValue: Text): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        if (NodeValue = '') or (NodeValue = FormatDecimal(0)) then
            exit(false);

        exit(XMLDOMManagement.AddAttribute(ParentXmlNode, Name, NodeValue));
    end;

    local procedure AddAttributeWithPrefix(var ParentXmlNode: XmlNode; Name: Text; Prefix: Text; Namespace: Text; NodeValue: Text): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        if (NodeValue = '') or (NodeValue = FormatDecimal(0)) then
            exit(false);

        exit(XMLDOMManagement.AddAttributeWithPrefix(ParentXmlNode, Name, Prefix, Namespace, NodeValue));
    end;

    local procedure CreateSoapRequest(SoapBodyContentXmlDocument: XmlDocument; IsolatedCertificate: Record "Isolated Certificate"; var SoapXmlDocument: XmlDocument)
    var
        SoapEnvelopeXmlDocument: XmlDocument;
        SoapBodyXmlNode: XmlNode;
    begin
        CreateSoapEnvelope(SoapEnvelopeXmlDocument, SoapBodyXmlNode, IsolatedCertificate);
        AddContentToSoapEnvelope(SoapBodyXmlNode, SoapBodyContentXmlDocument);
        SignXmlDocument(SoapEnvelopeXmlDocument, IsolatedCertificate, SoapXmlDocument);
    end;

    local procedure CreateSoapEnvelope(var SoapEnvelopeXmlDocument: XmlDocument; var SoapBodyXmlNode: XmlNode; IsolatedCertificate: Record "Isolated Certificate")
    var
        CertificateManagement: Codeunit "Certificate Management";
        XMLDOMManagement: Codeunit "XML DOM Management";
        EnvelopeXmlNode: XmlNode;
        HeaderXmlNode: XmlNode;
        SecurityXmlNode: XmlNode;
        BinarySecurityTokenXmlNode: XmlNode;
    begin
        SoapEnvelopeXmlDocument := XmlDocument.Create();
        XMLDOMManagement.AddRootElementWithPrefix(SoapEnvelopeXmlDocument, 'Envelope', 'soap', SoapNamespaceTxt, EnvelopeXmlNode);
        XMLDOMManagement.AddElementWithPrefix(EnvelopeXmlNode, 'Header', '', 'soap', SoapNamespaceTxt, HeaderXmlNode);

        if IsolatedCertificate.Code <> '' then begin
            XMLDOMManagement.AddElementWithPrefix(HeaderXmlNode, 'Security', '', 'wsse', SecurityExtensionNamespaceTxt, SecurityXmlNode);
            AddAttributeWithPrefix(SecurityXmlNode, 'mustUnderstand', 'soap', SoapNamespaceTxt, '1');
            XMLDOMManagement.AddNamespaceDeclaration(SecurityXmlNode, 'wsu', SecurityUtilityNamespaceTxt);
            XMLDOMManagement.AddElementWithPrefix(
                SecurityXmlNode, 'BinarySecurityToken', CertificateManagement.GetRawCertDataAsBase64String(IsolatedCertificate),
                'wsse', SecurityExtensionNamespaceTxt, BinarySecurityTokenXmlNode);
            AddAttributeWithPrefix(BinarySecurityTokenXmlNode, 'Id', 'wsu', SecurityUtilityNamespaceTxt, CreateXmlElementID());
            AddAttribute(BinarySecurityTokenXmlNode, 'EncodingType', SecurityEncodingTypeBase64BinaryTxt);
            AddAttribute(BinarySecurityTokenXmlNode, 'ValueType', SecurityValueTypeX509V3Txt);
        end;

        XMLDOMManagement.AddElementWithPrefix(EnvelopeXmlNode, 'Body', '', 'soap', SoapNamespaceTxt, SoapBodyXmlNode);
        AddAttribute(SoapBodyXmlNode, 'Id', CreateXmlElementID());
    end;

    local procedure AddContentToSoapEnvelope(var SoapBodyXmlNode: XmlNode; SoapBodyContentXmlDocument: XmlDocument)
    var
        SoapBodyContentXmlElement: XmlElement;
    begin
        SoapBodyContentXmlDocument.GetRoot(SoapBodyContentXmlElement);
        SoapBodyXmlNode.AsXmlElement().Add(SoapBodyContentXmlElement);
    end;

    [NonDebuggable]
    local procedure SignXmlDocument(InputXmlDocument: XmlDocument; IsolatedCertificate: Record "Isolated Certificate"; var SignedXmlDocument: XmlDocument)
    var
        DataTempBlob: Codeunit "Temp Blob";
        SignatureTempBlob: Codeunit "Temp Blob";
        EETXmlSignProviderCZL: Codeunit "EET Xml Sign. Provider CZL";
        XMLDOMManagement: Codeunit "XML DOM Management";
        SignatureXmlDocument: XmlDocument;
        SignatureXmlElement: XmlElement;
        SecurityXmlNode: XmlNode;
        BinarySecurityTokenXmlNode: XmlNode;
        SoapBodyXmlNode: XmlNode;
        SoapXmlWriteOptions: XmlWriteOptions;
        SoapBodyId: Text;
        BinarySecurityTokenId: Text;
        DataInStream: InStream;
        DataOutStream: OutStream;
        SignatureInStream: InStream;
        SignatureOutStream: OutStream;
    begin
        XMLDOMManagement.FindNodeWithNamespace(
          InputXmlDocument.AsXmlNode(), BinarySecurityTokenPathTxt, 'wsse', SecurityExtensionNamespaceTxt, BinarySecurityTokenXmlNode);
        BinarySecurityTokenId := XMLDOMManagement.GetAttributeValue(BinarySecurityTokenXmlNode, 'Id', SecurityUtilityNamespaceTxt);

        XMLDOMManagement.FindNodeWithNamespace(
          InputXmlDocument.AsXmlNode(), BodyPathTxt, 'soap', SoapNamespaceTxt, SoapBodyXmlNode);
        SoapBodyId := XMLDOMManagement.GetAttributeValue(SoapBodyXmlNode, 'Id');

        EETXmlSignProviderCZL.SetSoapBodyId(SoapBodyId);
        EETXmlSignProviderCZL.SetBinarySecurityTokenId(BinarySecurityTokenId);

        DataTempBlob.CreateOutStream(DataOutStream);
        DataTempBlob.CreateInStream(DataInStream);
        SignatureTempBlob.CreateOutStream(SignatureOutStream);
        SignatureTempBlob.CreateInStream(SignatureInStream);
        SoapXmlWriteOptions.PreserveWhitespace := false;
        InputXmlDocument.WriteTo(SoapXmlWriteOptions, DataOutStream);
        EETXmlSignProviderCZL.SignData(DataInStream, IsolatedCertificate, SignatureOutStream);

        XmlDocument.ReadFrom(SignatureInStream, SignatureXmlDocument);
        SignatureXmlDocument.GetRoot(SignatureXmlElement);
        SignedXmlDocument := InputXmlDocument;

        XMLDOMManagement.FindNodeWithNamespace(
          SignedXmlDocument.AsXmlNode(), SecurityPathTxt, 'wsse', SecurityExtensionNamespaceTxt, SecurityXmlNode);
        SecurityXmlNode.AsXmlElement().Add(SignatureXmlElement);
    end;

    local procedure SendSoapRequest(RequestContentXmlDocument: XmlDocument; var ResponseXmlDocument: XmlDocument; var ResponseContentXmlDocument: XmlDocument)
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
        SOAPWSRequestManagementCZL: Codeunit "SOAP WS Request Management CZL";
    begin
        EETServiceSetupCZL.Get();
        SOAPWSRequestManagementCZL.SetTimeout(EETServiceSetupCZL."Limit Response Time");
        if SOAPWSRequestManagementCZL.SendRequestToWebService(EETServiceSetupCZL."Service URL", RequestContentXmlDocument) then begin
            XmlDocument.ReadFrom(SOAPWSRequestManagementCZL.GetResponseAsText(), ResponseXmlDocument);
            ResponseContentXmlDocument := SOAPWSRequestManagementCZL.GetResponseContent();
        end else
            SOAPWSRequestManagementCZL.ProcessFaultResponse();
    end;

    local procedure ProcessResponseContent(ResponseContentXmlDocument: XmlDocument)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ConfirmationXmlNode: XmlNode;
        XMLFormatErr: Label 'XML Format of response is not supported.';
    begin
        if VerificationMode or (ResponseContentErrorCode <> '') then
            exit;

        if not XMLDOMManagement.FindNodeWithNamespace(
             ResponseContentXmlDocument.AsXmlNode(), ConfirmationPathTxt, EETNamespacePrefixTxt, EETNamespaceTxt, ConfirmationXmlNode)
        then
            LogMessage(TempErrorMessage."Message Type"::Error, '', XMLFormatErr);

        FIKControlCode := XMLDOMManagement.GetAttributeValue(ConfirmationXmlNode, 'fik');
    end;

    local procedure ProcessResponseContentError(ResponseContentXmlDocument: XmlDocument)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ErrorXmlNode: XmlNode;
    begin
        XMLDOMManagement.FindNodeWithNamespace(
          ResponseContentXmlDocument.AsXmlNode(), ErrorPathTxt, EETNamespacePrefixTxt, EETNamespaceTxt, ErrorXmlNode);

        ResponseContentError := ErrorXmlNode.AsXmlElement().InnerXml();
        ResponseContentErrorCode := XMLDOMManagement.GetAttributeValue(ErrorXmlNode, 'kod');

        if VerificationMode and (ResponseContentErrorCode = '0') then
            exit;

        LogMessage(TempErrorMessage."Message Type"::Error, ResponseContentErrorCode, ResponseContentError);
    end;

    local procedure ProcessResponseContentWarnings(ResponseContentXmlDocument: XmlDocument)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        WarningXmlNodeList: XmlNodeList;
        WarningXmlNode: XmlNode;
        ResponseContentWarning: Text;
        ResponseContentWarningCode: Text;
    begin
        XMLDOMManagement.FindNodesWithNamespace(
          ResponseContentXmlDocument.AsXmlNode(), WarningPathTxt, EETNamespacePrefixTxt, EETNamespaceTxt, WarningXmlNodeList);

        foreach WarningXmlNode in WarningXmlNodeList do begin
            ResponseContentWarning := WarningXmlNode.AsXmlElement().InnerXml();
            ResponseContentWarningCode := XMLDOMManagement.GetAttributeValue(WarningXmlNode, 'kod_varov');

            LogMessage(TempErrorMessage."Message Type"::Warning, ResponseContentWarningCode, ResponseContentWarning);
        end;
    end;

    local procedure HasResponseContentError(ResponseContentXmlDocument: XmlDocument): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ErrorXmlNode: XmlNode;
    begin
        exit(
          XMLDOMManagement.FindNodeWithNamespace(
            ResponseContentXmlDocument.AsXmlNode(), ErrorPathTxt, EETNamespacePrefixTxt, EETNamespaceTxt, ErrorXmlNode));
    end;

    local procedure HasResponseContentWarnings(ResponseContentXmlDocument: XmlDocument): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        WarningXmlNode: XmlNode;
    begin
        exit(
          XMLDOMManagement.FindNodeWithNamespace(
            ResponseContentXmlDocument.AsXmlNode(), WarningPathTxt, EETNamespacePrefixTxt, EETNamespaceTxt, WarningXmlNode));
    end;

    local procedure CheckResponseContentHeader(ResponseContentXmlDocument: XmlDocument; EETEntryCZL: Record "EET Entry CZL")
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        HeaderXmlNode: XmlNode;
        MessageUUID: Text;
        SecurityCode: Text;
    begin
        if not XMLDOMManagement.FindNodeWithNamespace(
             ResponseContentXmlDocument.AsXmlNode(), HeaderPathTxt, EETNamespacePrefixTxt, EETNamespaceTxt, HeaderXmlNode)
        then
            exit;

        MessageUUID := XMLDOMManagement.GetAttributeValue(HeaderXmlNode, 'uuid_zpravy');
        SecurityCode := XMLDOMManagement.GetAttributeValue(HeaderXmlNode, 'bkp');

        if ResponseContentErrorCode = '' then begin
            if MessageUUID <> EETEntryCZL."Message UUID" then
                LogMessage(TempErrorMessage."Message Type"::Error, '', MessageUUIDNotMatchErr);
            if SecurityCode <> EETEntryCZL."Taxpayer's Security Code" then
                LogMessage(TempErrorMessage."Message Type"::Error, '', SecurityCodeNotMatchErr);
        end else begin
            if (MessageUUID <> EETEntryCZL."Message UUID") and (MessageUUID <> '') then
                LogMessage(TempErrorMessage."Message Type"::Error, '', MessageUUIDNotMatchErr);
            if (SecurityCode <> EETEntryCZL."Taxpayer's Security Code") and (SecurityCode <> '') then
                LogMessage(TempErrorMessage."Message Type"::Error, '', SecurityCodeNotMatchErr);
        end;
    end;

    local procedure CheckResponseSecurity(ResponseXmlDocument: XmlDocument)
    var
        CertificateManagement: Codeunit "Certificate Management";
        CertBase64Value: Text;
        EETCertificateNotValidErr: Label 'Certificate of EET service is not valid.';
    begin
        if VerificationMode then
            exit;

        CertBase64Value := GetResponseCertificateAsBase64(ResponseXmlDocument);
        if CertBase64Value = '' then
            exit;

        if not CertificateManagement.VerifyCertFromBase64(CertBase64Value) then
            LogMessage(TempErrorMessage."Message Type"::Error, '', EETCertificateNotValidErr);
    end;

    local procedure GetResponseCertificateAsBase64(ResponseXmlDocument: XmlDocument): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        BinarySecurityTokenXmlNode: XmlNode;
    begin
        if XMLDOMManagement.FindNodeWithNamespace(
             ResponseXmlDocument.AsXmlNode(), BinarySecurityTokenPathTxt, 'wsse', SecurityExtensionNamespaceTxt, BinarySecurityTokenXmlNode)
        then
            exit(BinarySecurityTokenXmlNode.AsXmlElement().InnerText());
    end;

    local procedure Initialize()
    begin
        FIKControlCode := '';
        ResponseContentError := '';
        ResponseContentErrorCode := '';

        TempErrorMessage.ClearLog();
        ClearLastError();
    end;

    local procedure CreateXmlElementID(): Text
    var
        EETManagementCZL: Codeunit "EET Management CZL";
    begin
        exit('uuid-' + EETManagementCZL.CreateUUID());
    end;

    procedure FormatDecimal(DecimalValue: Decimal): Text
    begin
        exit(Format(DecimalValue, 0, '<Precision,2:2><Standard Format,2>'));
    end;

    procedure FormatBoolean(BooleanValue: Boolean): Text
    begin
        exit(Format(BooleanValue, 0, 9));
    end;

    procedure FormatDateTime(DateTimeValue: DateTime): Text
    begin
        exit(Format(RoundDateTime(DateTimeValue), 0, 9));
    end;

    local procedure IsVerificationModeOK(): Boolean
    begin
        exit(VerificationMode and (ResponseContentErrorCode = '0'));
    end;

    local procedure LogMessage(MessageType: Option; MessageCode: Text; MessageText: Text)
    var
        ErrorCodeTxt: Label 'Error Code: %1', Comment = '%1 = error code';
        WarningCodeTxt: Label 'Warning Code: %1', Comment = '%1 = warning code';
    begin
        TempErrorMessage.LogSimpleMessage(MessageType, MessageText);

        if MessageType = TempErrorMessage."Message Type"::Warning then
            TempErrorMessage.Validate("Additional Information", StrSubstNo(WarningCodeTxt, MessageCode))
        else
            TempErrorMessage.Validate("Additional Information", StrSubstNo(ErrorCodeTxt, MessageCode));

        TempErrorMessage.Modify();
    end;

    procedure HasErrors(): Boolean
    begin
        exit(TempErrorMessage.HasErrors(false));
    end;

    procedure HasWarnings(): Boolean
    begin
        TempErrorMessage.Reset();
        TempErrorMessage.SetRange("Message Type", TempErrorMessage."Message Type"::Warning);
        exit(not TempErrorMessage.IsEmpty);
    end;

    procedure GetWebServiceURLTxt(): Text[250]
    var
        WebServiceURLTxt: Label 'https://prod.eet.cz/eet/services/EETServiceSOAP/v3', Locked = true;
    begin
        exit(WebServiceURLTxt);
    end;

    procedure GetWebServicePlayGroundURLTxt(): Text[250]
    var
        WebServicePGURLTxt: Label 'https://pg.eet.cz/eet/services/EETServiceSOAP/v3', Locked = true;
    begin
        exit(WebServicePGURLTxt);
    end;

    procedure GetFIKControlCode(): Text[39]
    begin
        exit(CopyStr(FIKControlCode, 1, 39));
    end;

    procedure GetResponseText(): Text
    begin
        if IsVerificationModeOK() then
            exit(ResponseContentError);

        if GetLastErrorText() <> '' then
            exit(GetLastErrorText);

        TempErrorMessage.Reset();
        TempErrorMessage.FindFirst();
        exit(TempErrorMessage."Message");
    end;

    procedure SetVerificationMode(NewVerificationMode: Boolean)
    begin
        VerificationMode := NewVerificationMode;
    end;

    procedure SetURLToDefault(var EETServiceSetupCZL: Record "EET Service Setup CZL")
    begin
        EETServiceSetupCZL."Service URL" := GetWebServicePlayGroundURLTxt();
    end;

    procedure CopyErrorMessageToTemp(var TempDestinationErrorMessage: Record "Error Message" temporary)
    begin
        if (GetLastErrorText <> ResponseContentError) and (GetLastErrorText <> '') then
            LogMessage(TempErrorMessage."Message Type"::Error, GetLastErrorCode, GetLastErrorText);

        TempErrorMessage.Reset();
        TempErrorMessage.CopyToTemp(TempDestinationErrorMessage);
    end;

    [EventSubscriber(ObjectType::Table, 1400, 'OnRegisterServiceConnection', '', false, false)]
    local procedure HandleEETRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
        PageEETServiceSetupCZL: Page "EET Service Setup CZL";
        EETServiceSetupRecordRef: RecordRef;
    begin
        if not EETServiceSetupCZL.Get() then begin
            EETServiceSetupCZL.Init();
            EETServiceSetupCZL.Insert(true);
        end;
        EETServiceSetupRecordRef.GetTable(EETServiceSetupCZL);

        if EETServiceSetupCZL.Enabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, EETServiceSetupRecordRef.RecordId, PageEETServiceSetupCZL.Caption(), EETServiceSetupCZL."Service URL", PAGE::"EET Service Setup CZL");
    end;
}

