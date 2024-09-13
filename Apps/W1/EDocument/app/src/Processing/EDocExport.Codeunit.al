// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Automation;
using System.Telemetry;
using System.Utilities;


codeunit 6102 "E-Doc. Export"
{
    Permissions =
        tabledata "E-Document" = im,
        tabledata "E-Doc. Mapping" = im,
        tabledata "E-Doc. Mapping Log" = im;

    internal procedure CheckEDocument(var EDocSourceRecRef: RecordRef; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    var
        EDocumentService: Record "E-Document Service";
        DocumentSendingProfile: Record "Document Sending Profile";
        WorkFlow: Record Workflow;
        EDocWorkFlowProcessing: Codeunit "E-Document WorkFlow Processing";
        IsHandled: Boolean;
    begin
        OnBeforeEDocumentCheck(EDocSourceRecRef, EDocumentProcessingPhase, IsHandled);
        if IsHandled then
            exit;

        DocumentSendingProfile := EDocumentProcessing.GetDocSendingProfileForDocRef(EDocSourceRecRef);
        if (DocumentSendingProfile."Electronic Document" = DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow") and (not WorkFlow.Get(DocumentSendingProfile."Electronic Service Flow")) then
            Error(DocumentSendingProfileWithWorkflowErr, DocumentSendingProfile."Electronic Service Flow", Format(DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow"), DocumentSendingProfile.Code);
        WorkFlow.TestField(Enabled);

        if EDocWorkFlowProcessing.DoesFlowHasEDocService(EDocumentService, DocumentSendingProfile."Electronic Service Flow") then
            if EDocumentService.FindSet() then
                repeat
                    if IsDocumentTypeSupportedByService(EDocumentService, EDocSourceRecRef, true) then begin
                        EDocumentInterface := EDocumentService."Document Format";
                        EDocumentInterface.Check(EDocSourceRecRef, EDocumentService, EDocumentProcessingPhase);
                    end;
                until EDocumentService.Next() = 0;

        OnAfterEDocumentCheck(EDocSourceRecRef, EDocumentProcessingPhase);
    end;

    internal procedure CreateEDocument(var SourceDocumentHeader: RecordRef)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentBackgroundJobs: Codeunit "E-Document Background Jobs";
        EDocWorkFlowProcessing: Codeunit "E-Document WorkFlow Processing";
        IsDocumentTypeSupported: Boolean;
    begin
        EDocument.SetRange("Document Record ID", SourceDocumentHeader.RecordId);
        if not EDocument.IsEmpty() then
            exit;

        IsDocumentTypeSupported := false;
        DocumentSendingProfile := EDocumentProcessing.GetDocSendingProfileForDocRef(SourceDocumentHeader);
        if EDocWorkFlowProcessing.DoesFlowHasEDocService(EDocumentService, DocumentSendingProfile."Electronic Service Flow") then
            if EDocumentService.FindSet() then
                repeat
                    IsDocumentTypeSupported := IsDocumentTypeSupportedByService(EDocumentService, SourceDocumentHeader, false);
                until (EDocumentService.Next() = 0) or IsDocumentTypeSupported;

        if IsDocumentTypeSupported then begin
            OnBeforeCreateEDocument(EDocument, SourceDocumentHeader);

            PopulateEDocument(EDocument, SourceDocumentHeader);

            OnAfterCreateEDocument(EDocument, SourceDocumentHeader);

            EDocumentLog.InsertLog(EDocument, Enum::"E-Document Service Status"::Created);
            EDocumentProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::Created);
            EDocumentProcessing.ModifyEDocumentStatus(EDocument, Enum::"E-Document Service Status"::Created);

            EDocumentBackgroundJobs.StartEDocumentCreatedFlow(EDocument);
        end;
    end;

    internal procedure ExportEDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service") Success: Boolean
    var
        TempEDocMapping: Record "E-Doc. Mapping" temporary;
        EDocLog: Record "E-Document Log";
        EDocumentLog: Codeunit "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeaderMapped, SourceDocumentLineMapped : RecordRef;
        SourceDocumentHeader, SourceDocumentLines : RecordRef;
        EDocServiceStatus: Enum "E-Document Service Status";
        ErrorCount: Integer;
    begin
        SourceDocumentHeader.Get(EDocument."Document Record ID");
        EDocumentProcessing.GetLines(EDocument, SourceDocumentLines);
        MapEDocument(SourceDocumentHeader, SourceDocumentLines, EDocumentService, SourceDocumentHeaderMapped, SourceDocumentLineMapped, TempEDocMapping, false);

        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        CreateEDocument(EDocumentService, EDocument, SourceDocumentHeaderMapped, SourceDocumentLineMapped, TempBlob);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;
        if Success then
            EDocServiceStatus := Enum::"E-Document Service Status"::Exported
        else
            EDocServiceStatus := Enum::"E-Document Service Status"::"Export Error";

        EDocLog := EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, EDocServiceStatus);
        EDocumentLog.InsertMappingLog(EDocLog, TempEDocMapping);
        EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);
    end;

    internal procedure ExportEDocumentBatch(var EDocuments: Record "E-Document"; var EDocService: Record "E-Document Service"; var TempEDocMappingLogs: Record "E-Doc. Mapping Log" temporary; var TempBlob: Codeunit "Temp Blob"; var EDocumentsErrorCount: Dictionary of [Integer, Integer])
    var
        TempEDocMapping: Record "E-Doc. Mapping" temporary;
        SourceDocumentHeaderMapped, SourceDocumentLineMapped : RecordRef;
        SourceDocumentHeader, SourceDocumentLines : RecordRef;
        I: Integer;
    begin
        EDocuments.FindSet();
        I := 0;
        repeat
            TempEDocMapping.DeleteAll();
            SourceDocumentHeader.Get(EDocuments."Document Record ID");
            EDocumentProcessing.GetLines(EDocuments, SourceDocumentLines);
            MapEDocument(SourceDocumentHeader, SourceDocumentLines, EDocService, SourceDocumentHeaderMapped, SourceDocumentLineMapped, TempEDocMapping, false);
            if TempEDocMapping.FindSet() then
                repeat
                    TempEDocMappingLogs.InitFromMapping(TempEDocMapping);
                    TempEDocMappingLogs."Entry No." := I; // We need to set key for temp record when inserting
                    TempEDocMappingLogs.Validate("E-Doc Entry No.", EDocuments."Entry No");
                    TempEDocMappingLogs.Insert();
                    I += 1;
                until TempEDocMapping.Next() = 0;
            SourceDocumentLines.Close();
            EDocumentProcessing.ModifyServiceStatus(EDocuments, EDocService, Enum::"E-Document Service Status"::Created);
            EDocumentProcessing.ModifyEDocumentStatus(EDocuments, Enum::"E-Document Service Status"::Created);
            EDocumentsErrorCount.Add(EDocuments."Entry No", EDocumentErrorHelper.ErrorMessageCount(EDocuments));
        until EDocuments.Next() = 0;

        // Clear filters and find mapped records
        SourceDocumentHeaderMapped.Reset();
        SourceDocumentLineMapped.Reset();
        SourceDocumentHeaderMapped.FindSet();
        SourceDocumentLineMapped.FindSet();

        CreateEDocumentBatch(EDocService, EDocuments, SourceDocumentHeaderMapped, SourceDocumentLineMapped, TempBlob);
    end;

    internal procedure Recreate(EDocument: Record "E-Document"; EDocService: Record "E-Document Service")
    begin
        ExportEDocument(EDocument, EDocService);
    end;

    internal procedure MapEDocument(var EDocumentSource: RecordRef; var EDocumentSourceLine: RecordRef; EDocumentFormat: Record "E-Document Service"; var EDocumentSourceMapped: RecordRef; var EDocumentSourceLineMapped: RecordRef; var TempEDocMapping: Record "E-Doc. Mapping" temporary; ForImport: Boolean)
    var
        EDocMapping: Record "E-Doc. Mapping";
        EDocMappingNgt: Codeunit "E-Doc. Mapping";
    begin
        if EDocumentSourceMapped.Number() = 0 then
            EDocumentSourceMapped.Open(EDocumentSource.Number(), true);
        if EDocumentSourceLineMapped.Number() = 0 then
            EDocumentSourceLineMapped.Open(EDocumentSourceLine.Number(), true);

        EDocMapping.SetRange(Code, EDocumentFormat.Code);
        EDocMapping.SetRange("For Import", ForImport);
        EDocMapping.ModifyAll(Used, false);
        EDocMappingNgt.MapRecord(EDocMapping, EDocumentSource, EDocumentSourceMapped, TempEDocMapping);

        if EDocumentSourceLine.FindSet() then
            repeat
                EDocMappingNgt.MapRecord(EDocMapping, EDocumentSourceLine, EDocumentSourceLineMapped, TempEDocMapping);
            until EDocumentSourceLine.Next() = 0;
    end;

    local procedure PopulateEDocument(var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        SalesDocumentType: Enum "Sales Document Type";
        PurchDocumentType: Enum "Purchase Document Type";
        RemainingAmount, InterestAmount, AdditionalFee, VATAmount : Decimal;
    begin
        EDocument.Init();
        EDocument.Validate("Document Record ID", SourceDocumentHeader.RecordId);
        EDocument.Validate(Status, EDocument.Status::"In Progress");
        DocumentSendingProfile.Get(EDocumentProcessing.GetDocSendingProfileForDocRef(SourceDocumentHeader).Code);
        EDocument."Document Sending Profile" := DocumentSendingProfile.Code;
        EDocument."Workflow Code" := DocumentSendingProfile."Electronic Service Flow";
        EDocument.Direction := EDocument.Direction::Outgoing;

        case SourceDocumentHeader.Number of
            Database::"Sales Header", Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header",
            Database::"Service Header", Database::"Service Invoice Header", Database::"Service Cr.Memo Header":
                begin
                    case SourceDocumentHeader.Number of
                        Database::"Sales Header":
                            begin
                                SalesDocumentType := SourceDocumentHeader.Field(SalesHeader.FieldNo("Document Type")).Value;
                                case SalesDocumentType of
                                    SalesHeader."Document Type"::Quote:
                                        EDocument."Document Type" := EDocument."Document Type"::"Sales Quote";
                                    SalesHeader."Document Type"::Order:
                                        EDocument."Document Type" := EDocument."Document Type"::"Sales Order";
                                    SalesHeader."Document Type"::"Return Order":
                                        EDocument."Document Type" := EDocument."Document Type"::"Sales Return Order";
                                end;
                            end;
                        Database::"Sales Invoice Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Sales Invoice";
                        Database::"Sales Cr.Memo Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Sales Credit Memo";
                        Database::"Service Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Service Order";
                        Database::"Service Invoice Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Service Invoice";
                        Database::"Service Cr.Memo Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Service Credit Memo";
                    end;

                    EDocument."Document No." := SourceDocumentHeader.Field(SalesHeader.FieldNo("No.")).Value;
                    EDocument."Bill-to/Pay-to No." := SourceDocumentHeader.Field(SalesHeader.FieldNo("Bill-to Customer No.")).Value;
                    EDocument."Bill-to/Pay-to Name" := SourceDocumentHeader.Field(SalesHeader.FieldNo("Bill-to Name")).Value;
                    EDocument."Posting Date" := SourceDocumentHeader.Field(SalesHeader.FieldNo("Posting Date")).Value;
                    EDocument."Document Date" := SourceDocumentHeader.Field(SalesHeader.FieldNo("Document Date")).Value;
                    EDocument."Due Date" := SourceDocumentHeader.Field(SalesHeader.FieldNo("Due Date")).Value;
                    EDocument."Source Type" := EDocument."Source Type"::Customer;
                    EDocument."Currency Code" := SourceDocumentHeader.Field(SalesHeader.FieldNo("Currency Code")).Value;

                    SourceDocumentHeader.Field(SalesHeader.FieldNo(Amount)).CalcField();
                    SourceDocumentHeader.Field(SalesHeader.FieldNo("Amount Including VAT")).CalcField();
                    EDocument."Amount Excl. VAT" := SourceDocumentHeader.Field(SalesHeader.FieldNo(Amount)).Value;
                    EDocument."Amount Incl. VAT" := SourceDocumentHeader.Field(SalesHeader.FieldNo("Amount Including VAT")).Value;
                end;

            Database::"Finance Charge Memo Header", Database::"Issued Fin. Charge Memo Header",
            Database::"Reminder Header", Database::"Issued Reminder Header":
                begin
                    case SourceDocumentHeader.Number of
                        Database::"Finance Charge Memo Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Finance Charge Memo";
                        Database::"Issued Fin. Charge Memo Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Issued Finance Charge Memo";
                        Database::"Reminder Header":
                            EDocument."Document Type" := EDocument."Document Type"::Reminder;
                        Database::"Issued Reminder Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Issued Reminder";
                    end;
                    EDocument."Document No." := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("No.")).Value;
                    EDocument."Bill-to/Pay-to No." := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Customer No.")).Value;
                    EDocument."Bill-to/Pay-to Name" := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo(Name)).Value;
                    EDocument."Posting Date" := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Posting Date")).Value;
                    EDocument."Document Date" := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Document Date")).Value;
                    EDocument."Due Date" := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Due Date")).Value;
                    EDocument."Source Type" := EDocument."Source Type"::Customer;
                    EDocument."Currency Code" := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Currency Code")).Value;

                    SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Remaining Amount")).CalcField();
                    RemainingAmount := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Remaining Amount")).Value;
                    SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Interest Amount")).CalcField();
                    InterestAmount := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Interest Amount")).Value;
                    SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Additional Fee")).CalcField();
                    AdditionalFee := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("Additional Fee")).Value;
                    SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("VAT Amount")).CalcField();
                    VATAmount := SourceDocumentHeader.Field(FinanceChargeMemoHeader.FieldNo("VAT Amount")).Value;

                    EDocument."Amount Excl. VAT" := RemainingAmount + InterestAmount + AdditionalFee;
                    EDocument."Amount Incl. VAT" := RemainingAmount + InterestAmount + AdditionalFee + VATAmount;
                end;

            Database::"Purchase Header", Database::"Purch. Inv. Header", Database::"Purch. Cr. Memo Hdr.":
                begin
                    case SourceDocumentHeader.Number of
                        Database::"Purchase Header":
                            begin
                                PurchDocumentType := SourceDocumentHeader.Field(PurchHeader.FieldNo("Document Type")).Value;
                                case PurchDocumentType of
                                    PurchHeader."Document Type"::Quote:
                                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Quote";
                                    PurchHeader."Document Type"::Order:
                                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Order";
                                    PurchHeader."Document Type"::"Return Order":
                                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Return Order";
                                end;
                            end;
                        Database::"Purch. Inv. Header":
                            EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
                        Database::"Purch. Cr. Memo Hdr.":
                            EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
                    end;

                    EDocument."Document No." := SourceDocumentHeader.Field(PurchHeader.FieldNo("No.")).Value;
                    EDocument."Bill-to/Pay-to No." := SourceDocumentHeader.Field(PurchHeader.FieldNo("Pay-to Vendor No.")).Value;
                    EDocument."Bill-to/Pay-to Name" := SourceDocumentHeader.Field(PurchHeader.FieldNo("Pay-to Name")).Value;
                    EDocument."Posting Date" := SourceDocumentHeader.Field(PurchHeader.FieldNo("Posting Date")).Value;
                    EDocument."Document Date" := SourceDocumentHeader.Field(PurchHeader.FieldNo("Document Date")).Value;
                    EDocument."Due Date" := SourceDocumentHeader.Field(PurchHeader.FieldNo("Due Date")).Value;
                    EDocument."Source Type" := EDocument."Source Type"::Vendor;
                    EDocument."Currency Code" := SourceDocumentHeader.Field(PurchHeader.FieldNo("Currency Code")).Value;

                    SourceDocumentHeader.Field(PurchHeader.FieldNo(Amount)).CalcField();
                    SourceDocumentHeader.Field(PurchHeader.FieldNo("Amount Including VAT")).CalcField();
                    EDocument."Amount Excl. VAT" := SourceDocumentHeader.Field(PurchHeader.FieldNo(Amount)).Value;
                    EDocument."Amount Incl. VAT" := SourceDocumentHeader.Field(PurchHeader.FieldNo("Amount Including VAT")).Value;
                end;
        end;

        EDocument.Insert();
    end;

    local procedure CreateEDocument(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        EDocumentCreate: Codeunit "E-Document Create";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit before create document with error handling
        Commit();
        EDocumentProcessing.GetTelemetryDimensions(EDocService, EDocument, TelemetryDimensions);
        Telemetry.LogMessage('0000LBF', EDocTelemetryCreateScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        EDocumentCreate.SetSource(EDocService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        if not EDocumentCreate.Run() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        EDocumentCreate.GetSource(EDocument);
        Telemetry.LogMessage('0000LBG', EDocTelemetryCreateScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure CreateEDocumentBatch(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        EDocumentCreate: Codeunit "E-Document Create";
        ErrorText: Text;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit before create document with error handling
        Commit();
        EDocumentProcessing.GetTelemetryDimensions(EDocService, EDocument, TelemetryDimensions);
        Telemetry.LogMessage('0000LBH', EDocTelemetryCreateBatchScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        Clear(EDocumentCreate);
        EDocumentCreate.SetSource(EDocService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
        if not EDocumentCreate.Run() then begin
            ErrorText := GetLastErrorText();
            EDocument.FindSet();
            repeat
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, ErrorText);
            until EDocument.Next() = 0;
        end;

        // Read E-Document from database as multiple docs could be modified inside EDocumentCreate;
        EDocument.FindSet();
        Telemetry.LogMessage('0000LBI', EDocTelemetryCreateBatchScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure IsDocumentTypeSupportedByService(EDocService: Record "E-Document Service"; var SourceDocumentHeader: RecordRef; ForCheck: Boolean): Boolean
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
        PurchHeader: Record "Purchase Header";
        EDocSourceType: Enum "E-Document Type";
        SalesDocumentType: Enum "Sales Document Type";
        ServiceDocumentType: Enum "Service Document Type";
        PurchDocumentType: Enum "Purchase Document Type";

    begin
        case SourceDocumentHeader.Number of
            Database::"Sales Header":
                begin
                    SalesDocumentType := SourceDocumentHeader.Field(SalesHeader.FieldNo("Document Type")).Value;
                    case SalesDocumentType of
                        SalesHeader."Document Type"::Quote:
                            EDocSourceType := EDocSourceType::"Sales Quote";
                        SalesHeader."Document Type"::Order:
                            if ForCheck then
                                exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Sales Order") or EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Sales Invoice"))
                            else
                                EDocSourceType := EDocSourceType::"Sales Order";
                        SalesHeader."Document Type"::"Return Order":
                            if ForCheck then
                                exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Sales Return Order") or EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Sales Credit Memo"))
                            else
                                EDocSourceType := EDocSourceType::"Sales Return Order";
                        SalesHeader."Document Type"::Invoice:
                            EDocSourceType := EDocSourceType::"Sales Invoice";
                        SalesHeader."Document Type"::"Credit Memo":
                            EDocSourceType := EDocSourceType::"Sales Credit Memo";
                    end;
                end;
            Database::"Sales Invoice Header":
                EDocSourceType := EDocSourceType::"Sales Invoice";
            Database::"Sales Cr.Memo Header":
                EDocSourceType := EDocSourceType::"Sales Credit Memo";
            Database::"Service Header":
                begin
                    ServiceDocumentType := SourceDocumentHeader.Field(ServiceHeader.FieldNo("Document Type")).Value;
                    case ServiceDocumentType of
                        ServiceHeader."Document Type"::Order:
                            if ForCheck then
                                exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Service Order") or EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Service Invoice"))
                            else
                                EDocSourceType := EDocSourceType::"Service Order";
                        ServiceHeader."Document Type"::Invoice:
                            EDocSourceType := EDocSourceType::"Service Invoice";
                        ServiceHeader."Document Type"::"Credit Memo":
                            EDocSourceType := EDocSourceType::"Service Credit Memo";
                    end;
                end;
            Database::"Service Invoice Header":
                EDocSourceType := EDocSourceType::"Service Invoice";
            Database::"Service Cr.Memo Header":
                EDocSourceType := EDocSourceType::"Service Credit Memo";
            Database::"Finance Charge Memo Header":
                if ForCheck then
                    exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Finance Charge Memo") or EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Issued Finance Charge Memo"))
                else
                    EDocSourceType := EDocSourceType::"Finance Charge Memo";
            Database::"Issued Fin. Charge Memo Header":
                EDocSourceType := EDocSourceType::"Issued Finance Charge Memo";
            Database::"Reminder Header":
                if ForCheck then
                    exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::Reminder) or EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Issued Reminder"))
                else
                    EDocSourceType := EDocSourceType::Reminder;
            Database::"Issued Reminder Header":
                EDocSourceType := EDocSourceType::"Issued Reminder";
            Database::"Purchase Header":
                begin
                    PurchDocumentType := SourceDocumentHeader.Field(PurchHeader.FieldNo("Document Type")).Value;
                    case PurchDocumentType of
                        PurchHeader."Document Type"::Quote:
                            EDocSourceType := EDocSourceType::"Purchase Quote";
                        PurchHeader."Document Type"::Order:
                            if ForCheck then
                                exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Purchase Order") or EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Purchase Invoice"))
                            else
                                EDocSourceType := EDocSourceType::"Purchase Order";
                        PurchHeader."Document Type"::"Return Order":
                            if ForCheck then
                                exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Purchase Return Order") or EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType::"Purchase Credit Memo"))
                            else
                                EDocSourceType := EDocSourceType::"Purchase Return Order";
                        PurchHeader."Document Type"::Invoice:
                            EDocSourceType := EDocSourceType::"Purchase Invoice";
                        PurchHeader."Document Type"::"Credit Memo":
                            EDocSourceType := EDocSourceType::"Purchase Credit Memo";
                    end;
                end;
            Database::"Purch. Inv. Header":
                EDocSourceType := EDocSourceType::"Purchase Invoice";
            Database::"Purch. Cr. Memo Hdr.":
                EDocSourceType := EDocSourceType::"Purchase Credit Memo";
        end;

        exit(EDocServiceSupportedType.Get(EDocService.Code, EDocSourceType));
    end;

    var
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        Telemetry: Codeunit Telemetry;
        EDocumentInterface: Interface "E-Document";
        DocumentSendingProfileWithWorkflowErr: Label 'Workflow %1 defined for %2 in Document Sending Profile %3 is not found.', Comment = '%1 - The workflow code, %2 - Enum value set in Electronic Document, %3 - Document Sending Profile Code';
        EDocTelemetryCreateScopeStartLbl: Label 'E-Document Create: Start Scope', Locked = true;
        EDocTelemetryCreateScopeEndLbl: Label 'E-Document Create: End Scope', Locked = true;
        EDocTelemetryCreateBatchScopeStartLbl: Label 'E-Document Create Batch: Start Scope', Locked = true;
        EDocTelemetryCreateBatchScopeEndLbl: Label 'E-Document Create Batch: End Scope', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEDocumentCheck(RecRef: RecordRef; EDocumentProcessingPhase: Enum "E-Document Processing Phase"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterEDocumentCheck(RecRef: RecordRef; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateEDocument(var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateEdocument(var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef)
    begin
    end;
}