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
        if not File.ViewFromStream(InStream, AttachmentFileName, true) then
            File.DownloadFromStream(InStream, DownloadDialogTitleLbl, '', '', AttachmentFileName);
    end;

    procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    var
        AttachmentFileSize: Text;
        FileSizeTxt: Label '%1 %2', Comment = '%1 = File Size, %2 = Unit of measurement', Locked = true;
}