// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

/// <summary>
/// The behavior to use when a document sharing conflict occurs.
/// </summary>
enum 9562 "Doc. Sharing Conflict Behavior"
{
    // These values map to an enum in the platform, and hence should not be extended by partners
    Extensible = false;

    /// <summary>
    /// Fail the operation.
    /// </summary>
    value(0; Fail)
    {
    }

    /// <summary>
    /// Replace the existing document.
    /// </summary>
    value(1; Replace)
    {
    }

    /// <summary>
    /// Rename the new document.
    /// </summary>
    value(2; Rename)
    {
    }

    /// <summary>
    /// Reuse the existing document.
    /// </summary>
    value(3; Reuse)
    {
    }

    /// <summary>
    /// Show a dialog to the user to ask what to do.
    /// </summary>
    value(9999; Ask)
    {
    }
}