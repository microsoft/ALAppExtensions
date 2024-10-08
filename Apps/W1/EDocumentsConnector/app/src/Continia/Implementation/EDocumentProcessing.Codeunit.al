// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;
using Microsoft.eServices.EDocument;
using Microsoft.EServices.EDocumentConnector;
using System.Utilities;
using System.Telemetry;

codeunit 6391 "EDocument Processing"
{
    Access = Internal;
    internal procedure SendEDocument(EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EdocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
        APIRequests: Codeunit "API Requests";
        EDocumentHelper: Codeunit "E-Document Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin

        EDocumentHelper.GetEdocumentService(EDocument, EdocumentService);
        EDocumentServiceStatus.Get(EDocument."Entry No", EdocumentService.Code);

        case EDocumentServiceStatus.Status of
            EDocumentServiceStatus.Status::Exported:
                APIRequests.SendDocument(EDocument, TempBlob, HttpRequest, HttpResponse);
            EDocumentServiceStatus.Status::"Sending Error":
                if EDocument."Document Id" = '' then
                    APIRequests.SendDocument(EDocument, TempBlob, HttpRequest, HttpResponse);
        end;

        FeatureTelemetry.LogUptake('', ExternalServiceTok, Enum::"Feature Uptake Status"::Used);
    end;

    internal procedure GetTechnicalResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        APIRequests: Codeunit "API Requests";
    begin
        APIRequests.SetSupressError(true);

        exit(APIRequests.GetTechnicalResponse(EDocument, HttpRequest, HttpResponse));
    end;

    internal procedure GetLastDocumentBusinessResponses(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean
    var
        APIRequests: Codeunit "API Requests";
        DocumentGUID: Guid;
    begin
        Evaluate(DocumentGUID, EDocument."Document Id");

        APIRequests.SetSupressError(true);
        if not APIRequests.GetBusinessResponses(DocumentGUID, HttpRequest, HttpResponse) then
            exit(false);

        exit(IsDocumentApproved(HttpResponse));
    end;

    local procedure IsDocumentApproved(var HttpResponse: HttpResponseMessage): Boolean
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

    local procedure IsDocumentRejected(var HttpResponse: HttpResponseMessage; var StatusDescription: Text): Boolean
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

    local procedure GetBusinessResponses(var HttpResponse: HttpResponseMessage; var BusinessResponses: XmlNodeList): Boolean
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Management", 'OnGetEDocumentApprovalReturnsFalse', '', false, false)]
    local procedure OnGetEDocumentApprovalReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        StatusDescription: Text;
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Continia then
            exit;

        if IsDocumentRejected(HttpResponse, StatusDescription) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocuments, StatusDescription);
            exit;
        end;

        EDocumentLogHelper.InsertIntegrationLog(EDocuments, EDocumentService, HttpRequest, HttpResponse);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", 'OnAfterInsertImportedEdocument', '', false, false)]
    local procedure OnAfterInsertImportedEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        APIRequests: Codeunit "API Requests";
        EDocumentLogHelper: Codeunit "E-Document Log Helper";
        ContentData: Text;
        XMLFileToken: Text;
        DocumentResponse: XmlDocument;
        CurrentEDocumentNode: XmlNode;
        XmlDocNode: XmlNode;
        XMLFileTokenNode: XmlNode;
        XMLDocumentIdNode: XmlNode;
        DocumentId: Guid;
        DocumentXMLPathLbl: Label '/documents/document[%1]', Locked = true;
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Continia then
            exit;

        HttpResponse.Content.ReadAs(ContentData);

        XmlDocument.ReadFrom(ContentData, DocumentResponse);
        if EDocument."Index In Batch" = 0 then
            DocumentResponse.SelectSingleNode(StrSubstNo(DocumentXMLPathLbl, 1), CurrentEDocumentNode)
        else
            DocumentResponse.SelectSingleNode(StrSubstNo(DocumentXMLPathLbl, EDocument."Index In Batch"), CurrentEDocumentNode);

        CurrentEDocumentNode.SelectSingleNode('document_id', XMLDocumentIdNode);
        EDocument."Document Id" := CopyStr(XMLDocumentIdNode.AsXmlElement().InnerText, 1, MaxStrLen(EDocument."Document Id"));
        EDocument.Modify();

        CurrentEDocumentNode.SelectSingleNode('xml_document', XmlDocNode);
        XmlDocNode.SelectSingleNode('file_token', XMLFileTokenNode);
        XMLFileToken := XMLFileTokenNode.AsXmlElement().InnerText;

        // Download XML file from XMLFileToken and save to TempBlob
        APIRequests.DownloadFileFromURL(XMLFileToken, TempBlob);

        EDocumentLogHelper.InsertLog(EDocument, EDocumentService, TempBlob, "E-Document Service Status"::Imported);

        // Mark document as processed in Continia Online
        Evaluate(DocumentId, EDocument."Document Id");
        APIRequests.MarkDocumentAsProcessed(DocumentId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", 'OnBeforeInsertImportedEdocument', '', false, false)]
    local procedure OnBeforeInsertImportedEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsCreated: Boolean; var IsProcessed: Boolean)
    var
    begin
        if EDocumentService."Service Integration" <> EDocumentService."Service Integration"::Continia then
            exit;

        // Check if the document should be processed with current EDocumentService
        if not DocumentSupportedByEDocumentService(EDocument, EDocumentService, HttpResponse) then begin
            IsCreated := true;
            IsProcessed := true;
        end;
    end;

    local procedure DocumentSupportedByEDocumentService(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpResponse: HttpResponseMessage): Boolean
    var
        NetworkProfile: Record "Network Profile";
        ParticipationNetworkProfile: Record "Activated Net. Prof.";
        ContentData: Text;
        DocumentResponse: XmlDocument;
        DocumentXMLPathLbl: Label '/documents/document[%1]', Locked = true;
        CurrentEDocumentNode: XmlNode;
        ParticipationProfileIdNode: XmlNode;
        ParticipationNetworkProfileID: Guid;
    begin
        HttpResponse.Content.ReadAs(ContentData);

        XmlDocument.ReadFrom(ContentData, DocumentResponse);
        if EDocument."Index In Batch" = 0 then
            DocumentResponse.SelectSingleNode(StrSubstNo(DocumentXMLPathLbl, 1), CurrentEDocumentNode)
        else
            DocumentResponse.SelectSingleNode(StrSubstNo(DocumentXMLPathLbl, EDocument."Index In Batch"), CurrentEDocumentNode);

        CurrentEDocumentNode.SelectSingleNode('participation_profile_id', ParticipationProfileIdNode);
        Evaluate(ParticipationNetworkProfileID, ParticipationProfileIdNode.AsXmlElement().InnerText);

        ParticipationNetworkProfile.SetCurrentKey("CDN GUID");
        ParticipationNetworkProfile.SetRange("CDN GUID", ParticipationNetworkProfileID);
        if not ParticipationNetworkProfile.FindFirst() then
            exit(false);

        NetworkProfile.Get(ParticipationNetworkProfile."Network Profile ID");
        if not ProfileSupportedByEDocumentService(EDocumentService, NetworkProfile) then
            exit(false);
        exit(true);
    end;

    local procedure ProfileSupportedByEDocumentService(EDocumentService: Record "E-Document Service"; NetworkProfile: Record "Network Profile") IsSupported: Boolean
    begin

        // Check if Service Document Format supports this profile
        case GetDocumentFormatName(EDocumentService."Document Format") of
            'PEPPOL BIS 3.0':
                if NetworkProfile.Network = NetworkProfile.Network::peppol then
                    exit(true);
            'OIOUBL':
                if NetworkProfile.Network = NetworkProfile.Network::nemhandel then
                    exit(true);
            else
                exit(false);
        end;

        OnAfterProfileSupportedByEDocumentService(EDocumentService, NetworkProfile, IsSupported);
    end;

    local procedure GetDocumentFormatName(DocumentFormat: Enum "E-Document Format") DocumentFormatName: Text
    begin
        if not DocumentFormat.Names().Get(DocumentFormat.Ordinals().IndexOf(DocumentFormat.AsInteger()), DocumentFormatName) then
            exit('');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProfileSupportedByEDocumentService(EDocumentService: Record "E-Document Service"; NetworkProfile: Record "Network Profile"; var IsSupported: Boolean)
    begin

    end;

    var
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
        UnknownRejectionReasonErr: Label 'Unknown rejection reason';
        ReasonLbl: Label 'Reason: %1 - %2', Comment = '%1 - Reason code, %2 - Reason description';
}