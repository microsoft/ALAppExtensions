// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Integration.Send;
using System.Automation;
using System.Telemetry;
using System.Threading;

codeunit 6144 "E-Document Get Response"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata "E-Document" = rm,
                    tabledata "E-Document Service" = r,
                    tabledata "E-Document Service Status" = r;

    trigger OnRun()
    var
        EDocumentBackgroundjobs: Codeunit "E-Document Background jobs";
    begin
        if not IsEDocumentPendingResponse() then
            exit;

        ProcessPendingResponseDocuments();

        if IsEDocumentPendingResponse() then
            EDocumentBackgroundjobs.ScheduleGetResponseJob(false);
    end;

    local procedure ProcessPendingResponseDocuments()
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        WorkflowManagement: Codeunit "Workflow Management";
        EDocumentWorkflowSetup: Codeunit "E-Document Workflow Setup";
    begin
        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::"Pending Response");
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code");
                HandleResponse(EDocument, EDocumentService, EDocumentServiceStatus);

                WorkflowManagement.HandleEventOnKnownWorkflowInstance(EDocumentWorkflowSetup.EDocStatusChanged(), EDocument, EDocument."Workflow Step Instance ID");

            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure HandleResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
        SendContext: Codeunit SendContext;
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocServiceStatus: Enum "E-Document Service Status";
        ErrorCount: Integer;
        GotResponse, Success : Boolean;
    begin
        // Set default status value
        SendContext.Status().SetStatus(Enum::"E-Document Service Status"::Sent);

        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        GotResponse := RunGetResponse(EDocument, EDocumentService, EDocumentServiceStatus, SendContext);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

#if not CLEAN25
        EDocServiceStatus := GetServiceStatusFromResponse(
            Success,
            GotResponse,
            EDocument,
            EDocumentService,
            SendContext
        );
#else 
        EDocServiceStatus := GetServiceStatusFromResponse(
            Success,
            GotResponse,
            SendContext
        );
#endif

        EDocumentLog.InsertLog(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage());
        EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);
    end;

#if not CLEAN25
    local procedure GetServiceStatusFromResponse(Success: Boolean; GotResponse: Boolean; var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext) EDocServiceStatus: Enum "E-Document Service Status";
    var
        EDocumentServiceStatus2: Record "E-Document Service Status";
        IsHandled: Boolean;
    begin
        if not Success then
            exit(Enum::"E-Document Service Status"::"Sending Error");

        if GotResponse then
            exit(SendContext.Status().GetStatus())
        else begin
            OnGetEdocumentResponseReturnsFalse(EDocument, EDocumentService, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage(), IsHandled);
            if not IsHandled then
                EDocServiceStatus := Enum::"E-Document Service Status"::"Pending Response"
            else begin
                EDocumentServiceStatus2.Get(EDocument."Entry No", EDocumentService.Code);
                EDocServiceStatus := EDocumentServiceStatus2.Status;
            end;
        end

    end;
#else
    local procedure GetServiceStatusFromResponse(Success: Boolean; GotResponse: Boolean; SendContext: Codeunit SendContext): Enum "E-Document Service Status";
    begin
        if not Success then
            exit(Enum::"E-Document Service Status"::"Sending Error");

        if GotResponse then
            exit(SendContext.Status().GetStatus())
        else
            exit(Enum::"E-Document Service Status"::"Pending Response");
    end;
#endif

    local procedure RunGetResponse(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status"; SendContext: Codeunit SendContext) Result: Boolean
    var
        GetResponseRunner: Codeunit "Get Response Runner";
        EDocumentHelper: Codeunit "E-Document Processing";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern.
        Commit();
        EDocumentHelper.GetTelemetryDimensions(EDocService, EDocumentServiceStatus, TelemetryDimensions);
        Telemetry.LogMessage('0000LBQ', EDocTelemetryGetResponseScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        GetResponseRunner.SetDocumentAndService(EDocument, EDocService);
        GetResponseRunner.SetContext(SendContext);
        if not GetResponseRunner.Run() then begin
            EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
        end;

        GetResponseRunner.GetDocumentAndService(EDocument, EDocService);
        Result := GetResponseRunner.GetResponseResult();

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
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocTelemetryGetResponseScopeStartLbl: Label 'E-Document Get Response: Start Scope', Locked = true;
        EDocTelemetryGetResponseScopeEndLbl: Label 'E-Document Get Response: End Scope', Locked = true;

#if not CLEAN25
    [Obsolete('OnGetEdocumentResponseReturnsFalse is removed since framework now counts error to detect failure in GetResponse', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnGetEdocumentResponseReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;
#endif
}