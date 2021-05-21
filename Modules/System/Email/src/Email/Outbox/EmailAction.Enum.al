// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines the action that the user can take when open an email message in the editor modally.
/// </summary>
enum 8891 "Email Action"
{
    Extensible = false;

    /// <summary>
    /// The email was saved as draft.
    /// </summary>
    value(0; "Saved As Draft")
    {
    }

    /// <summary>
    /// The email was discarded.
    /// </summary>
    value(1; Discarded)
    {
    }

    /// <summary>
    /// The email was sent.
    /// </summary>
    value(2; Sent)
    {
    }
}