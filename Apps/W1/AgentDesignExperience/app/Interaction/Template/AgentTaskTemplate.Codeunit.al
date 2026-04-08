// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents;
using System.Utilities;

codeunit 4361 "Agent Task Template"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure CreateTaskFromTemplate(AgentSecurityID: Guid)
    var
        TasksCreated: Integer;
    begin
        TasksCreated := CreateTaskFromTemplate(AgentSecurityID, '');
        if (TasksCreated > 0) then
            Message(TasksCreatedMsg, TasksCreated);
    end;

    procedure CreateTaskFromTemplate(AgentSecurityID: Guid; TaskTemplateCode: Code[20]) TasksCreated: Integer
    var
        AgentTaskTemplate: Record "Agent Task Template";
        TempAgentTaskTemplateBuffer: Record "Agent Task Template Buffer";
        AgentMessageTemplate: Record "Agent Message Template";
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentMessageBuilder: Codeunit "Agent Task Message Builder";
        AgentTaskTemplates: Page "Agent Task Templates";
    begin
        AgentTaskTemplates.LookupMode(true);
        AgentTaskTemplates.SetType(Enum::"Agent Template Type"::"Agent Task Template");
        AgentTaskTemplates.SetTaskTemplateCode(TaskTemplateCode);
        if not (AgentTaskTemplates.RunModal() in [Action::OK, Action::LookupOK]) then
            exit;

        AgentTaskTemplates.GetSelectedRecords(TempAgentTaskTemplateBuffer);
        if not TempAgentTaskTemplateBuffer.FindSet() then
            exit;

        repeat
            if AgentTaskTemplate.Get(TempAgentTaskTemplateBuffer."Source Record ID") then begin
                AgentTaskBuilder.Initialize(AgentSecurityID, AgentTaskTemplate."Task Title");
                AgentTaskBuilder.SetExternalId(AgentTaskTemplate."Task External Id");

                if AgentTaskTemplate."Message Template ID" <> 0 then begin
                    AgentMessageTemplate.Get(AgentTaskTemplate."Message Template ID");
                    InitializeAgentMessageBuilder(AgentMessageBuilder, AgentMessageTemplate);
                    AgentTaskBuilder.AddTaskMessage(AgentMessageBuilder);
                end;

                AgentTaskBuilder.Create(true, false);
                TasksCreated += 1;
            end;
        until TempAgentTaskTemplateBuffer.Next() = 0;
    end;

    procedure CreateMessageFromTemplate(AgentTaskID: BigInteger)
    var
        AgentMessageTemplate: Record "Agent Message Template";
        AgentMessageBuilder: Codeunit "Agent Task Message Builder";
        AgentMessageTemplates: Page "Agent Task Templates";
    begin
        AgentMessageTemplates.LookupMode(true);
        AgentMessageTemplates.SetType(Enum::"Agent Template Type"::"Agent Message Template");
        if not (AgentMessageTemplates.RunModal() in [Action::OK, Action::LookupOK]) then
            exit;

        AgentMessageTemplate.Get(AgentMessageTemplates.GetSelectedSourceID());
        InitializeAgentMessageBuilder(AgentMessageBuilder, AgentMessageTemplate);
        AgentMessageBuilder.SetAgentTask(AgentTaskID);
        AgentMessageBuilder.Create();
    end;

    procedure ImportFromFile(): Boolean
    var
        PlaceholdersMap: Dictionary of [Text, Text];
        JsonInStream: InStream;
        FileName: Text;
        ImportAgentTemplatesLbl: Label 'Import agent templates from a file';
    begin
        FileName := AgentTemplatesFileLbl;

        if not UploadIntoStream(ImportAgentTemplatesLbl, '', 'All Files (*.*)|*.*', FileName, JsonInStream) then
            exit(false);

        exit(ImportTemplateFromStream(JsonInStream, '', PlaceholdersMap));
    end;

    procedure ImportTemplateFromStream(JsonInStream: InStream; TaskTemplateCode: Code[20]; PlaceholdersMap: Dictionary of [Text, Text]): Boolean
    var
        AgentTemplatesJsonObject: JsonObject;
        AgentTemplatesArrayJsonToken: JsonToken;
        AgentTemplatesJsonArray: JsonArray;
        AgentTemplateJsonToken: JsonToken;
    begin
        AgentTemplatesJsonObject.ReadFrom(JsonInStream);
        AgentTemplatesJsonObject.Get(ValuesTok, AgentTemplatesArrayJsonToken);
        AgentTemplatesJsonArray := AgentTemplatesArrayJsonToken.AsArray();

        foreach AgentTemplateJsonToken in AgentTemplatesJsonArray do
            ImportTemplateFromJson(AgentTemplateJsonToken.AsObject(), TaskTemplateCode, PlaceholdersMap);

        exit(true);
    end;

    local procedure ImportTemplateFromJson(AgentTemplateJsonObject: JsonObject; TaskTemplateCode: Code[20]; PlaceholdersMap: Dictionary of [Text, Text])
    var
        TemplateType: Enum "Agent Template Type";
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(1033); // ENU

        TemplateType := "Agent Template Type".FromInteger(AgentTemplateJsonObject.GetInteger(AgentTemplateTypeTok));
        case TemplateType of
            Enum::"Agent Template Type"::"Agent Task Template":
                ImportAgentTaskTemplate(AgentTemplateJsonObject, TaskTemplateCode, PlaceholdersMap);
            "Agent Template Type"::"Agent Message Template":
                ImportAgentMessageTemplate(AgentTemplateJsonObject, false, PlaceholdersMap);
            else
                Error(UnknownTemplateTypeErr, AgentTemplateJsonObject.GetInteger(AgentTemplateTypeTok));
        end;

        GlobalLanguage(CurrentGlobalLanguage);
    end;

    local procedure ImportAgentTaskTemplate(AgentTemplateJsonObject: JsonObject; TaskTemplateCode: Code[20]; PlaceholdersMap: Dictionary of [Text, Text])
    var
        ExistingAgentTaskTemplate: Record "Agent Task Template";
        AgentTaskTemplate: Record "Agent Task Template";
        AgentMessageJsonTok: JsonToken;
    begin
        ExistingAgentTaskTemplate.ReadIsolation := IsolationLevel::ReadUncommitted;
        if ExistingAgentTaskTemplate.FindLast() then
            AgentTaskTemplate.ID := ExistingAgentTaskTemplate.ID + 1
        else
            AgentTaskTemplate.ID := 1;

        AgentTaskTemplate."Include Message" := AgentTemplateJsonObject.GetBoolean(IncludeMessageTok);
        // We need to throw an error if the values are too long, there should be no truncation allowed
