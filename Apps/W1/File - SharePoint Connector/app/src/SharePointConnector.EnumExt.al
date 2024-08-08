// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Enum extension to register the SharePoint connector.
/// </summary>
enumextension 80300 "SharePoint Connector" extends "File System Connector"
{
    /// <summary>
    /// The SharePoint connector.
    /// </summary>
    value(80300; "SharePoint")
    {
        Caption = 'SharePoint';
        Implementation = "File System Connector" = "SharePoint Connector Impl.";
    }
}