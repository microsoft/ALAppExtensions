// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Enum extension to register the File Share connector.
/// </summary>
enumextension 4570 "Ext. File Share Connector" extends "Ext. File Storage Connector"
{
    /// <summary>
    /// The File Share connector.
    /// </summary>
    value(4570; "File Share")
    {
        Caption = 'File Share';
        Implementation = "External File Storage Connector" = "Ext. File Share Connector Impl";
    }
}