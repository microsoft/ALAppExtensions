// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Report for synchronizing document attachments between internal and external storage.
/// Supports bulk upload, download, and cleanup operations.
/// </summary>
report 8752 "DA External Storage Sync"
{
    Caption = 'External Storage Synchronization';
    ProcessingOnly = true;
    UseRequestPage = true;
    Extensible = false;

    dataset
    {
        dataitem(DocumentAttachment; "Document Attachment")
        {
            trigger OnPreDataItem()
            begin
                SetFilters();
                TotalCount := Count();

                if TotalCount = 0 then begin
                    if GuiAllowed then
                        Message(NoRecordsMsg);
                    CurrReport.Break();
                end;

                if MaxRecordsToProcess > 0 then
                    if TotalCount > MaxRecordsToProcess then
                        TotalCount := MaxRecordsToProcess;

                ProcessedCount := 0;
                FailedCount := 0;
                DeleteCount := 0;
                DeleteFailedCount := 0;

                if GuiAllowed then
                    Dialog.Open(ProcessingMsg, TotalCount);
            end;

            trigger OnAfterGetRecord()
            begin
                ProcessedCount += 1;

                if GuiAllowed then
                    Dialog.Update(1, ProcessedCount);

                case SyncDirection of
                    SyncDirection::"To External Storage":

                        if not ExternalStorageProcessor.UploadToExternalStorage(DocumentAttachment) then
                            FailedCount += 1;
                    SyncDirection::"From External Storage":

                        if not ExternalStorageProcessor.DownloadFromExternalStorage(DocumentAttachment) then
                            FailedCount += 1;
                end;
                if DeleteExpiredFiles then
                    if CalcDate('<+' + GetDateFormulaFromExternalStorageSetup() + '>', DocumentAttachment."External Upload Date") >= Today() then
                        if ExternalStorageProcessor.DeleteFromInternalStorage(DocumentAttachment) then
                            DeleteCount += 1
                        else
                            DeleteFailedCount += 1;

                if (MaxRecordsToProcess > 0) and (ProcessedCount >= MaxRecordsToProcess) then
                    CurrReport.Break();
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed then begin
                    if TotalCount <> 0 then
                        Dialog.Close();
                    if DeleteExpiredFiles then
                        Message(DeletedExpiredFilesMsg, ProcessedCount - FailedCount, FailedCount, DeleteCount)
                    else
                        Message(ProcessedMsg, ProcessedCount - FailedCount, FailedCount);
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(SyncDirectionField; SyncDirection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sync Direction';
                        ToolTip = 'Select whether to sync to external storage, from external storage, or delete expired files.';
                    }
                    field(DeleteExpiredFiles; DeleteExpiredFiles)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Delete Expired Files';
                        ToolTip = 'Select whether to delete expired files from internal storage.';
                    }
                    field(MaxRecordsToProcessField; MaxRecordsToProcess)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Maximum Records to Process';
                        ToolTip = 'Specify the maximum number of records to process in one run. Leave 0 for unlimited.';
                        MinValue = 0;
                    }
                }
            }
        }
    }

    var
        ExternalStorageProcessor: Codeunit "DA External Storage Processor";
        DeleteExpiredFiles: Boolean;
        Dialog: Dialog;
        DeleteCount, DeleteFailedCount : Integer;
        FailedCount: Integer;
        MaxRecordsToProcess: Integer;
        ProcessedCount: Integer;
        TotalCount: Integer;
        DeletedExpiredFilesMsg: Label 'Processed %1 attachments successfully. %2 failed.//Deleted %3 expired files.', Comment = '%1 - Number of Processed Attachments, %2 - Number of Failed Attachments, %3 - Number of Deleted Expired Files';
        NoRecordsMsg: Label 'No records found to process.';
        ProcessedMsg: Label 'Processed %1 attachments successfully. %2 failed.', Comment = '%1 - Number of Processed Attachments, %2 - Number of Failed Attachments';
        ProcessingMsg: Label 'Processing #1###### attachments...', Comment = '%1 - Total Number of Attachments';
        SyncDirection: Option "To External Storage","From External Storage";

    local procedure SetFilters()
    begin
        case SyncDirection of
            SyncDirection::"To External Storage":
                begin
                    DocumentAttachment.SetRange("Uploaded Externally", false);
                    if DocumentAttachment.FindSet() then begin
                        repeat
                            if not DocumentAttachment."Document Reference ID".HasValue() then
                                DocumentAttachment.Mark(false)
                            else
                                DocumentAttachment.Mark(true);
                        until DocumentAttachment.Next() = 0;
                        DocumentAttachment.MarkedOnly(true);
                    end;
                end;
            SyncDirection::"From External Storage":

                DocumentAttachment.SetRange("Uploaded Externally", true);
        end;
    end;

    local procedure GetDateFormulaFromExternalStorageSetup(): Text
    var
        ExternalStorageSetup: Record "DA External Storage Setup";
    begin
        ExternalStorageSetup.Get();
        exit(Format(ExternalStorageSetup."Delete After".AsInteger()) + 'D');
    end;
}
