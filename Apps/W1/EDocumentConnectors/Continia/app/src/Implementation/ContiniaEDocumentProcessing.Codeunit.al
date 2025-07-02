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

codeunit 6391 "Continia EDocument Processing"
{
    Access = Internal;

    internal procedure SendEDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        ApiRequests: Codeunit "Continia Api Requests";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported:
                ApiRequests.SendDocument(EDocument, SendContext);
            EDocumentServiceStatus.Status::"Sending Error":
                if IsNullGuid(EDocument."Continia Document Id") then
                    ApiRequests.SendDocument(EDocument, SendContext);
        end;

        FeatureTelemetry.LogUptake('0000PCW', ExternalServiceTok, Enum::"Feature Uptake Status"::Used);
    end;

    internal procedure GetTechnicalResponse(var EDocument: Record "E-Document"; SendContext: Codeunit SendContext): Boolean
    var
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        ApiRequests.SetSuppressError(true);

        exit(ApiRequests.GetTechnicalResponse(EDocument, SendContext));
    end;

    internal procedure GetLastDocumentBusinessResponses(var EDocument: Record "E-Document"; ActionContext: Codeunit ActionContext) Updated: Boolean
    var
        ApiRequests: Codeunit "Continia Api Requests";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        Success: Boolean;
        StatusDescription: Text;
    begin
        ApiRequests.SetSuppressError(true);
        Success := ApiRequests.GetBusinessResponses(EDocument."Continia Document Id", ActionContext);
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

    internal procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; ReceivedEDocuments: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        ActivatedNetworkProfile: Record "Continia Activated Net. Prof.";
    begin
        ActivatedNetworkProfile.SetRange("E-Document Service Code", EDocumentService.Code);
        if not ActivatedNetworkProfile.FindSet() then
            exit;
        repeat
            ReceiveNetworkProfileDocuments(ActivatedNetworkProfile, ReceivedEDocuments, ReceiveContext);
        until ActivatedNetworkProfile.Next() = 0;
    end;

    local procedure ReceiveNetworkProfileDocuments(ActivatedNetworkProfile: Record "Continia Activated Net. Prof."; ReceivedEDocuments: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        ApiRequests: Codeunit "Continia Api Requests";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        ContentData: Text;
        DocumentResponse: XmlDocument;
        DocumentNodeList: XmlNodeList;
        DocumentNode: XmlNode;
        i: Integer;
    begin
        if not ApiRequests.GetDocuments(ActivatedNetworkProfile, ReceiveContext) then
            exit;

        ReceiveContext.Http().GetHttpResponseMessage().Content.ReadAs(ContentData);

        if not XmlDocument.ReadFrom(ContentData, DocumentResponse) then
            exit;

        if not DocumentResponse.SelectNodes('/documents/document', DocumentNodeList) then
            exit;

        for i := 1 to DocumentNodeList.Count do begin
            DocumentNodeList.Get(i, DocumentNode);
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
            DocumentNode.WriteTo(OutStream);
            ReceivedEDocuments.Add(TempBlob);
        end;
    end;

    internal procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        ApiRequests: Codeunit "Continia Api Requests";
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
        Evaluate(EDocument."Continia Document Id", XMLDocumentIdNode.AsXmlElement().InnerText);
        EDocument.Modify();

        CurrentEDocumentNode.SelectSingleNode('xml_document', XmlDocNode);
        XmlDocNode.SelectSingleNode('file_token', XMLFileTokenNode);
        XMLFileToken := XMLFileTokenNode.AsXmlElement().InnerText;

        // Download XML file from XMLFileToken and save to TempBlob
        ApiRequests.DownloadFileFromUrl(XMLFileToken, ReceiveContext);
    end;

    internal procedure MarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        // Mark document as processed in Continia Online
        ApiRequests.MarkDocumentAsProcessed(EDocument."Continia Document Id", ReceiveContext);
    end;

    internal procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext) Success: Boolean
    var
        ApiRequests: Codeunit "Continia Api Requests";
    begin
        exit(ApiRequests.CancelDocument(EDocument."Continia Document Id", ActionContext));
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnAfterValidateEvent, "Service Integration V2", true, true)]
    local procedure OnAfterValidateServiceIntegration(var Rec: Record "E-Document Service")
    begin
        if Rec."Service Integration V2" <> Rec."Service Integration V2"::Continia then
            exit;
    end;

    [EventSubscriber(ObjectType::Page, Page::"E-Document Service", OnAfterValidateEvent, "Export Format", true, true)]
    local procedure OnAfterValidateDocumentFormat(var Rec: Record "E-Document Service")
    begin
        if Rec."Service Integration V2" <> Rec."Service Integration V2"::Continia then
            exit;
    end;

    var
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
        UnknownRejectionReasonErr: Label 'Unknown rejection reason';
        ReasonLbl: Label 'Reason: %1 - %2', Comment = '%1 - Reason code, %2 - Reason description';
}