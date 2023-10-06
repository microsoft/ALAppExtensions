// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Threading;
using System.Utilities;

codeunit 6142 "E-Doc. Recurrent Batch Send"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        EDocumentService: Record "E-Document Service";
        EDocuments: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        TempEDocMappingLogs: Record "E-Doc. Mapping Log" temporary;
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocumentLogRecord: Record "E-Document Log";
        EDocExport: Codeunit "E-Doc. Export";
        EDocIntMgt: Codeunit "E-Doc. Integration Management";
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentWorkFlowProcessing: Codeunit "E-Document WorkFlow Processing";
        EDocumentBackgroundjobs: Codeunit "E-Document Background Jobs";
        TempBlob: Codeunit "Temp Blob";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        BeforeExportEDocumentsErrorCount: Dictionary of [Integer, Integer];
        EntryNumbers: List of [Integer];
        EDocumentListFilter, EDocumentListExportedFilter : Text;
        ErrorCount, EDocLogEntryNo, EDocDataStorageEntryNo : Integer;
        DocumentType: Enum "E-Document Type";
        IsAsync: Boolean;
    begin
        EDocumentService.Get(Rec."Record ID to Process");

        EDocumentServiceStatus.SetRange(Status, EDocumentServiceStatus.Status::"Pending Batch");
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        if EDocumentServiceStatus.IsEmpty() then
            exit;

        EDocumentServiceStatus.FindSet();
        repeat
            EDocumentWorkFlowProcessing.AddFilter(EDocumentListFilter, Format(EDocumentServiceStatus."E-Document Entry No"));
        until EDocumentServiceStatus.Next() = 0;

        foreach DocumentType in EDocuments."Document Type".Ordinals() do begin
            EDocuments.Init();
            EDocuments.SetFilter("Entry No", EDocumentListFilter);
            EDocuments.SetRange("Document Type", DocumentType);
            if EDocuments.FindSet() then begin
                Clear(TempEDocMappingLogs);
                Clear(TempBlob);
                Clear(BeforeExportEDocumentsErrorCount);
                EDocumentListExportedFilter := '';
                EDocExport.ExportEDocumentBatch(EDocuments, EDocumentService, TempEDocMappingLogs, TempBlob, BeforeExportEDocumentsErrorCount);
                EDocuments.FindSet();
                repeat
                    BeforeExportEDocumentsErrorCount.Get(EDocuments."Entry No", ErrorCount);
                    if (EDocumentErrorHelper.ErrorMessageCount(EDocuments) > ErrorCount) then
                        EDocLogEntryNo := EDocumentLog.InsertLog(EDocuments, EDocumentService, Enum::"E-Document Service Status"::"Export Error")
                    else begin
                        EDocLogEntryNo := EDocumentLog.InsertLog(EDocuments, EDocumentService, Enum::"E-Document Service Status"::Exported);
                        TempEDocMappingLogs.SetRange("E-Doc Entry No.", EDocuments."Entry No");
                        if TempEDocMappingLogs.FindFirst() then begin
                            EDocMappingLog.Copy(TempEDocMappingLogs);
                            EDocMappingLog."Entry No." := 0;
                            EDocMappingLog.Validate("E-Doc Log Entry No.", EDocLogEntryNo);
                            EDocMappingLog.Insert();
                        end;
                        EntryNumbers.Add(EDocLogEntryNo);
                        EDocumentWorkFlowProcessing.AddFilter(EDocumentListExportedFilter, Format(EDocuments."Entry No"));
                    end;
                until EDocuments.Next() = 0;

                if EntryNumbers.Count() > 0 then begin
                    EDocDataStorageEntryNo := EDocumentLog.AddTempBlobToLog(TempBlob);
                    foreach EDocLogEntryNo in EntryNumbers do begin
                        EDocumentLogRecord.Get(EDocLogEntryNo);
                        EDocumentLog.SetDataStorage(EDocumentLogRecord, EDocDataStorageEntryNo);
                    end;

                    EDocuments.SetFilter("Entry No", EDocumentListExportedFilter);
                    EDocIntMgt.SendBatch(EDocuments, EDocumentService, IsAsync);

                    if IsAsync then
                        EDocumentBackgroundjobs.GetEDocumentResponse()
                    else
                        EDocumentWorkFlowProcessing.HandleNextEvent(EDocuments);
                end;
            end;
        end;
    end;
}
