// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum extension to register the Blob Storage connector.
/// </summary>
enumextension 80100 "Blob Storage Connector" extends "File Connector"
{
    /// <summary>
    /// The Blob Storage connector.
    /// </summary>
    value(2147483647; "Blob Storage") // Max int value so it appears last //FIXME Id from Module
    {
        Caption = 'Blob Storage';
        Implementation = "File Connector" = "Blob Storage Connector Impl.";
    }
}