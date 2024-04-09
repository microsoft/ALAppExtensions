// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
using System.Telemetry;
using System.Threading;

codeunit 6144 "E-Document Get Response"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        EDocumentServiceStatus, EDocumentServiceStatus2 : Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        EDocumentLog: Codeunit "E-Document Log";
        WorkflowManagement: Codeunit "Workflow Management";
        EDocumentWorkflowSetup: Codeunit "E-Document Workflow Setup";
        EDocumentBackgroundjobs: Codeunit "E-Document Background jobs";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        IsHandled: Boolean;
    begin
        if not IsEDocumentPendingResponse() then
            exit;

        EdocumentServiceStatus.SetRange(Status, EdocumentServiceStatus.Status::"Pending Response");
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code");
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");

                if GetResponse(EDocumentService, EDocumentServiceStatus, HttpRequest, HttpResponse) then
                    EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Sent, 0, HttpRequest, HttpResponse)
                else begin
                    OnGetEdocumentResponseReturnsFalse(EDocument, EDocumentService, HttpRequest, HttpResponse, IsHandled);
                    if not IsHandled then
                        EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Pending Response", 0, HttpRequest, HttpResponse)
                    else begin
                        EDocumentServiceStatus2.Get(EDocument."Entry No", EDocumentService.Code);
                        EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, EDocumentServiceStatus2.Status, 0, HttpRequest, HttpResponse);
                        EDocumentLog.UpdateServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus2.Status);
                    end;
                end;

                WorkflowManagement.HandleEventOnKnownWorkflowInstance(EDocumentWorkflowSetup.EDocStatusChanged(), EDocument, EDocument."Workflow Step Instance ID");

            until EDocumentServiceStatus.Next() = 0;

        if IsEDocumentPendingResponse() then
            EDocumentBackgroundjobs.GetEDocumentResponse(false);
    end;

    local procedure GetResponse(EDocService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage) GetResponseResult: Boolean
    var
        EDocument: Record "E-Document";
        EDocumentResponse: Codeunit "E-Document Response";
        EDocumentHelper: Codeunit "E-Document Processing";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit before create document with error handling
        Commit();
        EDocumentHelper.GetTelemetryDimensions(EDocService, EDocumentServiceStatus, TelemetryDimensions);
        Telemetry.LogMessage('0000LBQ', EDocTelemetryGetResponseScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        Clear(EDocumentResponse);
        EDocumentResponse.SetSource(EDocService, EDocumentServiceStatus, HttpRequest, HttpResponse);
        if not EDocumentResponse.Run() then
            if EDocumentServiceStatus.FindSet() then
                repeat
                    EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                    EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
                until EDocumentServiceStatus.Next() = 0;

        EDocumentResponse.GetRequestResponse(HttpRequest, HttpResponse);
        GetResponseResult := EDocumentResponse.GetResponseResult();
        Telemetry.LogMessage('0000LBR', EDocTelemetryGetResponseScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure IsEDocumentPendingResponse(): Boolean
    var
        EdocumentServiceStatus: Record "E-Document Service Status";
    begin
        EdocumentServiceStatus.SetRange(Status, EdocumentServiceStatus.Status::"Pending Response");
        exit(not EdocumentServiceStatus.IsEmpty());
    end;

    var
        Telemetry: Codeunit Telemetry;
        EDocTelemetryGetResponseScopeStartLbl: Label 'E-Document Get Response: Start Scope', Locked = true;
        EDocTelemetryGetResponseScopeEndLbl: Label 'E-Document Get Response: End Scope', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnGetEdocumentResponseReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;
}