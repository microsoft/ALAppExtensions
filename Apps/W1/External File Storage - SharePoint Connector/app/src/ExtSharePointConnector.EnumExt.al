// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Enum extension to register the SharePoint connector.
/// </summary>
enumextension 4580 "Ext. SharePoint Connector" extends "Ext. File Storage Connector"
{
    /// <summary>
    /// The SharePoint connector.
    /// </summary>
    value(4580; "SharePoint")
    {
        Caption = 'SharePoint';
        Implementation = "External File Storage Connector" = "Ext. SharePoint Connector Impl";
    }
}