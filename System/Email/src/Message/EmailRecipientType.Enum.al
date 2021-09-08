// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the type of an email recipient.
/// </summary>
enum 8901 "Email Recipient Type"
{
    Extensible = true;

    /// <summary>
    /// Recipient type 'To'.
    /// </summary>
    value(0; "To")
    {
    }

    /// <summary>
    /// Recipient type 'Cc'.
    /// </summary>
    value(1; "Cc")
    {
    }


    /// <summary>
    /// Recipient type 'Bcc'.
    /// </summary>
    value(3; "Bcc")
    {
    }
}