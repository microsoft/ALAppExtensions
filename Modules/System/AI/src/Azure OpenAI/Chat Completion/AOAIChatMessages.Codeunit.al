// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.AI;

/// <summary>
/// Helper functions for the AOAI Chat Message table.
/// </summary>
codeunit 7763 "AOAI Chat Messages"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AOAIChatMessagesImpl: Codeunit "AOAI Chat Messages Impl";

    /// <summary>
    /// Sets the system message which is always at the top of the chat messages history provided to the model.
    /// </summary>
    /// <param name="Message">The primary system message.</param>
    [NonDebuggable]
    procedure SetPrimarySystemMessage(Message: SecretText)
    begin
        AOAIChatMessagesImpl.SetPrimarySystemMessage(Message);
    end;

    /// <summary>
    /// Adds a system message to the chat messages history.
    /// </summary>
    /// <param name="NewMessage">The message to add.</param>
    [NonDebuggable]
    procedure AddSystemMessage(NewMessage: Text)
    begin
        AOAIChatMessagesImpl.AddSystemMessage(NewMessage);
    end;

    /// <summary>
    /// Adds a user message to the chat messages history.
    /// </summary>
    /// <param name="NewMessage">The message to add.</param>
    [NonDebuggable]
    procedure AddUserMessage(NewMessage: Text)
    begin
        AOAIChatMessagesImpl.AddUserMessage(NewMessage);
    end;

    /// <summary>
    /// Adds a user message to the chat messages history.
    /// </summary>
    /// <param name="NewMessage">The message to add.</param>
    /// <param name="NewName">The name of the user.</param>
    [NonDebuggable]
    procedure AddUserMessage(NewMessage: Text; NewName: Text[2048])
    begin
        AOAIChatMessagesImpl.AddUserMessage(NewMessage, NewName);
    end;

    /// <summary>
    /// Adds a assistant message to the chat messages history.
    /// </summary>
    /// <param name="NewMessage">The message to add.</param>
    [NonDebuggable]
    procedure AddAssistantMessage(NewMessage: Text)
    begin
        AOAIChatMessagesImpl.AddAssistantMessage(NewMessage);
    end;

    /// <summary>
    /// Modifies a message in the chat messages history.
    /// </summary>
    /// <param name="Id">Id of the message.</param>
    /// <param name="NewMessage">The new message.</param>
    /// <param name="NewRole">The new role.</param>
    /// <param name="NewName">The new name.</param>
    /// <error>Message id does not exist.</error>
    [NonDebuggable]
    procedure ModifyMessage(Id: Integer; NewMessage: Text; NewRole: Enum "AOAI Chat Roles"; NewName: Text[2048])
    begin
        AOAIChatMessagesImpl.ModifyMessage(Id, NewMessage, NewRole, NewName);
    end;

    /// <summary>
    /// Deletes a message from the chat messages history.
    /// </summary>
    /// <param name="Id">Id of the message.</param>
    /// <error>Message id does not exist.</error>
    [NonDebuggable]
    procedure DeleteMessage(Id: Integer)
    begin
        AOAIChatMessagesImpl.DeleteMessage(Id);
    end;

    /// <summary>
    /// Gets the history of chat messages.
    /// </summary>
    /// <returns>List of chat messages.</returns>
    [NonDebuggable]
    procedure GetHistory(): List of [Text]
    begin
        exit(AOAIChatMessagesImpl.GetHistory());
    end;

    /// <summary>
    /// Gets the history names of chat messages.
    /// </summary>
    /// <returns>List of names of chat messages.</returns>
    [NonDebuggable]
    procedure GetHistoryNames(): List of [Text[2048]]
    begin
        exit(AOAIChatMessagesImpl.GetHistoryNames());
    end;

    /// <summary>
    /// Gets the history roles of chat messages.
    /// </summary>
    /// <returns>List of roles of chat messages.</returns>
    [NonDebuggable]
    procedure GetHistoryRoles(): List of [Enum "AOAI Chat Roles"]
    begin
        exit(AOAIChatMessagesImpl.GetHistoryRoles());
    end;

    /// <summary>
    /// Gets the last chat message.
    /// </summary>
    /// <returns>The last chat message.</returns>
    [NonDebuggable]
    procedure GetLastMessage(): Text
    begin
        exit(AOAIChatMessagesImpl.GetLastMessage());
    end;

    /// <summary>
    /// Gets the last chat message role.
    /// </summary>
    /// <returns>The last chat message role.</returns>
    [NonDebuggable]
    procedure GetLastRole(): Enum "AOAI Chat Roles"
    begin
        exit(AOAIChatMessagesImpl.GetLastRole());
    end;

    /// <summary>
    /// Gets the last chat message name.
    /// </summary>
    /// <returns>The last chat message name.</returns>
    [NonDebuggable]
    procedure GetLastName(): Text[2048]
    begin
        exit(AOAIChatMessagesImpl.GetLastName());
    end;

    /// <summary>
    /// Set the length of history that is used by the model.
    /// </summary>
    /// <param name="NewLength">The new length.</param>
    /// <error>History length must be greater than 0.</error>
    [NonDebuggable]
    procedure SetHistoryLength(NewLength: Integer)
    begin
        AOAIChatMessagesImpl.SetHistoryLength(NewLength);
    end;

    /// <summary>
    /// Prepares the history of messages to be sent to the deployment model.
    /// </summary>
    /// <returns>History of messages in a JsonArray.</returns>
    /// <remarks>Use this after adding messages, to construct a json array of all messages.</remarks>
    [NonDebuggable]
    internal procedure AssembleHistory(): JsonArray
    begin
        exit(AOAIChatMessagesImpl.PrepareHistory());
    end;
}