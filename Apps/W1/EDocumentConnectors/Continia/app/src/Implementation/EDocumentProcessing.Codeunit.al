// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Send;
using System.Telemetry;
using System.Utilities;

codeunit 6391 "EDocument Processing"
{
    Access = Internal;

    internal procedure SendEDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        ApiRequests: Codeunit "Api Requests";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported:
                ApiRequests.SendDocument(EDocument, SendContext);
            EDocumentServiceStatus.Status::"Sending Error":
                if EDocument."Document Id" = '' then
                    ApiRequests.SendDocument(EDocument, SendContext);
        end;

        FeatureTelemetry.LogUptake('', ExternalServiceTok, Enum::"Feature Uptake Status"::Used);
    end;

    internal procedure GetTechnicalResponse(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        ApiRequests: Codeunit "Api Requests";
    begin
        ApiRequests.SetSuppressError(true);

        exit(ApiRequests.GetTechnicalResponse(EDocument, SendContext));
    end;

    internal procedure GetLastDocumentBusinessResponses(var EDocument: Record "E-Document"; ActionContext: Codeunit ActionContext) Updated: Boolean
    var
        ApiRequests: Codeunit "Api Requests";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        DocumentGuid: Guid;
        Success: Boolean;
        StatusDescription: Text;
    begin
        Evaluate(DocumentGuid, EDocument."Document Id");

        ApiRequests.SetSuppressError(true);
        Success := ApiRequests.GetBusinessResponses(DocumentGuid, ActionContext);
        if not Success then
            exit(false);

        if IsDocumentApproved(ActionContext.Http().GetHttpResponseMessage()) then begin
            ActionContext.Status().SetStatus(Enum::"E-Document Service Status"::Approved);
            exit(true);
        end;

        if IsDocumentRejected(ActionContext.Http().GetHttpResponseMessage(), StatusDescription) then begin
            ActionContext.Status().SetStatus(Enum::"E-Document Service Status"::Rejected);
            if StatusDescription <> '' then
                EDocumentErrorHelper.LogWarningMessage(EDocument, EDocument, EDocument."Entry No", StatusDescription);
            exit(true);
        end;
    end;

    local procedure IsDocumentApproved(HttpResponse: HttpResponseMessage): Boolean
    var
        ResponseCode: Text;
        StatusDescription: Text;
        BusinessResponses: XmlNodeList;
        BusinessResponseNode: XmlNode;
        i: Integer;
        IsApproved: Boolean;
    begin
        if not GetBusinessResponses(HttpResponse, BusinessResponses) then
            exit(false);

        for i := 1 to BusinessResponses.Count do begin
            BusinessResponses.Get(i, BusinessResponseNode);
            ResponseCode := GetResponseCodeFromBusinessResponse(BusinessResponseNode, StatusDescription);
            if IsResponseCodeRejected(ResponseCode) then
                exit(false);

            if IsResponseCodeApproved(ResponseCode) then
                IsApproved := true;
        end;

        exit(IsApproved);
    end;

    local procedure IsDocumentRejected(HttpResponse: HttpResponseMessage; var StatusDescription: Text): Boolean
    var
        BusinessResponses: XmlNodeList;
        BusinessResponseNode: XmlNode;
        ResponseCode: Text;
        i: Integer;
    begin
        if not GetBusinessResponses(HttpResponse, BusinessResponses) then
            exit(false);

        for i := 1 to BusinessResponses.Count do begin
            BusinessResponses.Get(i, BusinessResponseNode);
            ResponseCode := GetResponseCodeFromBusinessResponse(BusinessResponseNode, StatusDescription);
            if IsResponseCodeRejected(ResponseCode) then
                exit(true);
        end;
    end;

    local procedure GetResponseCodeFromBusinessResponse(BusinessResponseNode: XmlNode; var StatusDescription: Text) ResponseCode: Text
    var
        TempNode: XmlNode;
        Reason: Text;
        ReasonCode: Text;
    begin
        if BusinessResponseNode.SelectSingleNode('response_code', TempNode) then
            ResponseCode := TempNode.AsXmlElement().InnerText;

        if BusinessResponseNode.SelectSingleNode('reason_code', TempNode) then
            ReasonCode := TempNode.AsXmlElement().InnerText;

        if BusinessResponseNode.SelectSingleNode('reason', TempNode) then
            Reason := TempNode.AsXmlElement().InnerText;

        if (ReasonCode = '') and (Reason = '') then begin
            if IsResponseCodeRejected(ResponseCode) then
                StatusDescription := UnknownRejectionReasonErr
        end else
            StatusDescription := StrSubstNo(ReasonLbl, ReasonCode, Reason);
    end;

    local procedure GetBusinessResponses(HttpResponse: HttpResponseMessage; var BusinessResponses: XmlNodeList): Boolean
    var
        ResponseBody: Text;
        ResponseXmlDoc: XmlDocument;
    begin
        HttpResponse.Content.ReadAs(ResponseBody);
        if ResponseBody = '' then
            exit(false);

        XmlDocument.ReadFrom(ResponseBody, ResponseXmlDoc);

        if not ResponseXmlDoc.SelectNodes('/document_business_responses/document_business_response', BusinessResponses) then
            exit(false);

        exit(BusinessResponses.Count > 0)
    end;

    local procedure IsResponseCodeApproved(ResponseCode: Text): Boolean
    begin
        exit(ResponseCode in ['AP', 'CA', 'PD', 'BusinessAccept']);
    end;

    local procedure IsResponseCodeRejected(ResponseCode: Text): Boolean
    begin
        exit(ResponseCode in ['RE', 'BusinessReject']);
    end;

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; ReceivedEDocuments: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        TempBlob: Codeunit "Temp Blob";
        ApiRequests: Codeunit "Api Requests";
        OutStream: OutStream;
        ContentData: Text;
        DocumentResponse: XmlDocument;
        DocumentNodeList: XmlNodeList;
        DocumentNode: XmlNode;
        i: Integer;
    begin
        if not ApiRequests.GetDocumentsForCompany(ReceiveContext) then
            exit;

        ReceiveContext.Http().GetHttpResponseMessage().Content.ReadAs(ContentData);

        if not XmlDocument.ReadFrom(ContentData, DocumentResponse) then
            exit;

        if not DocumentResponse.SelectNodes('/documents/document', DocumentNodeList) then
            exit;

        for i := 1 to DocumentNodeList.Count do begin
            DocumentNodeList.Get(i, DocumentNode);
            // Check if the document should be processed with current EDocumentService
            if DocumentSupportedByEDocumentService(EDocumentService, DocumentNode) then begin
                Clear(TempBlob);
                TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
                DocumentNode.WriteTo(OutStream);
                ReceivedEDocuments.Add(TempBlob);
            end;
        end;
    end;

    local procedure DocumentSupportedByEDocumentService(EDocumentService: Record "E-Document Service"; DocumentNode: XmlNode): Boolean
    var
        ActivatedNetworkProfile: Record "Activated Net. Prof.";
        ParticipationProfileIdNode: XmlNode;
        ParticipationNetworkProfileId: Guid;
    begin
        DocumentNode.SelectSingleNode('participation_profile_id', ParticipationProfileIdNode);
        Evaluate(ParticipationNetworkProfileId, ParticipationProfileIdNode.AsXmlElement().InnerText);

        ActivatedNetworkProfile.SetCurrentKey(Id);
        ActivatedNetworkProfile.SetRange(Id, ParticipationNetworkProfileId);
        if not ActivatedNetworkProfile.FindFirst() then
            exit(false);

        if EDocumentService.Code = ActivatedNetworkProfile."E-Document Service Code" then
            exit(true);
    end;

    procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        ApiRequests: Codeunit "Api Requests";
        XMLFileToken: Text;
        XmlDocNode: XmlNode;
        XMLFileTokenNode: XmlNode;
        XMLDocumentIdNode: XmlNode;
        InStream: InStream;
        DocumentInfoXml: XmlDocument;
        CurrentEDocumentNode: XmlNode;
    begin
        DocumentMetadata.CreateInStream(InStream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(InStream, DocumentInfoXml);
        DocumentInfoXml.SelectSingleNode('document', CurrentEDocumentNode);

        CurrentEDocumentNode.SelectSingleNode('document_id', XMLDocumentIdNode);
        EDocument."Document Id" := CopyStr(XMLDocumentIdNode.AsXmlElement().InnerText, 1, MaxStrLen(EDocument."Document Id"));
        EDocument.Modify();

        CurrentEDocumentNode.SelectSingleNode('xml_document', XmlDocNode);
        XmlDocNode.SelectSingleNode('file_token', XMLFileTokenNode);
        XMLFileToken := XMLFileTokenNode.AsXmlElement().InnerText;

        // Download XML file from XMLFileToken and save to TempBlob
        ApiRequests.DownloadFileFromUrl(XMLFileToken, ReceiveContext);
    end;

    internal procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        ApiRequests: Codeunit "Api Requests";
        DocumentId: Guid;
    begin
        // Mark document as processed in Continia Online
        Evaluate(DocumentId, EDocument."Document Id");
        ApiRequests.MarkDocumentAsProcessed(DocumentId, ReceiveContext);
    end;

    procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext) Success: Boolean
    var
        ApiRequests: Codeunit "Api Requests";
        DocumentId: Guid;
    begin
        Evaluate(DocumentId, EDocument."Document Id");
        exit(ApiRequests.CancelDocument(DocumentId, ActionContext));
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnAfterValidateEvent, "Service Integration V2", true, true)]
    local procedure OnAfterValidateServiceIntegration(var Rec: Record "E-Document Service")
    begin
        if Rec."Service Integration V2" <> Rec."Service Integration V2"::Continia then
            exit;

        if Rec."Document Format" = Rec."Document Format"::"Data Exchange" then
            Error(DocumentFormatUnsupportedErr);
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnAfterValidateEvent, "Export Format", true, true)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service")
    begin
        if Rec."Service Integration V2" <> Rec."Service Integration V2"::Continia then
            exit;

        if Rec."Document Format" = Rec."Document Format"::"Data Exchange" then
            Error(DocumentFormatUnsupportedErr);
    end;

    var
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
        UnknownRejectionReasonErr: Label 'Unknown rejection reason';
        ReasonLbl: Label 'Reason: %1 - %2', Comment = '%1 - Reason code, %2 - Reason description';
        DocumentFormatUnsupportedErr: Label 'Data Exchange is not supported with the Continia Service Integration in this version';
}