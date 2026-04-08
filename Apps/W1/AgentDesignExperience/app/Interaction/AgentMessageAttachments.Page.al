// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;

page 4358 "Agent Message Attachments"
{
    PageType = ListPart;
    ApplicationArea = All;
    Caption = 'Attachments';
    SourceTable = "Agent Task File";
    InsertAllowed = false;
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
                    Editable = false;
                    Caption = 'File name';
                    ToolTip = 'Specifies the name of the attachment';

                    trigger OnDrillDown()
                    begin
                        ShowOrDownloadAttachment();
                    end;
                }
                field(MimeType; Rec."File MIME Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'MIME type';
                    ToolTip = 'Specifies the MIME type of the attachment';
                }
                field(FileSize; AttachmentFileSize)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Width = 10;
                    Caption = 'File size';
                    ToolTip = 'Specifies the size of the attachment';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                ToolTip = 'Deletes the attachment';
                Image = Delete;

                trigger OnAction()
                begin
                    Rec.Delete();
                end;
            }
            action(New)
            {
                ApplicationArea = All;
                Caption = 'Upload';
                ToolTip = 'Upload a new attachment';
                Image = Import;

                trigger OnAction()
                begin
                    if not AgentTaskMessageBuilder.UploadAttachment() then
                        exit;
                    Rec := AgentTaskMessageBuilder.GetLastAttachment();
                    Rec.ID := Rec.Count() + 1;
                    Rec.Insert();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        AgentMessage: Codeunit "Agent Message";
    begin
        AttachmentFileSize := AgentMessage.GetFileSizeDisplayText(Rec.Content.Length());
    end;

    local procedure ShowOrDownloadAttachment()
    var
        AgentMessage: Codeunit "Agent Message";
    begin
        AgentMessage.ShowAttachment(Rec);
    end;

    internal procedure GetUploadedFiles(var TempAgentTaskFile: Record "Agent Task File" temporary): Boolean
    begin
        Rec.Reset();
        Rec.SetAutoCalcFields(Content);
        if not Rec.FindSet() then
            exit(false);

        repeat
            TempAgentTaskFile.Copy(Rec);
            TempAgentTaskFile.Insert();
        until Rec.Next() = 0;

        exit(true);
    end;

    internal procedure SetData(var TempAgentTaskFile: Record "Agent Task File" temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if not TempAgentTaskFile.FindSet() then
            exit;
        repeat
            Rec.Copy(TempAgentTaskFile);
            Rec.Insert();
            TempAgentTaskFile.CalcFields(Content);
            Rec.Content := TempAgentTaskFile.Content;
            Rec.Modify();
        until TempAgentTaskFile.Next() = 0;
    end;


    var
        AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder";
        AttachmentFileSize: Text;
}