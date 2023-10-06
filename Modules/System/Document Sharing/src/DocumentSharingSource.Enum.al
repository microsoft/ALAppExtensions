// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

/// <summary>
/// Enum describing the source of the document share record
/// </summary>
enum 9561 "Document Sharing Source"
{
    Extensible = false;

    /// <summary>
    /// The source of the share is from the Application.
    /// </summary>
    value(0; App)
    {
        Caption = 'App';
    }

    /// <summary>
    /// The source of the share is from the System.
    /// </summary>
    value(1; System)
    {
        Caption = 'System';
    }
}