#pragma warning disable AA0139
        AgentTaskTemplate.Name := ReplacePlaceholders(AgentTemplateJsonObject.GetText(NameTok), PlaceholdersMap);
        AgentTaskTemplate."Sample Agent Code" := TaskTemplateCode;
        AgentTaskTemplate."Task Title" := ReplacePlaceholders(AgentTemplateJsonObject.GetText(TaskTitleTok), PlaceholdersMap);
        AgentTaskTemplate."Description" := ReplacePlaceholders(AgentTemplateJsonObject.GetText(DescriptionTok, true), PlaceholdersMap);
        AgentTaskTemplate."Task External Id" := AgentTemplateJsonObject.GetText(TaskExternalIdTok);
#pragma warning restore AA0139
        AgentTaskTemplate.Insert(true);

        if AgentTemplateJsonObject.Get(MessageTok, AgentMessageJsonTok) then begin
            AgentTaskTemplate."Message Template ID" := ImportAgentMessageTemplate(AgentMessageJsonTok.AsObject(), true, PlaceholdersMap);
            AgentTaskTemplate.Modify(true);
        end;
    end;

    local procedure ImportAgentMessageTemplate(AgentTemplateJsonObject: JsonObject; CreatedWithTask: Boolean; PlaceholdersMap: Dictionary of [Text, Text]): Integer
    var
        AgentMessageTemplate: Record "Agent Message Template";
        AttachmentsText: Text;
        MessageText: Text;
    begin
