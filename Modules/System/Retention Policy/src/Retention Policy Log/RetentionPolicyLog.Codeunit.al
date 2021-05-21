// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit provides functions for logging error, warning, and informational messages to the Retention Policy Log Entry table.
/// </summary>
codeunit 3908 "Retention Policy Log"
{
    Access = Public;

    /// <summary>
    /// LogError will create an entry in the Retention Policy Log Entry table with Message Type set to Error.
    /// An error message will be displayed to the user and any changes in the current transaction will be reverted.
    /// </summary>
    /// <param name="Category">The category for which to log the message.</param>
    /// <param name="Message">The message to log.</param>
    procedure LogError(Category: Enum "Retention Policy Log Category"; Message: Text[2048]);
    var
        RetentionPolicyLogImpl: Codeunit "Retention Policy Log Impl.";
    begin
        RetentionPolicyLogImpl.LogError(Category, Message, true);
    end;

    /// <summary>
    /// LogError will create an entry in the Retention Policy Log Entry table with Message Type set to Error.
    /// If DisplayError is true, an error message will be displayed to the user and any changes in the current transaction will be rolled back.
    /// If DisplayError is false, no error is displayed, the code continues to run, and no changes are reverted.
    /// </summary>
    /// <param name="Category">The category for which to log the message.</param>
    /// <param name="Message">The message to log.</param>
    /// <param name="DisplayError">Specifies whether the error is displayed.</param>
    procedure LogError(Category: Enum "Retention Policy Log Category"; Message: Text[2048]; DisplayError: Boolean);
    var
        RetentionPolicyLogImpl: Codeunit "Retention Policy Log Impl.";
    begin
        RetentionPolicyLogImpl.LogError(Category, Message, DisplayError);
    end;

    /// <summary>
    /// LogWarning will create an entry in the Retention Policy Log Entry table with Message Type set to Warning. No message is displayed to the user.
    /// </summary>
    /// <param name="Category">The category for which to log the message.</param>
    /// <param name="Message">The message to log.</param>
    procedure LogWarning(Category: Enum "Retention Policy Log Category"; Message: Text[2048]);
    var
        RetentionPolicyLogImpl: Codeunit "Retention Policy Log Impl.";
    begin
        RetentionPolicyLogImpl.LogWarning(Category, Message);
    end;

    /// <summary>
    /// LogInfo will create an entry in the Retention Policy Log Entry table with Message Type set to Info. No message is displayed to the user.
    /// </summary>
    /// <param name="Category">The category for which to log the message.</param>
    /// <param name="Message">The message to log.</param>
    procedure LogInfo(Category: Enum "Retention Policy Log Category"; Message: Text[2048]);
    var
        RetentionPolicyLogImpl: Codeunit "Retention Policy Log Impl.";
    begin
        RetentionPolicyLogImpl.LogInfo(Category, Message);
    end;
}