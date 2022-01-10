// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// System entity of record with email address.
/// </summary>
enum 8945 "Email Address Entity"
{
    Access = Public;
    Extensible = true;

    value(0; User)
    {
        Caption = 'User';
    }
}