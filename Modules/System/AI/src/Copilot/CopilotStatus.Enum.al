// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// The status of the Copilot Capability.
/// </summary>
enum 7775 "Copilot Status"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// The Copilot is active.
    /// </summary>
    value(0; Active)
    {
    }

    /// <summary>
    /// The Copilot is inactive.
    /// </summary>
    value(1; Inactive)
    {
    }
}