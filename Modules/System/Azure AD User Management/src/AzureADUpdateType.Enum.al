// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Types of updates from users in the Office 365.</summary>
enum 9010 "Azure AD Update Type"
{
    Extensible = false;

    /// <summary>
    /// Represents a value that is present in the Office 365 portal but not in Business Central.
    /// </summary>
    value(0; New)
    {
        Caption = 'New';
    }

    /// <summary>
    /// Represents a value that is different in the Office 365 portal compared to Business Central.
    /// </summary>
    value(1; Change)
    {
        Caption = 'Change';
    }

    /// <summary>
    /// Represents a value that is removed in the Office 365 portal but present in Business Central.
    /// </summary>
    value(2; Remove)
    {
        Caption = 'Remove';
    }
}