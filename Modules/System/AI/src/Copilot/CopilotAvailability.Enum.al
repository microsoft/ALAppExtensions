// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// The availability of the Copilot Capability.
/// </summary>
enum 7774 "Copilot Availability"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// The Copilot Capability is in preview.
    /// </summary>
    value(0; Preview)
    {
        Caption = 'Preview';
    }

    /// <summary>
    /// The Copilot Capability is generally available.
    /// </summary>
    value(1; "Generally Available")
    {
        Caption = 'Generally Available';
    }
}