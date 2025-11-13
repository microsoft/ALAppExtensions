// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;

page 4405 "SOA Email Attachments"
{
    PageType = ListPart;
    ApplicationArea = All;
    Caption = 'Email Attachments';
    SourceTable = "Agent Task File";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    SourceTableTemporary = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(FileName; Rec."File Name")
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                    ToolTip = 'Specifies the name of the attachment';

                    trigger OnDrillDown()
                    begin
                        DownloadAttachment();
                    end;
                }
                field(Status; AttachmentStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies the review status of the attachment';
                    Style = Attention;
                    StyleExpr = AttentionReviewStatus;
                }
                field(FileSize; AttachmentFileSize)
                {
                    ApplicationArea = All;
                    Width = 10;
                    Caption = 'File Size';
                    ToolTip = 'Specifies the size of the attachment';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AttachmentFileSize := FormatFileSize(Rec.Content.Length());
        AttachmentStatus := GetReviewStatus();

        AttentionReviewStatus := (AttachmentStatus <> AttachmentStatus::Reviewed);
    end;

    internal procedure FormatFileSize(SizeInBytes: Integer): Text
    var
        FileSizeConverted: Decimal;
        FileSizeUnit: Text;
    begin
        FileSizeConverted := SizeInBytes / 1024; // The smallest size we show is KB
        if FileSizeConverted < 1024 then
            FileSizeUnit := 'KB'
        else begin
            FileSizeConverted := FileSizeConverted / 1024; // The largest size we show is MB
            FileSizeUnit := 'MB'
        end;
        exit(StrSubstNo(FileSizeTxt, Round(FileSizeConverted, 1, '>'), FileSizeUnit));
    end;

    local procedure GetReviewStatus(): Enum "SOA Email Attachment Status"
    var
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentTaskFile: Record "Agent Task File";
        SOASetup: Codeunit "SOA Setup";
        InStream: InStream;
        ExceedsPageCountThreshold: Boolean;
    begin
        AgentTaskMessageAttachment.ReadIsolation(IsolationLevel::ReadCommitted);
        AgentTaskMessageAttachment.SetLoadFields(Ignored);
        AgentTaskMessageAttachment.SetRange("Task ID", Rec."Task ID");
        AgentTaskMessageAttachment.SetRange("File ID", Rec.ID);
        if not AgentTaskMessageAttachment.FindFirst() then
            exit(AttachmentStatus::Reviewed);

        if not AgentTaskMessageAttachment.Ignored then
            exit(AttachmentStatus::Reviewed);

        if not SOASetup.SupportedAttachmentContentType(Rec."File MIME Type") then
            exit(AttachmentStatus::UnsupportedFormat);

        if SOASetup.IsPdfAttachmentContentType(Rec."File MIME Type") then
            if AgentTaskFile.Get(AgentTaskMessageAttachment."Task ID", AgentTaskMessageAttachment."File ID") then begin
                AgentTaskFile.CalcFields(Content);
                AgentTaskFile.Content.CreateInStream(InStream, GetDefaultEncoding());
                if SOASetup.DocumentExceedsPageCountThreshold(InStream, ExceedsPageCountThreshold) then
                    if ExceedsPageCountThreshold then
                        exit(AttachmentStatus::ExceedsPageCount);
            end;

        AgentTaskMessageAttachment.Reset();
        AgentTaskMessageAttachment.SetRange("Task ID", Rec."Task ID");
        if AgentTaskMessageAttachment.Count() > SOASetup.GetMaxNoOfAttachmentsPerEmail() then
            exit(AttachmentStatus::ExceedsNumberOfAttachments);

        exit(AttachmentStatus::NoRelevantContent);
    end;

    internal procedure LoadRecords(var AgentTaskMessage: Record "Agent Task Message")
    var
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentTaskFile: Record "Agent Task File";
    begin
        Rec.Reset();
        Rec.DeleteAll();

        AgentTaskMessageAttachment.SetRange("Task ID", AgentTaskMessage."Task ID");
        AgentTaskMessageAttachment.SetRange("Message ID", AgentTaskMessage.ID);
        if not AgentTaskMessageAttachment.FindSet() then
            exit;

        AgentTaskFile.SetAutoCalcFields(Content);

        repeat
            if not AgentTaskFile.Get(AgentTaskMessageAttachment."Task ID", AgentTaskMessageAttachment."File ID") then
                exit;

            if not Rec.Get(AgentTaskMessageAttachment."Task ID", AgentTaskMessageAttachment."File ID") then begin
                Rec.Init();
                Rec.TransferFields(AgentTaskFile, true);
                Rec.Content := AgentTaskFile.Content;
                Rec.Insert();
            end;
        until AgentTaskMessageAttachment.Next() = 0;
    end;

    local procedure DownloadAttachment()
    var
        AgentTaskFile: Record "Agent Task File";
        InStream: InStream;
        AttachmentFileName: Text;
        DownloadDialogTitleLbl: Label 'Download Email Attachment';
    begin
        AgentTaskFile.SetAutoCalcFields(Content);
        if not AgentTaskFile.Get(Rec."Task ID", Rec.ID) then
            exit;

        AttachmentFileName := AgentTaskFile."File Name";
        AgentTaskFile.Content.CreateInStream(InStream, GetDefaultEncoding());
        if SupportedByFileViewer(AgentTaskFile."File MIME Type") then begin
            if not File.ViewFromStream(InStream, AttachmentFileName, true) then
                File.DownloadFromStream(InStream, DownloadDialogTitleLbl, '', '', AttachmentFileName);
        end
        else
            File.DownloadFromStream(InStream, DownloadDialogTitleLbl, '', '', AttachmentFileName);
    end;

    local procedure SupportedByFileViewer(FileMIMEType: Text): Boolean
    begin
        if FileMIMEType <> '' then
            exit(LowerCase(FileMIMEType).Contains('pdf'));
        exit(false);
    end;

    procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    var
        AttachmentFileSize: Text;
        AttachmentStatus: Enum "SOA Email Attachment Status";
        AttentionReviewStatus: Boolean;
        FileSizeTxt: Label '%1 %2', Comment = '%1 = File Size, %2 = Unit of measurement', Locked = true;
}