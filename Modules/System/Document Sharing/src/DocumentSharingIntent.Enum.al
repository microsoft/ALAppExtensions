// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum describing the intent of the document share record
/// </summary>
enum 9560 "Document Sharing Intent"
{
    Extensible = false;

    /// <summary>
    /// Intent to open a preview of the document.
    /// </summary>
    value(0; Open)
    {
        Caption = 'Open';
    }

    /// <summary>
    /// Intent to open the share dialog for the document.
    /// </summary>
    value(1; Share)
    {
        Caption = 'Share';
    }

    /// <summary>
    /// Intent to give the user a prompt to decide what action to take with the document.
    /// Note: This will fail if GuiAllowed() is false.
    /// </summary>
    value(2; Prompt)
    {
        Caption = 'Prompt';
    }
}