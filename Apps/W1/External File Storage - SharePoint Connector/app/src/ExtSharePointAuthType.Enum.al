// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Specifies the authentication types for SharePoint accounts.
/// </summary>
enum 4585 "Ext. SharePoint Auth Type"
{
    Extensible = false;
    Access = Public;

    /// <summary>
    /// Authenticate using Client ID and Client Secret.
    /// </summary>
    value(0; "Client Secret")
    {
        Caption = 'Client Secret';
    }

    /// <summary>
    /// Authenticate using Client ID and Certificate.
    /// </summary>
    value(1; Certificate)
    {
        Caption = 'Certificate';
    }
}
