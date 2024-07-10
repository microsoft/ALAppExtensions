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
                FetchEDocumentAndService(EDocument, EDocumentService, EDocumentServiceStatus);

                HandleResponse(EDocument, EDocumentService, EDocumentServiceStatus);

                WorkflowManagement.HandleEventOnKnownWorkflowInstance(EDocumentWorkflowSetup.EDocStatusChanged(), EDocument, EDocument."Workflow Step Instance ID");

            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure FetchEDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    begin
        EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code");
        EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
    end;

    local procedure HandleResponse(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status")
    var
#if not CLEAN25
        EDocumentServiceStatus2: Record "E-Document Service Status";
#endif
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        ErrorCount: Integer;
        GotResponse, NoNewErrorsInGetResponse : Boolean;
#if not CLEAN25
        IsHandled: Boolean;
#endif
    begin
        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        GotResponse := GetResponse(EDocumentService, EDocumentServiceStatus, HttpRequest, HttpResponse);
        NoNewErrorsInGetResponse := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

        if NoNewErrorsInGetResponse then
            if GotResponse then
                EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Sent, 0, HttpRequest, HttpResponse)
#if not CLEAN25
                    else begin
                        OnGetEdocumentResponseReturnsFalse(EDocument, EDocumentService, HttpRequest, HttpResponse, IsHandled);
                        if not IsHandled then
                            EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Pending Response", 0, HttpRequest, HttpResponse)
                        else begin
                            EDocumentServiceStatus2.Get(EDocument."Entry No", EDocumentService.Code);
                            EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, EDocumentServiceStatus2.Status, 0, HttpRequest, HttpResponse);
                            EDocumentLog.UpdateServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus2.Status);
                        end;
                    end
#else
            else
                EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Pending Response", 0, HttpRequest, HttpResponse)
#endif
        else
            EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Sending Error", 0, HttpRequest, HttpResponse);
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
        if not EDocumentResponse.Run() then begin
            EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
        end;
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

#if NOT CLEAN25
    [Obsolete('OnGetEdocumentResponseReturnsFalse is removed since framework now counts error to detect failure in GetResponse', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnGetEdocumentResponseReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;
#endif
}