#pragma warning disable AA0139
        AgentMessageTemplate.Name := ReplacePlaceholders(AgentTemplateJsonObject.GetText(NameTok), PlaceholdersMap);
        AgentMessageTemplate."Message From Text" := AgentTemplateJsonObject.GetText(MessageFromTok);
        AgentMessageTemplate."Message External Id" := AgentTemplateJsonObject.GetText(MessageExternalIdTok);
#pragma warning restore AA0139
        AgentMessageTemplate."Message Requires Review" := AgentTemplateJsonObject.GetBoolean(MessageRequiresReviewTok);
        AgentMessageTemplate."Sanitize Message Content" := AgentTemplateJsonObject.GetBoolean(SanitizeMessageContentTok);
        AgentMessageTemplate."Ignore Attachments" := AgentTemplateJsonObject.GetBoolean(IgnoreAttachmentsTok);
        AgentMessageTemplate."Created with task" := CreatedWithTask;
        AgentMessageTemplate.Insert(true);

        MessageText := AgentTemplateJsonObject.GetText(MessageTextTok, true);
        if MessageText <> '' then
            AgentMessageTemplate.SetMessageText(ReplacePlaceholders(MessageText, PlaceholdersMap));

        AttachmentsText := AgentTemplateJsonObject.GetText(AttachmentsTok, true);
        if AttachmentsText <> '' then
            AgentMessageTemplate.SetAttachmentsText(ReplacePlaceholders(AttachmentsText, PlaceholdersMap));

        exit(AgentMessageTemplate.ID);
    end;

    local procedure ReplacePlaceholders(Source: Text; PlaceholdersMap: Dictionary of [Text, Text]): Text
    var
        PlaceHolder: Text;
    begin
        foreach PlaceHolder in PlaceholdersMap.Keys do
            Source := Source.Replace(PlaceHolder, PlaceholdersMap.Get(PlaceHolder));

        exit(Source);
    end;

    procedure ExportToFile(): Boolean
    var
        AgentTaskTemplates: Record "Agent Task Template";
        AgentMessageTemplates: Record "Agent Message Template";
        TempBlob: Codeunit "Temp Blob";
        AgentTaskTemplatesJsonObject: JsonObject;
        AgentTaskTemplatesArray: JsonArray;
        JsonOutStream: OutStream;
        JsonInStream: InStream;
        FileName: Text;
        CurrentGlobalLanguage: Integer;
        ExportAgentTemplatesDialogLbl: Label 'Export agent templates to a file';
    begin
        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(1033); // ENU

        if AgentTaskTemplates.FindSet() then
            repeat
                AgentTaskTemplatesArray.Add(ExportAgentTaskTemplate(AgentTaskTemplates));
            until AgentTaskTemplates.Next() = 0;

        AgentMessageTemplates.SetRange("Created with task", false);
        if AgentMessageTemplates.FindSet() then
            repeat
                AgentTaskTemplatesArray.Add(ExportAgentMessageTemplate(AgentMessageTemplates));
            until AgentMessageTemplates.Next() = 0;

        AgentTaskTemplatesJsonObject.Add(ValuesTok, AgentTaskTemplatesArray);
        TempBlob.CreateOutStream(JsonOutStream);
        AgentTaskTemplatesJsonObject.WriteTo(JsonOutStream);
        TempBlob.CreateInStream(JsonInStream);
        FileName := AgentTemplatesFileLbl;
        DownloadFromStream(JsonInStream, ExportAgentTemplatesDialogLbl, '', '*.json', FileName);
        GlobalLanguage(CurrentGlobalLanguage);
    end;

    local procedure ExportAgentTaskTemplate(AgentTaskTemplate: Record "Agent Task Template"): JsonObject
    var
        AgentMessageTemplate: Record "Agent Message Template";
        AgentTaskTemplateJsonObject: JsonObject;
    begin
        AgentTaskTemplateJsonObject.Add(AgentTemplateTypeTok, Enum::"Agent Template Type"::"Agent Task Template".AsInteger());
        AgentTaskTemplateJsonObject.Add(NameTok, AgentTaskTemplate.Name);
        AgentTaskTemplateJsonObject.Add(TaskTitleTok, AgentTaskTemplate."Task Title");
        AgentTaskTemplateJsonObject.Add(DescriptionTok, AgentTaskTemplate."Description");
        AgentTaskTemplateJsonObject.Add(IncludeMessageTok, AgentTaskTemplate."Include Message");
        AgentTaskTemplateJsonObject.Add(TaskExternalIdTok, AgentTaskTemplate."Task External Id");
        if AgentTaskTemplate."Message Template ID" <> 0 then begin
            AgentMessageTemplate.Get(AgentTaskTemplate."Message Template ID");
            AgentTaskTemplateJsonObject.Add(MessageTok, ExportAgentMessageTemplate(AgentMessageTemplate));
        end;

        exit(AgentTaskTemplateJsonObject);
    end;

    local procedure CopyMessageAttachmentsToBuffer(AgentTaskID: BigInteger; MessageID: Guid; var TempAgentTaskFile: Record "Agent Task File" temporary)
    var
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentTaskFile: Record "Agent Task File";
    begin
        AgentTaskMessageAttachment.SetRange("Task ID", AgentTaskID);
        AgentTaskMessageAttachment.SetRange("Message ID", MessageID);
        if AgentTaskMessageAttachment.FindSet() then begin
            repeat
                AgentTaskFile.Get(AgentTaskID, AgentTaskMessageAttachment."File ID");
                AgentTaskFile.CalcFields(Content);
                TempAgentTaskFile := AgentTaskFile;
                TempAgentTaskFile.ID := TempAgentTaskFile.Count() + 1;
                TempAgentTaskFile.Insert();
            until AgentTaskMessageAttachment.Next() = 0;

            TempAgentTaskFile.Reset();
            TempAgentTaskFile.FindFirst();
        end;
    end;

    local procedure ExportAgentMessageTemplate(AgentMessageTemplate: Record "Agent Message Template"): JsonObject
    var
        AgentTaskMessageTemplateJsonObject: JsonObject;
        AttachmentsText: Text;
        MessageText: Text;
    begin
        AgentTaskMessageTemplateJsonObject.Add(AgentTemplateTypeTok, Enum::"Agent Template Type"::"Agent Message Template".AsInteger());
        AgentTaskMessageTemplateJsonObject.Add(NameTok, AgentMessageTemplate.Name);
        AgentTaskMessageTemplateJsonObject.Add(MessageFromTok, AgentMessageTemplate."Message From Text");
        AgentTaskMessageTemplateJsonObject.Add(MessageExternalIdTok, AgentMessageTemplate."Message External Id");
        AgentTaskMessageTemplateJsonObject.Add(MessageRequiresReviewTok, AgentMessageTemplate."Message Requires Review");
        AgentTaskMessageTemplateJsonObject.Add(SanitizeMessageContentTok, AgentMessageTemplate."Sanitize Message Content");
        AgentTaskMessageTemplateJsonObject.Add(IgnoreAttachmentsTok, AgentMessageTemplate."Ignore Attachments");

        MessageText := AgentMessageTemplate.GetMessageText();
        if MessageText <> '' then
            AgentTaskMessageTemplateJsonObject.Add(MessageTextTok, MessageText);

        AttachmentsText := AgentMessageTemplate.GetAttachmentsText();
        if AttachmentsText <> '' then
            AgentTaskMessageTemplateJsonObject.Add(AttachmentsTok, AttachmentsText);

        exit(AgentTaskMessageTemplateJsonObject);
    end;

    local procedure InitializeAgentMessageBuilder(var AgentMessageBuilder: Codeunit "Agent Task Message Builder"; var AgentMessageTemplate: Record "Agent Message Template")
    var
        TempAgentTaskFile: Record "Agent Task File" temporary;
        ContentInStream: InStream;
    begin
        AgentMessageBuilder.Initialize(AgentMessageTemplate."Message From Text", AgentMessageTemplate.GetMessageText());
        AgentMessageBuilder.SetMessageExternalID(AgentMessageTemplate."Message External Id");
        AgentMessageBuilder.SetRequiresReview(AgentMessageTemplate."Message Requires Review");
        AgentMessageBuilder.SetIgnoreAttachment(AgentMessageTemplate."Ignore Attachments");
        AgentMessageTemplate.LoadAttachments(AgentMessageTemplate, TempAgentTaskFile);
        if TempAgentTaskFile.FindSet() then
            repeat
                TempAgentTaskFile.CalcFields(Content);
                TempAgentTaskFile.Content.CreateInStream(ContentInStream);
                AgentMessageBuilder.AddAttachment(TempAgentTaskFile."File Name", TempAgentTaskFile."File MIME Type", ContentInStream);
            until TempAgentTaskFile.Next() = 0;
    end;

    procedure CreateTaskTemplate(TaskName: Text[150]; TaskTitle: Text[150]; TaskExternalId: Text[2048]; var AgentMessageTemplate: Record "Agent Message Template"): Record "Agent Task Template"
    var
        AgentTaskTemplate: Record "Agent Task Template";
    begin
        if AgentMessageTemplate.ID <> 0 then begin
            AgentTaskTemplate."Message Template ID" := AgentMessageTemplate.ID;
            AgentTaskTemplate."Include Message" := true;
        end;

        AgentTaskTemplate."Task Title" := TaskTitle;
        AgentTaskTemplate."Task External Id" := TaskExternalId;
        AgentTaskTemplate.Name := TaskName;
        AgentTaskTemplate.Insert(true);
        exit(AgentTaskTemplate);
    end;

    procedure CreateMessageTemplate(MessageName: Text[150]; MessageFromText: Text[250]; MessageText: Text; MessageExternalId: Text[2048]; MessageRequiresReview: Boolean; SanitizeMessageContent: Boolean; IgnoreAttachments: Boolean; var TempAgentTaskFile: Record "Agent Task File" temporary; CreatedWithTask: Boolean): Record "Agent Message Template"
    var
        AgentMessageTemplate: Record "Agent Message Template";
    begin
        AgentMessageTemplate.Name := MessageName;
        AgentMessageTemplate."Message From Text" := MessageFromText;
        AgentMessageTemplate."Message External Id" := MessageExternalId;
        AgentMessageTemplate."Message Requires Review" := MessageRequiresReview;
        AgentMessageTemplate."Sanitize Message Content" := SanitizeMessageContent;
        AgentMessageTemplate."Ignore Attachments" := IgnoreAttachments;
        AgentMessageTemplate."Created with task" := CreatedWithTask;
        AgentMessageTemplate.Insert(true);
        AgentMessageTemplate.SetMessageText(MessageText);
        AgentMessageTemplate.SaveAttachments(AgentMessageTemplate, TempAgentTaskFile);
        exit(AgentMessageTemplate);
    end;

    procedure CreateTemplateFromTask(AgentTaskID: BigInteger): Integer
    var
        AgentTaskMessage: Record "Agent Task Message";
        TempAgentTaskFile: Record "Agent Task File" temporary;
    begin
        AgentTaskMessage.SetRange("Task ID", AgentTaskID);
        if AgentTaskMessage.FindFirst() then
            CopyMessageAttachmentsToBuffer(AgentTaskID, AgentTaskMessage.ID, TempAgentTaskFile);

        exit(CreateTemplateFromTask(AgentTaskID, TempAgentTaskFile));
    end;

    procedure CreateTemplateFromTask(AgentTaskID: BigInteger; var TempAgentTaskFile: Record "Agent Task File" temporary): Integer
    var
        AgentTask: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        AgentMessageTemplate: Record "Agent Message Template";
        AgentTaskTemplateRec: Record "Agent Task Template";
        MessageContentInstream: InStream;
        MessageContent: Text;
    begin
        AgentTask.Get(AgentTaskID);

        AgentTaskMessage.SetRange("Task ID", AgentTask.ID);
        if AgentTaskMessage.FindFirst() then begin
            AgentTaskMessage.CalcFields(Content);
            if AgentTaskMessage.Content.HasValue() then begin
                AgentTaskMessage.Content.CreateInStream(MessageContentInstream, GetEncoding());
                MessageContentInstream.Read(MessageContent);
            end;

            AgentMessageTemplate := CreateMessageTemplate(
                CopyStr(MessageTitleLbl + ' - ' + AgentTask.Title, 1, 150),
                AgentTaskMessage.From,
                MessageContent,
                AgentTaskMessage."External ID",
                AgentTaskMessage."Requires Review",
                true,
                false,
                TempAgentTaskFile,
                true);
        end;

        AgentTaskTemplateRec := CreateTaskTemplate(
            AgentTask.Title,
            AgentTask.Title,
            AgentTask."External ID",
            AgentMessageTemplate);

        exit(AgentTaskTemplateRec.ID);
    end;

    procedure RepeatTask(AgentTaskID: BigInteger)
    var
        AgentTask: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        TempAgentTaskFile: Record "Agent Task File" temporary;
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentMessageBuilder: Codeunit "Agent Task Message Builder";
        AgentMessage: Codeunit "Agent Message";
        MessageContent: Text;
        ContentInStream: InStream;
        RequiresMessage: Boolean;
    begin
        AgentTask.Get(AgentTaskID);

        AgentTaskBuilder
            .Initialize(AgentTask."Agent User Security ID", AgentTask.Title)
            .SetExternalId(AgentTask."External ID");

        Clear(RequiresMessage);
        AgentTaskMessage.SetRange(Type, AgentTaskMessage.Type::Input);
        AgentTaskMessage.SetRange("Task ID", AgentTask.ID);
        if AgentTaskMessage.FindFirst() then begin
            MessageContent := AgentMessage.GetText(AgentTaskMessage);
            AgentMessage.GetAttachments(AgentTaskID, AgentTaskMessage.ID, TempAgentTaskFile);

            AgentMessageBuilder.Initialize(AgentTaskMessage.From, MessageContent)
                .SetMessageExternalID(AgentTaskMessage."External ID")
                .SetRequiresReview(AgentTaskMessage."Requires Review")
                .SetIgnoreAttachment(false);

            if TempAgentTaskFile.FindSet() then
                repeat
                    TempAgentTaskFile.CalcFields(Content);
                    TempAgentTaskFile.Content.CreateInStream(ContentInStream);
                    AgentMessageBuilder.AddAttachment(TempAgentTaskFile."File Name", TempAgentTaskFile."File MIME Type", ContentInStream);
                until TempAgentTaskFile.Next() = 0;

            AgentTaskBuilder.AddTaskMessage(AgentMessageBuilder);
        end;

        AgentTaskBuilder.Create(true, RequiresMessage);
    end;

    procedure GetEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    var
        AgentTemplatesFileLbl: Label 'AgentTemplates.json', Locked = true;
        ValuesTok: Label 'values', Locked = true;
        NameTok: Label 'name', Locked = true;
        IncludeMessageTok: Label 'includeMessage', Locked = true;
        TaskTitleTok: Label 'taskTitle', Locked = true;
        DescriptionTok: Label 'description', Locked = true;
        TaskExternalIdTok: Label 'taskExternalId', Locked = true;
        MessageTok: Label 'message', Locked = true;
        MessageTextTok: Label 'messageText', Locked = true;
        MessageFromTok: Label 'messageFrom', Locked = true;
        MessageExternalIdTok: Label 'messageExternalId', Locked = true;
        MessageRequiresReviewTok: Label 'messageRequiresReview', Locked = true;
        SanitizeMessageContentTok: Label 'sanitizeMessageContent', Locked = true;
        IgnoreAttachmentsTok: Label 'ignoreAttachments', Locked = true;
        AttachmentsTok: Label 'attachments', Locked = true;
        AgentTemplateTypeTok: Label 'agentTemplateType', Locked = true;
        UnknownTemplateTypeErr: Label 'Unknown template type: %1', Locked = true;
        TasksCreatedMsg: Label '%1 task(s) created from template(s).', Comment = '%1 = Number of tasks created';
        MessageTitleLbl: Label 'Message';
}
