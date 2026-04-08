// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;
using System.Text;

table 4356 "Agent Message Template"
{
    Access = Internal;
    Extensible = false;
    Caption = 'Agent Message Template';
    ReplicateData = false;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            ToolTip = 'Specifies the unique identifier of the agent message template.';
        }
        field(2; Name; Text[150])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the agent message template.';
        }
        field(10; "Message From Text"; Text[250])
        {
            Caption = 'From';
            ToolTip = 'Specifies who the message is from.';
        }
        field(11; "Message External Id"; Text[2048])
        {
            Caption = 'Message title';
            ToolTip = 'Specifies the title of the message to be included in the agent task.';
        }
        field(12; "Message Requires Review"; Boolean)
        {
            Caption = 'Requires review';
            ToolTip = 'Specifies whether the agent task requires review before it can be completed.';
            DataClassification = SystemMetadata;
        }
        field(13; "Sanitize Message Content"; Boolean)
        {
            Caption = 'Sanitize message content';
            ToolTip = 'Specifies whether to sanitize the message content before including it in the agent task.';
        }
        field(14; "Message Content"; Blob)
        {
            Caption = 'Message content';
            ToolTip = 'Specifies the content of the message to be included in the agent task.';
        }
        field(15; "Ignore Attachments"; Boolean)
        {
            Caption = 'Ignore attachments';
            ToolTip = 'Specifies whether to ignore processing of attachments in the message.';
        }

        field(20; Attachments; Blob)
        {
            Caption = 'Attachments';
            ToolTip = 'Specifies the attachments to be included in the agent task.';
            DataClassification = SystemMetadata;
        }
        field(21; "Created with task"; Boolean)
        {
            Caption = 'Created with task';
            ToolTip = 'Specifies whether the message template was created with a task.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ValidatePermissions();

        TestField(Name);
        if Rec.ID = 0 then
            Rec.ID := GetNextID();

        if Rec."Message From Text" = '' then
#pragma warning disable AA0139
            Rec."Message From Text" := UserId();
#pragma warning restore AA0139
    end;

    trigger OnModify()
    begin
        ValidatePermissions()
    end;

    trigger OnRename()
    begin
        ValidatePermissions()
    end;

    trigger OnDelete()
    begin
        ValidatePermissions()
    end;

    procedure GetMessageText(): Text
    var
        MessageContentInstream: InStream;
        MessageContent: Text;
    begin
        Rec.CalcFields("Message Content");
        if Rec."Message Content".Length() = 0 then
            exit('');

        Rec."Message Content".CreateInStream(MessageContentInstream, GetDefaultEncoding());
        MessageContentInstream.Read(MessageContent);
        exit(MessageContent);
    end;

    procedure SetMessageText(NewMessageText: Text)
    var
        MessageContentOutstream: OutStream;
    begin
        Clear(Rec."Message Content");
        Rec."Message Content".CreateOutStream(MessageContentOutstream, GetDefaultEncoding());
        MessageContentOutstream.WriteText(NewMessageText);
        Rec.Modify(true);
    end;

    procedure GetAttachmentsText(): Text
    var
        AttachmentsInstream: InStream;
        AttachmentsText: Text;
    begin
        Rec.CalcFields(Attachments);
        if Rec.Attachments.Length() = 0 then
            exit('');

        Rec.Attachments.CreateInStream(AttachmentsInstream, GetDefaultEncoding());
        AttachmentsInstream.Read(AttachmentsText);
        exit(AttachmentsText);
    end;

    procedure SetAttachmentsText(NewAttachmentsText: Text)
    var
        AttachmentsOutstream: OutStream;
    begin
        Clear(Rec.Attachments);
        Rec.Attachments.CreateOutStream(AttachmentsOutstream, GetDefaultEncoding());
        AttachmentsOutstream.WriteText(NewAttachmentsText);
        Rec.Modify(true);
    end;

    procedure SaveAttachments(var AgentMessageTemplate: Record "Agent Message Template"; var TempAgentTaskAttachment: Record "Agent Task File" temporary)
    var
        AttachmentsOutStream: OutStream;
        AttachmentJsonObject: JsonObject;
        AttachmentsText: Text;
        CommaSeparatorTok: Label ',', Locked = true;
        AttachmentsJsonTok: Label '{"attachments" : [%1]}', Locked = true;
    begin
        if not TempAgentTaskAttachment.FindSet() then
            exit;

        repeat
            AttachmentsText += ConvertAttachmentToJson(TempAgentTaskAttachment) + CommaSeparatorTok;
        until TempAgentTaskAttachment.Next() = 0;


        AttachmentJsonObject.ReadFrom(StrSubstNo(AttachmentsJsonTok, AttachmentsText.TrimEnd(CommaSeparatorTok)));
        Clear(AgentMessageTemplate.Attachments);
        AgentMessageTemplate.Attachments.CreateOutStream(AttachmentsOutStream, GetDefaultEncoding());
        AttachmentJsonObject.WriteTo(AttachmentsOutStream);
        AgentMessageTemplate.Modify(true);
    end;

    procedure LoadAttachments(var AgentMessageTemplate: Record "Agent Message Template" temporary; var TempAgentTaskAttachment: Record "Agent Task File" temporary)
    var
        AttachmentsInstream: InStream;
        AttachmentsJson: JsonObject;
        AttachmentsJsonArray: JsonArray;
        AttachmentJsonObject: JsonObject;
        AttachmentJToken: JsonToken;
        I: Integer;
    begin
        AgentMessageTemplate.CalcFields(Attachments);
        if AgentMessageTemplate.Attachments.Length() = 0 then
            exit;

        AgentMessageTemplate.Attachments.CreateInStream(AttachmentsInstream, GetDefaultEncoding());
        AttachmentsJson.ReadFrom(AttachmentsInstream);
        AttachmentsJsonArray := AttachmentsJson.GetArray(AttachmentsLbl, true);

        for I := 1 to AttachmentsJsonArray.Count() do begin
            AttachmentsJsonArray.Get(I - 1, AttachmentJToken);
            AttachmentJsonObject := AttachmentJToken.AsObject();
            GetAttachmentFromJson(AttachmentJsonObject, TempAgentTaskAttachment);
        end;
    end;

    local procedure ConvertAttachmentToJson(var TempAgentTaskAttachment: Record "Agent Task File" temporary): Text
    var
        Base64Converter: Codeunit "Base64 Convert";
        AttachmentInstream: InStream;
        AttachmentJson: JsonObject;
        AttachmentJsonText: Text;
    begin
        TempAgentTaskAttachment.CalcFields(Content);
        TempAgentTaskAttachment.Content.CreateInStream(AttachmentInstream, GetDefaultEncoding());
        AttachmentJson.ReadFrom(EmptyJsonLbl);
        AttachmentJson.Add(FileNameLbl, TempAgentTaskAttachment."File Name");
        AttachmentJson.Add(FileMimeTypeLbl, TempAgentTaskAttachment."File MIME Type");
        AttachmentJson.Add(FileContentsLbl, Base64Converter.ToBase64(AttachmentInstream));

        AttachmentJson.WriteTo(AttachmentJsonText);
        exit(AttachmentJsonText);
    end;

    local procedure GetAttachmentFromJson(AttachmentsJson: JsonObject; var TempAgentTaskAttachment: Record "Agent Task File" temporary)
    var
        Base64Converter: Codeunit "Base64 Convert";
        AttachmentOutstream: OutStream;
        Base64Text: Text;
    begin
        Clear(TempAgentTaskAttachment);
#pragma warning disable AA0139
        TempAgentTaskAttachment."File Name" := AttachmentsJson.GetText(FileNameLbl);
        TempAgentTaskAttachment."File MIME Type" := AttachmentsJson.GetText(FileMimeTypeLbl);
#pragma warning restore AA0139
        Base64Text := AttachmentsJson.GetText(FileContentsLbl);

        Clear(TempAgentTaskAttachment.Content);

        TempAgentTaskAttachment.Content.CreateOutStream(AttachmentOutstream, GetDefaultEncoding());
        Base64Converter.FromBase64(Base64Text, AttachmentOutstream);
        TempAgentTaskAttachment.ID := TempAgentTaskAttachment.Count() + 1;
        TempAgentTaskAttachment.Insert();
    end;

    local procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    local procedure GetNextID(): Integer
    var
        AgentMessageTemplate: Record "Agent Message Template";
    begin
        if AgentMessageTemplate.FindLast() then;
        exit(AgentMessageTemplate.ID + 1);
    end;

    local procedure ValidatePermissions()
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanManageTemplates();
    end;

    var
        FileNameLbl: Label 'fileName', Locked = true;
        FileMimeTypeLbl: Label 'fileMimeType', Locked = true;
        FileContentsLbl: Label 'fileContents', Locked = true;
        AttachmentsLbl: Label 'attachments', Locked = true;
        EmptyJsonLbl: Label '{}', Locked = true;
}