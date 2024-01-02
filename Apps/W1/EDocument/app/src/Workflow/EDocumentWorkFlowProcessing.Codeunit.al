// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
using System.Telemetry;
using System.Utilities;

codeunit 6135 "E-Document WorkFlow Processing"
{
    Permissions =
        tabledata "E-Document" = m;

    internal procedure DoesFlowHasEDocService(var EDocServices: Record "E-Document Service"; WorkfLowCode: Code[20]): Boolean
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowStep: Record "Workflow Step";
        WorkFlow: Record Workflow;
        Filter: Text;
    begin
        WorkFlow.Get(WorkfLowCode);
        WorkflowStep.SetRange("Workflow Code", Workflow.Code);
        WorkflowStep.SetRange(Type, WorkflowStep.Type::Response);
        if WorkflowStep.FindSet() then
            repeat
                WorkflowStepArgument.Get(WorkflowStep.Argument);
                AddFilter(Filter, WorkflowStepArgument."E-Document Service");
            until WorkflowStep.Next() = 0;

        if Filter = '' then
            exit(false);

        EDocServices.SetFilter(Code, Filter);
        exit(true);
    end;

    internal procedure SendEDocument(var EDocument: Record "E-Document"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        EDocumentService: Record "E-Document Service";
    begin
        if not ValidateFlowStep(EDocument, WorkflowStepArgument, WorkflowStepInstance) then
            exit;
        EDocumentService.Get(WorkflowStepArgument."E-Document Service");
        SendEDocument(EDocument, EDocumentService);
    end;

    internal procedure SendEDocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        Telemetry: Codeunit Telemetry;
        EDocumentHelper: Codeunit "E-Document Processing";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        FeatureTelemetry.LogUptake('0000KZ7', EDocumentHelper.GetEDocTok(), Enum::"Feature Uptake Status"::Used);
        EDocumentHelper.GetTelemetryDimensions(EDocumentService, EDocument, TelemetryDimensions);
        Telemetry.LogMessage('0000LBB', EDocTelemetryProcessingStartScopeLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        if IsEdocServiceUsingBatch(EDocumentService) then
            DoBatchSend(EDocument, EDocumentService)
        else
            DoSend(EDocument, EDocumentService);

        FeatureTelemetry.LogUsage('0000KZ8', EDocumentHelper.GetEDocTok(), 'E-Document has been sent.');
        Telemetry.LogMessage('0000LBW', EDocTelemetryProcessingEndScopeLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    internal procedure HandleNextEvent(var EDocument: Record "E-Document")
    var
        WorkflowManagement: Codeunit "Workflow Management";
        EDocumentWorkflowSetup: Codeunit "E-Document Workflow Setup";
    begin
        // Commit before execute next workflow step
        Commit();

        if EDocument.Count() = 1 then
            WorkflowManagement.HandleEventOnKnownWorkflowInstance(EDocumentWorkflowSetup.EDocStatusChanged(), EDocument, EDocument."Workflow Step Instance ID")
        else begin
            EDocument.FindSet();
            repeat
                WorkflowManagement.HandleEventOnKnownWorkflowInstance(EDocumentWorkflowSetup.EDocStatusChanged(), EDocument, EDocument."Workflow Step Instance ID");
            until EDocument.Next() = 0;
        end;
    end;

    internal procedure AddFilter(var Filter: Text; Value: Text)
    begin
        if Value = '' then
            exit;

        if Filter = '' then
            Filter := Value
        else
            Filter := Filter + '|' + Value;
    end;

    local procedure DoBatchSend(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    var
        TempEDocMappingLogs: Record "E-Doc. Mapping Log" temporary;
        EDocExport: Codeunit "E-Doc. Export";
        EDocIntMgt: Codeunit "E-Doc. Integration Management";
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentBackgroundjobs: Codeunit "E-Document Background Jobs";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        TempBlob: Codeunit "Temp Blob";
        BeforeExportEDocErrorCount: Dictionary of [Integer, Integer];
        IsAsync, IsHandled, AnyErrors : Boolean;
        ErrorCount: Integer;
    begin
        EDocumentLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");

        if EDocumentService."Batch Mode" = EDocumentService."Batch Mode"::Recurrent then
            exit;
        if EDocumentService."Batch Mode" = EDocumentService."Batch Mode"::Threshold then begin
            if not IsThresholdBatchCriteriaMet(EDocumentService, EDocument) then
                exit;
        end else begin
            OnBatchSendWithCustomBatchMode(EDocument, EDocumentService, IsHandled);
            if not IsHandled then
                Error(NotSupportedBatchModeErr, EDocumentService."Batch Mode");
            exit;
        end;

        EDocExport.ExportEDocumentBatch(EDocument, EDocumentService, TempEDocMappingLogs, TempBlob, BeforeExportEDocErrorCount);

        AnyErrors := false;
        EDocument.FindSet();
        repeat
            BeforeExportEDocErrorCount.Get(EDocument."Entry No", ErrorCount);
            if (EDocumentErrorHelper.ErrorMessageCount(EDocument) > ErrorCount) then
                AnyErrors := true;
        until EDocument.Next() = 0;

        InsertLogsForThresholdBatch(EDocument, EDocumentService, TempEDocMappingLogs, TempBlob, AnyErrors);
        if not AnyErrors then begin
            EDocIntMgt.SendBatch(EDocument, EDocumentService, IsAsync);
            if IsAsync then
                EDocumentBackgroundjobs.GetEDocumentResponse()
            else
                HandleNextEvent(EDocument);
        end;
    end;

    local procedure InsertLogsForThresholdBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempEDocMappingLogs: Record "E-Doc. Mapping Log" temporary; var TempBlob: Codeunit "Temp Blob"; Error: Boolean)
    var
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocumentLogRecord: Record "E-Document Log";
        EDocumentLog: Codeunit "E-Document Log";
        EDocDataStorageEntryNo, EDocLogEntryNo : Integer;
    begin
        EDocument.FindSet();
        if Error then begin
            repeat
                EDocLogEntryNo := EDocumentLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Export Error");
            until EDocument.Next() = 0;
            exit;
        end;
        EDocDataStorageEntryNo := EDocumentLog.AddTempBlobToLog(TempBlob);
        repeat
            EDocLogEntryNo := EDocumentLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::Exported);
            TempEDocMappingLogs.SetRange("E-Doc Entry No.", EDocument."Entry No");
            if TempEDocMappingLogs.FindFirst() then begin
                EDocMappingLog.Copy(TempEDocMappingLogs);
                EDocMappingLog."Entry No." := 0;
                EDocMappingLog.Validate("E-Doc Log Entry No.", EDocLogEntryNo);
                EDocMappingLog.Insert();
            end;
            EDocumentLogRecord.Get(EDocLogEntryNo);
            EDocumentLog.SetDataStorage(EDocumentLogRecord, EDocDataStorageEntryNo);
        until EDocument.Next() = 0
    end;

    local procedure DoSend(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    var
        EDocExport: Codeunit "E-Doc. Export";
        EDocIntMgt: Codeunit "E-Doc. Integration Management";
        EDocumentBackgroundjobs: Codeunit "E-Document Background Jobs";
        IsAsync: Boolean;
    begin
        if EDocExport.ExportEDocument(EDocument, EDocumentService) then
            EDocIntMgt.Send(EDocument, EDocumentService, IsAsync);

        if IsAsync then
            EDocumentBackgroundjobs.GetEDocumentResponse()
        else
            HandleNextEvent(EDocument);
    end;

    local procedure ValidateFlowStep(var EDocument: Record "E-Document"; var WorkflowStepArgument: Record "Workflow Step Argument"; WorkflowStepInstance: Record "Workflow Step Instance"): Boolean
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
    begin
        WorkflowStepArgument.Get(WorkflowStepInstance.Argument);

        if WorkflowStepArgument."E-Document Service" = '' then begin
            EDocErrorHelper.LogErrorMessage(EDocument, WorkflowStepArgument, WorkflowStepArgument.FieldNo("E-Document Service"), 'E-Document Service must be specified in Workflow Argument');
            exit(false);
        end;
        if IsNullGuid(EDocument."Workflow Step Instance ID") then begin
            EDocument."Workflow Step Instance ID" := WorkflowStepInstance.ID;
            EDocument.Modify();
        end;
        exit(true);
    end;

    local procedure IsEdocServiceUsingBatch(EDocumentService: Record "E-Document Service"): Boolean
    begin
        exit(EDocumentService."Use Batch Processing");
    end;

    local procedure IsThresholdBatchCriteriaMet(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"): Boolean
    var
        EDocument2: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentListFilter: Text;
    begin
        if EDocumentService."Batch Mode" <> EDocumentService."Batch Mode"::Threshold then
            exit(false);

        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::"Pending Batch");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if EDocumentServiceStatus.FindSet() then begin
            repeat
                AddFilter(EDocumentListFilter, Format(EDocumentServiceStatus."E-Document Entry No"));
            until EDocumentServiceStatus.Next() = 0;

            EDocument2.SetFilter("Entry No", EDocumentListFilter);
            EDocument2.SetRange("Document Type", EDocument."Document Type");
            EDocument2.SetRange("Document Sending Profile", EDocument."Document Sending Profile");

            if EDocument2.Count() >= EDocumentService."Batch Threshold" then begin
                EDocument.CopyFilters(EDocument2);
                exit(true);
            end;
        end;
    end;

    var
        NotSupportedBatchModeErr: Label 'Batch Mode %1 is not supported in E-Document Framework.', Comment = '%1 - The batch mode enum value';
        EDocTelemetryProcessingStartScopeLbl: Label 'E-Document Processing: Start Scope', Locked = true;
        EDocTelemetryProcessingEndScopeLbl: Label 'E-Document Processing: End Scope', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnBatchSendWithCustomBatchMode(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var IsHandled: Boolean)
    begin
    end;
}