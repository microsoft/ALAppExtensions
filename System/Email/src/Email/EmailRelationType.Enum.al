// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Represent the type of relation between an email and a source record.
/// </summary>
enum 8908 "Email Relation Type"
{
    Access = Public;
    Extensible = true;

    /// <summary>
    /// Primary source of an email. There should only be one primary source for an email.
    /// </summary>
    value(0; "Primary Source")
    {
        Caption = 'Primary Source';
    }

    /// <summary>
    /// Related entity of an email. An email can have many record relations of this type.
    /// </summary>
    value(1; "Related Entity")
    {
        Caption = 'Related Entity';
    }
}