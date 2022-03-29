// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the state of the Privacy Notice Approval.
/// </summary>
enum 1563 "Privacy Notice Approval State"
{
    Extensible = false;
    
    /// <summary>
    /// No decision has been made for the Privacy Notice.
    /// </summary>
    value(0; "Not set")
    {
    }

    /// <summary>
    /// The Privacy Notice has been agreed to.
    /// </summary>
    value(1; Agreed)
    {
    }

    /// <summary>
    /// The Privacy Notice was disagreed.
    /// </summary>
    value(2; Disagreed)
    {
    }
}