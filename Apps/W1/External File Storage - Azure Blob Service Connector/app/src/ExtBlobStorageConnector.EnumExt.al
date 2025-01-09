// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Enum extension to register the Blob Storage connector.
/// </summary>
enumextension 4560 "Ext. Blob Storage Connector" extends "Ext. File Storage Connector"
{
    /// <summary>
    /// The Blob Storage connector.
    /// </summary>
    value(4560; "Blob Storage")
    {
        Caption = 'Blob Storage';
        Implementation = "External File Storage Connector" = "Ext. Blob Sto. Connector Impl.";
    }
}