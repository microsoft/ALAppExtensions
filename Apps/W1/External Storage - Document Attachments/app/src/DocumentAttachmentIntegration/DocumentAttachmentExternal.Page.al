// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page for managing document attachments with external storage information.
/// Provides actions for upload, download, and deletion operations.
/// </summary>
page 8751 "Document Attachment - External"
{
    PageType = List;
    SourceTable = "Document Attachment";
    Caption = 'Document Attachments - External Storage';
    UsageCategory = None;
    ApplicationArea = Basic, Suite;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the table ID the attachment belongs to.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the record number the attachment belongs to.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the attached file.';
                }
                field("File Extension"; Rec."File Extension")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the file extension.';
                }
                field("Attached Date"; Rec."Attached Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the file was attached.';
                }
                field("Attached By"; Rec."Attached By")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies who attached the file.';
                }
                field("BCY Deleted Internally"; Rec."Deleted Internally")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Deleted Internally field.', Comment = '%';
                }
                field("BCY Uploaded to External"; Rec."Uploaded Externally")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Uploaded to External';
                    ToolTip = 'Specifies if the file has been uploaded to external storage.';
                }
                field("BCY External Upload Date"; Rec."External Upload Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Upload Date';
                    ToolTip = 'Specifies when the file was uploaded to external storage.';
                }
                field("BCY External File Path"; Rec."External File Path")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'External File Path';
                    ToolTip = 'Specifies the path to the file in external storage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Upload to External Storage")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Upload to External Storage';
                ToolTip = 'Upload the selected file to external storage.';
                Image = Export;

                trigger OnAction()
                var
                    DocumentAttachment: Record "Document Attachment";
                    ExternalStorageProcessor: Codeunit "DA External Storage Processor";
                begin
                    CurrPage.SetSelectionFilter(DocumentAttachment);
                    if DocumentAttachment.FindSet() then
                        repeat
                            if ExternalStorageProcessor.UploadToExternalStorage(DocumentAttachment) then
                                Message(FileUploadedMsg)
                            else
                                Message(FailedFileUploadMsg);
                        until DocumentAttachment.Next() = 0;
                end;
            }
            action("Download from External Storage")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Download from External Storage';
                ToolTip = 'Download the file from external storage.';
                Image = Import;

                trigger OnAction()
                var
                    ExternalStorageProcessor: Codeunit "DA External Storage Processor";
                begin
                    if ExternalStorageProcessor.DownloadFromExternalStorage(Rec) then
                        Message(FileDownloadedMsg)
                    else
                        Message(FailedFileDownloadMsg);
                end;
            }
            action("Download from External To Internal Storage")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Download from External To Internal Storage';
                ToolTip = 'Download the file from external storage to internal storage.';
                Image = Import;

                trigger OnAction()
                var
                    ExternalStorageProcessor: Codeunit "DA External Storage Processor";
                begin
                    if ExternalStorageProcessor.DownloadFromExternalStorageToInternal(Rec) then
                        Message(FileDownloadedMsg)
                    else
                        Message(FailedFileDownloadMsg);
                end;
            }
            action("Delete from External Storage")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = not (Rec."Deleted Internally") and Rec."Uploaded Externally";
                Caption = 'Delete from External Storage';
                ToolTip = 'Delete the file from external storage.';
                Image = Delete;

                trigger OnAction()
                var
                    ExternalStorageProcessor: Codeunit "DA External Storage Processor";
                begin
                    if Confirm(DeleteFileFromExternalStorageQst) then
                        if ExternalStorageProcessor.DeleteFromExternalStorage(Rec) then
                            Message(FileDeletedExternalStorageMsg)
                        else
                            Message(FailedFileDeleteExternalStorageMsg);
                end;
            }
            action("Delete from Internal Storage")
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = Rec."Uploaded Externally" and not Rec."Deleted Internally";
                Caption = 'Delete from Internal Storage';
                ToolTip = 'Delete the file from Internal storage.';
                Image = Delete;

                trigger OnAction()
                var
                    ExternalStorageProcessor: Codeunit "DA External Storage Processor";
                begin
                    if Confirm(DeleteFileFromIntStorageQst) then
                        if ExternalStorageProcessor.DeleteFromInternalStorage(Rec) then
                            Message(FileDeletedIntStorageMsg)
                        else
                            Message(FailedFileDeleteIntStorageMsg);
                end;
            }
        }
        area(Navigation)
        {
            action("External Storage Setup")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'External Storage Setup';
                ToolTip = 'Configure external storage settings.';
                Image = Setup;
                RunObject = page "DA External Storage Setup";
            }
        }
    }

    var
        DeleteFileFromExternalStorageQst: Label 'Are you sure you want to delete this file from external storage?';
        DeleteFileFromIntStorageQst: Label 'Are you sure you want to delete this file from Internal storage?';
        FailedFileDeleteExternalStorageMsg: Label 'Failed to delete file from external storage.';
        FailedFileDeleteIntStorageMsg: Label 'Failed to delete file from Internal storage.';
        FailedFileDownloadMsg: Label 'Failed to download file.';
        FailedFileUploadMsg: Label 'Failed to upload file.';
        FileDeletedExternalStorageMsg: Label 'File deleted successfully from external storage.';
        FileDeletedIntStorageMsg: Label 'File deleted successfully from Internal storage.';
        FileDownloadedMsg: Label 'File downloaded successfully.';
        FileUploadedMsg: Label 'File uploaded successfully.';
}
