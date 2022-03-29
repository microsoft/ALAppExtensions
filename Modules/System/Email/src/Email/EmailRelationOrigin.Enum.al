// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Represent how a email relation was added to an email.
/// </summary>
enum 8909 "Email Relation Origin"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// Compose context of an email. Relations added to the email when it was first composed.
    /// </summary>
    value(0; "Compose Context")
    {
        Caption = 'Email Compose Context';
    }

    /// <summary>
    /// Email address lookup. Relations added to the email using address lookup.
    /// </summary>
    value(1; "Email Address Lookup")
    {
        Caption = 'Email Address Lookup';
    }
}