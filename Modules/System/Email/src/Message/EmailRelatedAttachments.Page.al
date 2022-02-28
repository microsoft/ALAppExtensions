// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays a list of related attachments to an email. 
/// </summary>
page 8890 "Email Related Attachments"
{
    PageType = List;
    SourceTable = "Email Related Attachment";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Caption = 'Related Attachments';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(FileName; Rec."Attachment Name")
                {
                    ApplicationArea = All;
                    Caption = 'Filename';
                    ToolTip = 'Specifies the name of the attachment';
                }
                field(Source; Rec."Attachment Source")
                {
                    ApplicationArea = All;
                    Caption = 'Source';
                    ToolTip = 'Specifies source record of the attachment.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        EmailEditor: Codeunit "Email Editor";
    begin
        EmailEditor.GetRelatedAttachments(EmailMessageId, Rec);
    end;

    internal procedure SetMessageID(MessageId: Guid)
    begin
        EmailMessageId := MessageId;
    end;

    internal procedure GetSelectedAttachments(var EmailRelatedAttachment: Record "Email Related Attachment")
    begin
        CurrPage.SetSelectionFilter(Rec);

        if not Rec.FindSet() then
            exit;

        repeat
            EmailRelatedAttachment.Copy(Rec);
            EmailRelatedAttachment.Insert();
        until Rec.Next() = 0;
    end;


    var
        EmailMessageId: Guid;
}
