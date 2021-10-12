// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the behaviour when adding a new query parameter or flag to a URI.
/// </summary>
enum 3062 "Uri Query Duplicate Behaviour"
{
    Extensible = false;

    /// <summary>
    /// Skips adding the value if the same flag or parameter already exists.
    /// </summary>
    /// <example>Adding "foo=bar" to "https://microsoft.com?foo=goofy" and using this option results in "https://microsoft.com?foo=goofy".</example>
    value(1; "Skip")
    {
        Caption = 'Skip';
    }

    /// <summary>
    /// Keeps the new value (overwrites all existing matching flags or parameters).
    /// </summary>
    /// <example>Adding "foo=bar" to "https://microsoft.com?foo=goofy" and using this option results in "https://microsoft.com?foo=bar".</example>
    value(2; "Overwrite All Matching")
    {
        Caption = 'Overwrite All Matching';
    }

    /// <summary>
    /// Keeps both the existing values and the new value.
    /// </summary>
    /// <example>Adding "foo=bar" to "https://microsoft.com?foo=goofy" and using this option results in "https://microsoft.com?foo=goofy&amp;foo=bar".</example>
    value(3; "Keep All")
    {
        Caption = 'Keep All';
    }

    /// <summary>
    /// Throws an error if the flag or parameter already exists.
    /// </summary>
    /// <example>Adding "foo=bar" to "https://microsoft.com?foo=goofy" and using this option results in an error.</example>
    value(4; "Throw Error")
    {
        Caption = 'Throw Error';
    }
}