// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.AI;
using System.Telemetry;

codeunit 7764 "AOAI Chat Messages Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Initialized: Boolean;
        HistoryLength: Integer;
        SystemMessage: SecretText;
        [NonDebuggable]
        History: List of [Text];
        [NonDebuggable]
        HistoryRoles: List of [Enum "AOAI Chat Roles"];
        [NonDebuggable]
        HistoryNames: List of [Text[2048]];
        IsSystemMessageSet: Boolean;
        MessageIdDoesNotExistErr: Label 'Message id does not exist.';
        HistoryLengthErr: Label 'History length must be greater than 0.';
        TelemetryMetapromptSetbutEmptyTxt: Label 'Metaprompt was set but is empty.', Locked = true;
        TelemetryMetapromptEmptyTxt: Label 'Metaprompt was not set.', Locked = true;

    [NonDebuggable]
    procedure SetPrimarySystemMessage(NewPrimaryMessage: SecretText)
    begin
        SystemMessage := NewPrimaryMessage;
        IsSystemMessageSet := true;
    end;

    [NonDebuggable]
    procedure AddSystemMessage(NewMessage: Text)
    begin
        Initialize();
        AddMessage(NewMessage, '', Enum::"AOAI Chat Roles"::System);
    end;

    [NonDebuggable]
    procedure AddUserMessage(NewMessage: Text)
    begin
        Initialize();
        AddMessage(NewMessage, '', Enum::"AOAI Chat Roles"::User);
    end;

    [NonDebuggable]
    procedure AddUserMessage(NewMessage: Text; NewName: Text[2048])
    begin
        Initialize();
        AddMessage(NewMessage, NewName, Enum::"AOAI Chat Roles"::User);
    end;

    [NonDebuggable]
    procedure AddAssistantMessage(NewMessage: Text)
    begin
        Initialize();
        AddMessage(NewMessage, '', Enum::"AOAI Chat Roles"::Assistant);
    end;

    [NonDebuggable]
    procedure ModifyMessage(Id: Integer; NewMessage: Text; NewRole: Enum "AOAI Chat Roles"; NewName: Text[2048])
    begin
        if (Id < 1) or (Id > History.Count) then
            Error(MessageIdDoesNotExistErr);

        History.Set(Id, NewMessage);
        HistoryRoles.Set(Id, NewRole);
        HistoryNames.Set(Id, NewName);
    end;

    [NonDebuggable]
    procedure DeleteMessage(Id: Integer)
    begin
        if (Id < 1) or (Id > History.Count) then
            Error(MessageIdDoesNotExistErr);

        History.RemoveAt(Id);
        HistoryRoles.RemoveAt(Id);
        HistoryNames.RemoveAt(Id);
    end;

    [NonDebuggable]
    procedure GetHistory(): List of [Text]
    begin
        exit(History);
    end;

    [NonDebuggable]
    procedure GetHistoryNames(): List of [Text[2048]]
    begin
        exit(HistoryNames);
    end;

    [NonDebuggable]
    procedure GetHistoryRoles(): List of [Enum "AOAI Chat Roles"]
    begin
        exit(HistoryRoles);
    end;

    [NonDebuggable]
    procedure GetLastMessage() LastMessage: Text
    begin
        History.Get(History.Count, LastMessage);
    end;

    [NonDebuggable]
    procedure GetLastRole() LastRole: Enum "AOAI Chat Roles"
    begin
        HistoryRoles.Get(HistoryRoles.Count, LastRole);
    end;

    [NonDebuggable]
    procedure GetLastName() LastName: Text[2048]
    begin
        HistoryNames.Get(HistoryNames.Count, LastName);
    end;

    [NonDebuggable]
    procedure SetHistoryLength(NewHistoryLength: Integer)
    begin
        if NewHistoryLength < 1 then
            Error(HistoryLengthErr);

        HistoryLength := NewHistoryLength;
    end;

    [NonDebuggable]
    procedure PrepareHistory() HistoryResult: JsonArray
    var
        AzureOpenAIImpl: Codeunit "Azure OpenAI Impl";
        Counter: Integer;
        MessageJsonObject: JsonObject;
        Message: Text;
        Name: Text[2048];
        Role: Enum "AOAI Chat Roles";
    begin
        if History.Count = 0 then
            exit;

        Initialize();
        CheckandAddMetaprompt();

        if SystemMessage.Unwrap() <> '' then begin
            MessageJsonObject.Add('role', Format(Enum::"AOAI Chat Roles"::System));
            MessageJsonObject.Add('content', SystemMessage.Unwrap());
            HistoryResult.Add(MessageJsonObject);
        end;

        Counter := History.Count - HistoryLength + 1;
        if Counter < 1 then
            Counter := 1;

        repeat
            Clear(MessageJsonObject);
            HistoryRoles.Get(Counter, Role);
            History.Get(Counter, Message);
            HistoryNames.Get(Counter, Name);
            MessageJsonObject.Add('role', Format(Role));
            MessageJsonObject.Add('content', AzureOpenAIImpl.RemoveProhibitedCharacters(Message));

            if Name <> '' then
                MessageJsonObject.Add('name', Name);
            HistoryResult.Add(MessageJsonObject);
            Counter += 1;
        until Counter > History.Count;
    end;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        HistoryLength := 10;

        Initialized := true;
    end;

    [NonDebuggable]
    local procedure AddMessage(NewMessage: Text; NewName: Text[2048]; NewRole: Enum "AOAI Chat Roles")
    begin
        History.Add(NewMessage);
        HistoryRoles.Add(NewRole);
        HistoryNames.Add(NewName);
    end;

    [NonDebuggable]
    local procedure CheckandAddMetaprompt()
    var
        AzureOpenAIImpl: Codeunit "Azure OpenAI Impl";
        Telemetry: Codeunit Telemetry;
    begin
        if SystemMessage.Unwrap().Trim() = '' then begin
            if IsSystemMessageSet then
                Telemetry.LogMessage('0000LO9', TelemetryMetapromptSetbutEmptyTxt, Verbosity::Normal, DataClassification::SystemMetadata)
            else
                Telemetry.LogMessage('0000LOA', TelemetryMetapromptEmptyTxt, Verbosity::Normal, DataClassification::SystemMetadata);
            SetPrimarySystemMessage(AzureOpenAIImpl.GetMetaprompt());
        end;
    end;
}