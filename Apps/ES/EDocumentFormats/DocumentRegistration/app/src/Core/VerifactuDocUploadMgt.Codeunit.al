// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

using Microsoft.EServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Send;
using System.Utilities;

codeunit 10777 "Verifactu Doc. Upload Mgt."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "E-Document" = rimd,
                  tabledata "E-Document Log" = rimd,
                  tabledata "E-Doc. Data Storage" = rimd;

    var
        VerifactuSetup: Record "Verifactu Setup";
        ConnectionSetupErr: Label 'You must enable Verifactu Setup.';
        NoCertificateErr: Label 'Loading the certificate failed. Open Verifactu Setup page and make sure that the certificate and its password are correctly specified and that it has not expired.';
        NoCertificateTelemetryErr: Label 'Could not get certificate.', Locked = true;
        BatchSoapRequestMsg: Label 'Sending batch soap request of type %1', Locked = true;
        NoResponseErr: Label 'Remote service did not provide a response. Open Verifactu Setup page and make sure that the Document Registration Endpoint and the certificate are correctly specified and try again.';
        NoResponseTelemetryErr: Label 'Could not get response.', Locked = true;
        CommunicationErr: Label 'Remote service returned an unexpected response: %1.', Comment = '%1 is the error message.';
        CommunicationTelemetryErr: Label 'Communication error: %1.', Comment = '%1 is the error message.', Locked = true;
        CouldNotEvaluateClearanceDateErr: Label 'Could not evaluate clearance date: %1.', Comment = '%1 is the received clearance date as text.', Locked = true;
        BatchSoapRequestSuccMsg: Label 'Batch soap request of type %1 successfully executed', Locked = true;
        FeatureNameTxt: Label 'Verifactu Document Registration';
        DocRegistrationErr: Label 'AEAT response contains an error. %1.', Comment = 'AEAT is the abbreviation of Agencia Tributaria, Spanish Tax Authority, %1 is the error message from AEAT.';
        DisableVerifactuQst: Label 'Verifactu setup will be disabled. Do you want to proceed?';
        EmptyRequestLbl: Label 'The request is empty.';

    internal procedure InvokeSoapRequest(var EDocument: Record "E-Document"; RequestText: Text; RequestType: Enum "Verifactu Request Type"; var ErrorText: Text; var SendContext: Codeunit SendContext): Boolean
    var
        DocRegistrationCertMgt: Codeunit "Doc. Registration Cert. Mgt.";
        CertificateEnabled, IsSuccessful : Boolean;
        CertText, CertPassword : SecretText;
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        ContentHeaders, RequestHeaders : HttpHeaders;
        WebServiceUrl, StatusDescription, ResponseTxt : Text;
        StatusCode: Integer;
    begin
        if not VerifactuSetup.IsEnabled() then begin
            ErrorText := ConnectionSetupErr;
            exit(false);
        end;

        Session.LogMessage('0000QWW', StrSubstNo(BatchSoapRequestMsg, RequestType), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);

        CertificateEnabled := DocRegistrationCertMgt.GetIsolatedCertificate(VerifactuSetup."Certificate Code", CertText, CertPassword);
        if not CertificateEnabled then begin
            Session.LogMessage('0000QWX', NoCertificateTelemetryErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);
            ErrorText := NoCertificateErr;
            exit(false);
        end;
        HttpClient.AddCertificate(CertText, CertPassword);

        case RequestType of
            RequestType::DocumentRegistration:
                WebServiceUrl := VerifactuSetup.GetDocumentSubmissionEndpointUrl();
            RequestType::DocumentCancelation:
                WebServiceUrl := VerifactuSetup.GetDocumentSubmissionEndpointUrl();
            RequestType::QrCodeValidation:
                WebServiceUrl := VerifactuSetup.GetQRCodeValidationEndpointUrl();
        end;

        Commit();

        HttpRequest := SendContext.Http().GetHttpRequestMessage();
        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(WebServiceUrl);

        HttpRequest.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/xml');
        RequestHeaders.Add('Accept-Encoding', 'utf-8');

        HttpRequest.Content.WriteFrom(RequestText);
        HttpRequest.Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/xml');
        HttpRequest.Content(HttpRequest.Content);

        IsSuccessful := HttpClient.Send(HttpRequest, HttpResponse);
        SendContext.Http().SetHttpResponseMessage(HttpResponse);

        if not IsSuccessful then begin
            Session.LogMessage('0000QWY', NoResponseTelemetryErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);
            ErrorText := NoResponseErr;
            exit(false);
        end;

        StatusCode := HttpResponse.HttpStatusCode;
        StatusDescription := HttpResponse.ReasonPhrase;
        if not (StatusCode in [200, 202]) then begin
            Session.LogMessage('0000QWZ', StrSubstNo(CommunicationTelemetryErr, Format(StatusCode) + ' ' + StatusDescription), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);
            ErrorText := StrSubstNo(CommunicationErr, Format(StatusCode) + ' ' + StatusDescription);
            exit(false);
        end;

        HttpResponse.Content().ReadAs(ResponseTxt);
        if not ParseResponse(EDocument, ResponseTxt, SendContext, ErrorText) then
            exit(false);
        Session.LogMessage('0000QX0', StrSubstNo(BatchSoapRequestSuccMsg, RequestType), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);
        exit(true);
    end;

    procedure ParseResponse(var EDocument: Record "E-Document"; var ResponseText: Text; var SendContext: Codeunit SendContext; var ErrorText: Text): Boolean
    var
        XmlDoc: XmlDocument;
        XmlElem: XmlElement;
        XmlRootNode: XmlNode;
        SubmissionId, SubmissionStatus, LineErrorCode, LineErrorDescription, HeaderErrorDetails, ClearanceDateTimeTxt : Text;
        ClearanceDateTime: DateTime;
        LineErrorCodeXPath, LineErrorDescriptionXPath, HeaderErrorDetailsXPath, SubmissionIdXPath, SubmissionStatusXPath, ClearanceDateTimeXPath : Text;
    begin
        if ResponseText = '' then begin
            Session.LogMessage('0000QX1', EmptyRequestLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);
            exit(false);
        end;

        ResponseText := ResponseText.Replace('env:', '');
        ResponseText := ResponseText.Replace('tikR:', '');
        ResponseText := ResponseText.Replace('tik:', '');

        XmlDocument.ReadFrom(ResponseText, XmlDoc);
        XmlDoc.GetRoot(XmlElem);
        XMLRootNode := XmlElem.AsXmlNode();

        LineErrorCodeXPath := '/Envelope/Body/RespuestaRegFactuSistemaFacturacion/RespuestaLinea/CodigoErrorRegistro';
        LineErrorDescriptionXPath := '/Envelope/Body/RespuestaRegFactuSistemaFacturacion/RespuestaLinea/DescripcionErrorRegistro';
        HeaderErrorDetailsXPath := '/Envelope/Body/Fault/faultstring';
        SubmissionIdXPath := '/Envelope/Body/RespuestaRegFactuSistemaFacturacion/CSV';
        SubmissionStatusXPath := '/Envelope/Body/RespuestaRegFactuSistemaFacturacion/RespuestaLinea/EstadoRegistro';
        ClearanceDateTimeXPath := '/Envelope/Body/RespuestaRegFactuSistemaFacturacion/DatosPresentacion/TimestampPresentacion';

        LineErrorCode := FindNodeXML(XMLRootNode, LineErrorCodeXPath);
        LineErrorDescription := FindNodeXML(XMLRootNode, LineErrorDescriptionXPath);
        HeaderErrorDetails := FindNodeXML(XMLRootNode, HeaderErrorDetailsXPath);
        SubmissionId := FindNodeXML(XMLRootNode, SubmissionIdXPath);
        SubmissionStatus := FindNodeXML(XMLRootNode, SubmissionStatusXPath);
        ClearanceDateTimeTxt := FindNodeXML(XMLRootNode, ClearanceDateTimeXPath);
        if ClearanceDateTimeTxt <> '' then
            if not Evaluate(ClearanceDateTime, ClearanceDateTimeTxt, 9) then
                Session.LogMessage('0000QX2', StrSubstNo(CouldNotEvaluateClearanceDateErr, ClearanceDateTimeTxt), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);

        if HeaderErrorDetails <> '' then
            ErrorText := HeaderErrorDetails
        else
            if LineErrorCode <> '' then begin
                ErrorText := LineErrorCode;
                if LineErrorDescription <> '' then
                    ErrorText += ': ' + LineErrorDescription
            end;

        if ErrorText <> '' then begin
            ErrorText := StrSubstNo(DocRegistrationErr, ErrorText);
            Session.LogMessage('0000QX3', ErrorText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureNameTxt);
        end;
        UpdateEdocument(EDocument, SubmissionId, SubmissionStatus, ClearanceDateTime, SendContext, ErrorText);
        if ErrorText <> '' then
            exit(false);
        exit(true);
    end;

    local procedure FindNodeXML(Node: XmlNode; NodePath: Text): Text;
    var
        RootElement: XmlElement;
        FoundXmlNode: XmlNode;
    begin
        if Node.SelectSingleNode(NodePath, FoundXmlNode) then begin
            if FoundXmlNode.IsXmlElement() then
                exit(FoundXmlNode.AsXmlElement().InnerXml());

            if FoundXmlNode.IsXmlDocument() then begin
                FoundXmlNode.AsXmlDocument().GetRoot(RootElement);
                exit(RootElement.InnerXml());
            end;
        end;

        exit('');
    end;

    procedure SendEDocument(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document"; var SendContext: Codeunit SendContext)
    var
        ErrorText, RequestTxt : Text;
        RequestType: Enum "Verifactu Request Type";
    begin
        RequestTxt := GetRequestText(TempBlob);

        if RequestTxt = '' then begin
            ErrorText := EmptyRequestLbl;
            exit;
        end;
        case EDocument."Document Type" of
            EDocument."Document Type"::"Sales Invoice",
            EDocument."Document Type"::"Sales Order",
            EDocument."Document Type"::"Sales Quote",
            EDocument."Document Type"::"Service Invoice",
            EDocument."Document Type"::"Service Order":
                RequestType := Enum::"Verifactu Request Type"::DocumentRegistration;
            EDocument."Document Type"::"Sales Credit Memo",
            EDocument."Document Type"::"Sales Return Order",
            EDocument."Document Type"::"Service Credit Memo":
                RequestType := Enum::"Verifactu Request Type"::DocumentCancelation;

        end;
        if not InvokeSoapRequest(EDocument, RequestTxt, RequestType, ErrorText, SendContext) then
            Error(ErrorText);
    end;

    local procedure GetRequestText(var TempBlob: Codeunit "Temp Blob") RequestTxt: Text
    var
        FileInStream: InStream;
        RequestLineTxt: Text;
    begin
        TempBlob.CreateInStream(FileInStream, TextEncoding::UTF8);
        while not FileInStream.EOS do begin
            FileInStream.ReadText(RequestLineTxt);
            RequestTxt += RequestLineTxt;
        end;
        exit(RequestTxt);
    end;

    procedure UpdateEdocument(var EDocument: Record "E-Document"; SubmissionId: Text; SubmissionStatus: Text; ClearanceDateTime: DateTime; var SendContext: Codeunit SendContext; ErrorText: Text)
    var
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentServiceStatus: Enum "E-Document Service Status";
    begin
        EDocument."Last Clearance Request Time" := CurrentDateTime();
        EDocument."Clearance Date" := ClearanceDateTime;
        EDocument.Modify();
        UpdateVerifactuEDocument(EDocument, SubmissionId, SubmissionStatus);

        if SubmissionStatus = 'Correcto' then
            EDocumentServiceStatus := "E-Document Service Status"::Cleared
        else
            EDocumentServiceStatus := "E-Document Service Status"::"Not Cleared";
        SendContext.Status().SetStatus(EDocumentServiceStatus);
        EDocumentLogHelper.InsertLog(EDocument, EDocument.GetEDocumentService(), EDocumentServiceStatus);
        if ErrorText <> '' then
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, ErrorText);
    end;

    procedure InsertVerifactuDocument(var EDocument: Record "E-Document"; SourceDocumentNo: Code[20]; SourceDocumentPostingDate: Date; VerifactuHash: Text[64])
    var
        VerifactuDocument: Record "Verifactu Document";
    begin
        if VerifactuDocument.Get(EDocument."Entry No") then
            exit;
        VerifactuDocument.Init();
        VerifactuDocument."E-Document Entry No." := EDocument."Entry No";
        VerifactuDocument."Source Document Type" := EDocument."Document Type";
        VerifactuDocument."Source Document No." := SourceDocumentNo;
        VerifactuDocument."Verifactu Hash" := VerifactuHash;
        VerifactuDocument."Verifactu Posting Date" := SourceDocumentPostingDate;
        VerifactuDocument.Insert();
    end;

    procedure UpdateVerifactuEDocument(var EDocument: Record "E-Document"; SubmissionId: Text; SubmissionStatus: Text)
    var
        VerifactuDocument: Record "Verifactu Document";
    begin
        if not VerifactuDocument.Get(EDocument."Entry No") then
            exit;
        VerifactuDocument."Submission Id" := CopyStr(SubmissionId, 1, MaxStrLen(VerifactuDocument."Submission Id"));
        VerifactuDocument."Submission Status" := CopyStr(SubmissionStatus, 1, MaxStrLen(VerifactuDocument."Submission Status"));
        VerifactuDocument.Modify();
    end;

    procedure GetVerifactuData(var EDocument: Record "E-Document"; var VerifactuHash: Text[64]; var SubmissionId: Text[100])
    var
        VerifactuDocument: Record "Verifactu Document";
    begin
        VerifactuDocument.SetLoadFields("Verifactu Hash", "Submission Id");
        if not VerifactuDocument.Get(EDocument."Entry No") then
            exit;
        VerifactuHash := VerifactuDocument."Verifactu Hash";
        SubmissionId := VerifactuDocument."Submission Id";
    end;

    [EventSubscriber(ObjectType::Table, Database::"SII Setup", 'OnBeforeValidateEnabled', '', false, false)]
    local procedure OnBeforeValidateEnabled(var SIISetup: Record "SII Setup"; var IsHandled: Boolean)
    var
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        if not VerifactuSetup.IsEnabled() then
            exit;

        if not SIISetup.Enabled then
            exit;

        if ConfirmMgt.GetResponseOrDefault(DisableVerifactuQst, false) then begin
            VerifactuSetup.Enabled := false;
            VerifactuSetup.Modify(true);
        end else begin
            IsHandled := true;
            SIISetup.Enabled := false;
        end;
    end;
}