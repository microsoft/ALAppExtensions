// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Utilities;

/// <summary>
/// Defines the different kinds of URIs.
/// </summary>
/// <remarks>Visit https://learn.microsoft.com/en-us/dotnet/api/system.urikind for more information.</remarks>
enum 3060 UriKind
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// The URI kind is indeterminate.
    /// </summary>
    value(0; RelativeOrAbsolute)
    {
        Caption = 'RelativeOrAbsolute', Locked = true;
    }
    /// <summary>
    /// The URI is absolute.
    /// </summary>
    value(1; Absolute)
    {
        Caption = 'Absolute', Locked = true;
    }
    /// <summary>
    /// The URI is relative.
    /// </summary>
    value(2; Relative)
    {
        Caption = 'Relative', Locked = true;
    }
}