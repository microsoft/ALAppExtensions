// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the tenant license state types.
/// </summary>
enum 2301 "Tenant License State"
{
    /// <summary>
    /// Specifies that the tenant license is in the evaluation state.
    /// </summary>
    value(0; Evaluation) { }

    /// <summary>
    /// Specifies that the tenant license is in the trial state.
    /// </summary>
    value(1; Trial) { }

    /// <summary>
    /// Specifies that the tenant license is in the paid state.
    /// </summary>
    value(2; Paid) { }

    /// <summary>
    /// Specifies that the tenant license is in the warning state.
    /// This period starts after the trial period or when the tenant's subscription expires.
    /// </summary>
    value(3; Warning) { }

    /// <summary>
    /// Specifies that the tenant license is in the suspended state.
    /// </summary>
    value(4; Suspended) { }

    /// <summary>
    /// Specifies that the tenant license is in the deleted state.
    /// </summary>
    value(5; Deleted) { }

    /// <summary>
    /// Specifies that the tenant license is in the locked state.
    /// The tenant is locked, and no one can access it.
    /// </summary>
    value(6; LockedOut) { }
}