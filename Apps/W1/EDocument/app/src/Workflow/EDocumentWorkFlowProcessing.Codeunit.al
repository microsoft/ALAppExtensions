// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
using System.Telemetry;
using System.Utilities;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Service.History;
using Microsoft.Inventory.Transfer;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.Foundation.Reporting;

codeunit 6135 "E-Document WorkFlow Processing"
{
    Permissions =
        tabledata "E-Document" = m,
        tabledata "E-Doc. Mapping Log" = i;

    internal procedure IsServiceUsedInActiveWorkflow(EDocumentService: Record "E-Document Service"): Boolean
    var
        Workflow: Record Workflow;
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        Workflow.SetRange(Enabled, true);
        if Workflow.FindSet() then
            repeat
                WorkflowStep.SetRange("Workflow Code", Workflow.Code);
                if WorkflowStep.FindSet() then
                    repeat
                        if WorkflowStepArgument.Get(WorkflowStep.Argument) then
                            if WorkflowStepArgument."E-Document Service" = EDocumentService.Code then
                                exit(true);
                    until WorkflowStep.Next() = 0;
            until Workflow.Next() = 0;
    end;

    internal procedure SendEDocFromEmail(var RecordRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance"; Attachment: Enum "Document Sending Profile Attachment Type")
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        WorkflowStepArgument: Record "Workflow Step Argument";
        EDocument: Record "E-Document";
        DocumentSendingProfile: Record "Document Sending Profile";
        ReportSelections: Record "Report Selections";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        ReportUsage: Enum "Report Selection Usage";
        CustomerNo, DocumentNo : Code[20];
        DocumentTypeText: Text[150];
        Variant: Variant;
    begin
        if not GetEDocumentFromRecordRef(RecordRef, EDocument) then
            exit;

        // We don't validate arguments for email sending steps
        if not ValidateFlowStep(EDocument, WorkflowStepArgument, WorkflowStepInstance, false) then
            exit;

        // Set for attachments creation
        DocumentSendingProfile.Get(EDocument."Document Sending Profile");
        DocumentSendingProfile."E-Mail" := DocumentSendingProfile."E-Mail"::"Yes (Use Default Settings)";
        DocumentSendingProfile."E-Mail Attachment" := Attachment;

        case EDocument."Document Type" of
            Enum::"E-Document Type"::None:
                Error(CannotSendEDocWithoutTypeErr);
            Enum::"E-Document Type"::"Sales Invoice":
                begin

                    if not SalesInvHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Sales Invoice", EDocument."Document No.");

                    SalesInvHeader.SetRecFilter();
                    Variant := SalesInvHeader;
                    ReportUsage := ReportSelections.Usage::"S.Invoice";
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(SalesInvHeader);
                    DocumentNo := SalesInvHeader."No.";
                    CustomerNo := SalesInvHeader."Bill-to Customer No.";
                end;
            Enum::"E-Document Type"::"Sales Credit Memo":
                begin
                    if not SalesCrMemoHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Sales Credit Memo", EDocument."Document No.");

                    SalesCrMemoHeader.SetRecFilter();
                    Variant := SalesCrMemoHeader;
                    ReportUsage := ReportSelections.Usage::"S.Cr.Memo";
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(SalesCrMemoHeader);
                    DocumentNo := SalesCrMemoHeader."No.";
                    CustomerNo := SalesCrMemoHeader."Bill-to Customer No.";
                end;
            Enum::"E-Document Type"::"Issued Reminder":
                begin
                    if not IssuedReminderHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Issued Reminder", EDocument."Document No.");

                    IssuedReminderHeader.SetRecFilter();
                    Variant := IssuedReminderHeader;
                    ReportUsage := ReportSelections.Usage::Reminder;
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(IssuedReminderHeader);
                    DocumentNo := IssuedReminderHeader."No.";
                    CustomerNo := IssuedReminderHeader."Customer No.";
                end;
            Enum::"E-Document Type"::"Issued Finance Charge Memo":
                begin
                    if not IssuedFinChargeMemoHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Issued Finance Charge Memo", EDocument."Document No.");

                    IssuedFinChargeMemoHeader.SetRecFilter();
                    Variant := IssuedFinChargeMemoHeader;
                    ReportUsage := ReportSelections.Usage::"Fin.Charge";
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(IssuedFinChargeMemoHeader);
                    DocumentNo := IssuedFinChargeMemoHeader."No.";
                    CustomerNo := IssuedFinChargeMemoHeader."Customer No.";
                end;
            Enum::"E-Document Type"::"Service Invoice":
                begin
                    if not ServiceInvoiceHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Service Invoice", EDocument."Document No.");

                    ServiceInvoiceHeader.SetRecFilter();
                    Variant := ServiceInvoiceHeader;
                    ReportUsage := ReportSelections.Usage::"SM.Invoice";
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(ServiceInvoiceHeader);
                    DocumentNo := ServiceInvoiceHeader."No.";
                    CustomerNo := ServiceInvoiceHeader."Bill-to Customer No.";
                end;
            Enum::"E-Document Type"::"Service Credit Memo":
                begin
                    if not ServiceCrMemoHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Service Credit Memo", EDocument."Document No.");

                    ServiceCrMemoHeader.SetRecFilter();
                    Variant := ServiceCrMemoHeader;
                    ReportUsage := ReportSelections.Usage::"SM.Credit Memo";
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(ServiceCrMemoHeader);
                    DocumentNo := ServiceCrMemoHeader."No.";
                    CustomerNo := ServiceCrMemoHeader."Bill-to Customer No.";
                end;
            Enum::"E-Document Type"::"Sales Shipment":
                begin
                    if not SalesShipmentHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Sales Shipment", EDocument."Document No.");

                    SalesShipmentHeader.SetRecFilter();
                    Variant := SalesShipmentHeader;
                    ReportUsage := ReportSelections.Usage::"S.Shipment";
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(SalesShipmentHeader);
                    DocumentNo := SalesShipmentHeader."No.";
                    CustomerNo := SalesShipmentHeader."Bill-to Customer No.";
                end;
            Enum::"E-Document Type"::"Transfer Shipment":
                begin
                    if not TransferShipmentHeader.Get(EDocument."Document Record ID") then
                        Error(CannotFindEDocErr, Enum::"E-Document Type"::"Transfer Shipment", EDocument."Document No.");

                    TransferShipmentHeader.SetRecFilter();
                    Variant := TransferShipmentHeader;
                    ReportUsage := ReportSelections.Usage::Inv2;
                    DocumentTypeText := ReportDistributionMgt.GetFullDocumentTypeText(TransferShipmentHeader);
                    DocumentNo := TransferShipmentHeader."No.";
                    CustomerNo := TransferShipmentHeader."Transfer-to Code";
                end;

            else
                Error(NotSupportedEDocTypeErr, EDocument."Document Type");
        end;

        EDocumentProcessing.ProcessEDocumentAsEmail(DocumentSendingProfile, ReportUsage, Variant, DocumentNo, DocumentTypeText, CustomerNo, false);
    end;

    internal procedure GetEDocumentServiceFromPreviousSendOrExportResponse(WorkflowStepInstance: Record "Workflow Step Instance"; var EDocumentService: Record "E-Document Service"): Boolean
    var
        PrevWorkflowStepInstance: Record "Workflow Step Instance";
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowManagement: Codeunit "Workflow Management";
        EDocumentWorkflowSetup: Codeunit "E-Document Workflow Setup";
        Telemetry: Codeunit Telemetry;
        NoEDocumentServiceFoundINPrevResponseLbl: Label 'No E-Document Service found in previous Send or Export response step in workflow.';
    begin
        PrevWorkflowStepInstance.SetFilter("Function Name", '%1|%2', EDocumentWorkflowSetup.EDocSendEDocResponseCode(), EDocumentWorkflowSetup.ResponseEDocExport());
        while WorkflowManagement.FindResponse(PrevWorkflowStepInstance, WorkflowStepInstance) do begin

            if WorkflowStepArgument.Get(PrevWorkflowStepInstance.Argument) then begin
                EDocumentService.SetRange(Code, WorkflowStepArgument."E-Document Service");
                if EDocumentService.IsEmpty() then begin
                    Telemetry.LogMessage('0000Q56', NoEDocumentServiceFoundINPrevResponseLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All);
                    exit(false);
                end;
                exit(true);
            end;
            WorkflowStepInstance := PrevWorkflowStepInstance;
        end;
    end;

    internal procedure GetServicesFromEntryPointResponseInWorkflow(WorkFlow: Record Workflow; var EDocumentService: Record "E-Document Service"): Boolean
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowStep, WorkflowStepEvent : Record "Workflow Step";
        Filter: Text;
    begin
        // Find the entry point to workflow
        WorkflowStep.SetRange("Workflow Code", Workflow.Code);
        WorkflowStep.SetRange(Type, WorkflowStep.Type::Response);
        if WorkflowStep.IsEmpty() then
            exit(false);

        if WorkflowStep.FindSet() then
            repeat
                if WorkflowStep.HasParentEvent(WorkflowStepEvent) then
                    if WorkflowStepEvent."Entry Point" then begin
                        WorkflowStepArgument.Get(WorkflowStep.Argument);
                        AddFilter(Filter, WorkflowStepArgument."E-Document Service");
                    end;
            until WorkflowStep.Next() = 0;

        if Filter = '' then
            exit(false);

        EDocumentService.SetFilter(Code, Filter);
        exit(true);
    end;

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

    procedure GetEDocumentFromRecordRef(var RecordRef: RecordRef; var EDocument: Record "E-Document"): Boolean
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        Telemetry: Codeunit Telemetry;
        WrongWorkflowEventRecordTypeErr: Label 'The record type %1 is not supported in E-Document workflow events.', Comment = '%1 - Table ID';
    begin
        case RecordRef.Number() of
            Database::"E-Document":
                begin
                    RecordRef.SetTable(EDocument);
                    EDocument.Get(EDocument."Entry No");
                    exit(true);
                end;
            Database::"E-Document Service Status":
                begin
                    RecordRef.SetTable(EDocumentServiceStatus);
                    EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                    exit(true);
                end;
            else
                Telemetry.LogMessage('0000Q57', StrSubstNo(WrongWorkflowEventRecordTypeErr, RecordRef.Number()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All);
        end;
        exit(false);
    end;

    internal procedure SendEDocument(var RecordRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
    begin
        if not GetEDocumentFromRecordRef(RecordRef, EDocument) then
            exit;
        if not ValidateFlowStep(EDocument, WorkflowStepArgument, WorkflowStepInstance, true) then
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

    internal procedure HandleNextEvent(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        WorkflowManagement: Codeunit "Workflow Management";
        EDocumentWorkflowSetup: Codeunit "E-Document Workflow Setup";
        Telemetry: Codeunit Telemetry;
        EDocTelemetryNoFilterForNextEventLbl: Label 'No filter set on E-Document to execute next workflow step.';
    begin
        // Commit before execute next workflow step
        Commit();

        if not EDocument.HasFilter() then begin
            Telemetry.LogMessage('0000Q58', EDocTelemetryNoFilterForNextEventLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
            exit;
        end;

        if EDocument.FindSet() then
            repeat
                EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
                WorkflowManagement.HandleEventOnKnownWorkflowInstance(EDocumentWorkflowSetup.EventEDocStatusChanged(), EDocumentServiceStatus, EDocument."Workflow Step Instance ID");
            until EDocument.Next() = 0;
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
        EDocumentBackgroundJobs: Codeunit "E-Document Background Jobs";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        TempBlob: Codeunit "Temp Blob";
        EDocServiceStatus: Enum "E-Document Service Status";
        BeforeExportEDocErrorCount: Dictionary of [Integer, Integer];
        IsAsync, IsHandled, AnyErrors : Boolean;
        ErrorCount: Integer;
    begin
        EDocServiceStatus := Enum::"E-Document Service Status"::"Pending Batch";
        EDocumentLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");
        EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument);

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
                EDocumentBackgroundJobs.ScheduleGetResponseJob();

            HandleNextEvent(EDocument, EDocumentService);
        end;
    end;

    local procedure InsertLogsForThresholdBatch(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempEDocMappingLogs: Record "E-Doc. Mapping Log" temporary; var TempBlob: Codeunit "Temp Blob"; Error: Boolean)
    var
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocLog: Record "E-Document Log";
        EDocumentLog: Codeunit "E-Document Log";
        EDocServiceStatus: Enum "E-Document Service Status";
        EDocDataStorageEntryNo: Integer;
    begin
        EDocument.FindSet();
        if Error then begin
            repeat
                EDocServiceStatus := Enum::"E-Document Service Status"::"Export Error";
                EDocumentLog.InsertLog(EDocument, EDocumentService, EDocServiceStatus);
                EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
                EDocumentProcessing.ModifyEDocumentStatus(EDocument);
            until EDocument.Next() = 0;
            exit;
        end;
        EDocDataStorageEntryNo := EDocumentLog.InsertDataStorage(TempBlob);
        repeat
            EDocServiceStatus := Enum::"E-Document Service Status"::Exported;
            EDocLog := EDocumentLog.InsertLog(EDocument, EDocumentService, EDocServiceStatus);
            EDocumentLog.ModifyDataStorageEntryNo(EDocLog, EDocDataStorageEntryNo);
            EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
            EDocumentProcessing.ModifyEDocumentStatus(EDocument);

            TempEDocMappingLogs.SetRange("E-Doc Entry No.", EDocument."Entry No");
            if TempEDocMappingLogs.FindSet() then
                repeat
                    EDocMappingLog.TransferFields(TempEDocMappingLogs);
                    EDocMappingLog."Entry No." := 0;
                    EDocMappingLog.Validate("E-Doc Log Entry No.", EDocLog."Entry No.");
                    EDocMappingLog.Insert();
                until TempEDocMappingLogs.Next() = 0;
        until EDocument.Next() = 0
    end;

    local procedure DoSend(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    var
        EDocServiceStatus: Record "E-Document Service Status";
        EDocExport: Codeunit "E-Doc. Export";
        EDocIntMgt: Codeunit "E-Doc. Integration Management";
        EDocumentBackgroundJobs: Codeunit "E-Document Background Jobs";
        SendContext: Codeunit SendContext;
        Sent, IsAsync : Boolean;
    begin
        Sent := false;

        if EDocServiceStatus.Get(EDocument."Entry No", EDocumentService.Code) then;

        // if the EDoc has been exported, we don't need to export it again when it is triggered by workflow.
        if (EDocServiceStatus.Status = Enum::"E-Document Service Status"::Exported) then
            Sent := EDocIntMgt.Send(EDocument, EDocumentService, SendContext, IsAsync)
        else
            if EDocExport.ExportEDocument(EDocument, EDocumentService) then
                Sent := EDocIntMgt.Send(EDocument, EDocumentService, SendContext, IsAsync);

        if Sent then
            if IsAsync then
                EDocumentBackgroundJobs.ScheduleGetResponseJob();

        EDocument.SetRecFilter();
        HandleNextEvent(EDocument, EDocumentService);
    end;

    internal procedure ExportEDocument(var RecordRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        EDocExport: Codeunit "E-Doc. Export";
        WorkflowManagement: Codeunit "Workflow Management";
        EDocWorkflowSetup: Codeunit "E-Document Workflow Setup";
    begin
        if not GetEDocumentFromRecordRef(RecordRef, EDocument) then
            exit;

        if not ValidateFlowStep(EDocument, WorkflowStepArgument, WorkflowStepInstance, true) then
            exit;

        EDocumentService.Get(WorkflowStepArgument."E-Document Service");

        if EDocExport.ExportEDocument(EDocument, EDocumentService) then
            WorkflowManagement.HandleEventOnKnownWorkflowInstance(EDocWorkflowSetup.EventEDocExported(), EDocument, EDocument."Workflow Step Instance ID");
    end;

    local procedure ValidateFlowStep(var EDocument: Record "E-Document"; var WorkflowStepArgument: Record "Workflow Step Argument"; WorkflowStepInstance: Record "Workflow Step Instance"; ValidateArgument: Boolean): Boolean
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
    begin
        // Check that step instance corresponds to workflow code set by document sending profile for the document
        if WorkflowStepInstance."Workflow Code" <> EDocument."Workflow Code" then
            Error(WrongWorkflowStepInstanceFoundErr, WorkflowStepInstance."Workflow Code");

        if IsNullGuid(EDocument."Workflow Step Instance ID") then begin
            EDocument."Workflow Step Instance ID" := WorkflowStepInstance.ID;
            EDocument.Modify();
        end;

        if EDocument."Workflow Step Instance ID" <> WorkflowStepInstance.ID then
            exit(false);

        if not ValidateArgument then
            exit(true);

        WorkflowStepArgument.Get(WorkflowStepInstance.Argument);
        if WorkflowStepArgument."E-Document Service" = '' then begin
            EDocErrorHelper.LogErrorMessage(EDocument, WorkflowStepArgument, WorkflowStepArgument.FieldNo("E-Document Service"), 'E-Document Service must be specified in Workflow Argument');
            exit(false);
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
        EDocumentProcessing: Codeunit "E-Document Processing";
        WrongWorkflowStepInstanceFoundErr: Label 'Workflow %1 was executed but did not match the one set for E-Document. Ensure that the response argument condition in the workflow is the only true condition across all workflows.', Comment = '%1 - Workflow code';
        NotSupportedBatchModeErr: Label 'Batch Mode %1 is not supported in E-Document Framework.', Comment = '%1 - The batch mode enum value';
        EDocTelemetryProcessingStartScopeLbl: Label 'E-Document Processing: Start Scope', Locked = true;
        EDocTelemetryProcessingEndScopeLbl: Label 'E-Document Processing: End Scope', Locked = true;
        CannotSendEDocWithoutTypeErr: Label 'Cannot send the E-Document without document type.';
        CannotFindEDocErr: Label 'Cannot find the E-Document with type %1, document number %2.', Comment = '%1 - E-Document type, %2 - Document number';
        NotSupportedEDocTypeErr: Label 'The document type %1 is not supported for sending from email.', Comment = '%1 - E-Document type';

    [IntegrationEvent(false, false)]
    local procedure OnBatchSendWithCustomBatchMode(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var IsHandled: Boolean)
    begin
    end;
}