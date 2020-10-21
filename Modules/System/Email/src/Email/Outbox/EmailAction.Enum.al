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

    value(0; "Saved As Draft")
    {
    }

    value(1; Discarded)
    {
    }

    value(2; Sent)
    {
    }
}