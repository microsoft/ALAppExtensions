// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph;

/// <summary>
/// Defines the available API versions for Microsoft Graph API.
/// See: https://learn.microsoft.com/en-us/graph/versioning-and-support#versions
/// </summary>
enum 9350 "Mg API Version"
{
    Access = Public;
    Extensible = false;

    value(0; "v1.0")
    {
        Caption = 'v1.0', Locked = true;
    }
    value(999999; "beta")
    {
        Caption = 'beta', Locked = true;
    }
}