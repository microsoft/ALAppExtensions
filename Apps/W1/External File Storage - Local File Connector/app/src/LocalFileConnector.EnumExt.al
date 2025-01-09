// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Enum extension to register the File Share connector.
/// </summary>
enumextension 4820 "Local File Connector" extends "Ext. File Storage Connector"
{
    /// <summary>
    /// The File Share connector.
    /// </summary>
    value(4820; "Local File")
    {
        Caption = 'Local File';
        Implementation = "External File Storage Connector" = "Local File Connector Impl.";
    }
}