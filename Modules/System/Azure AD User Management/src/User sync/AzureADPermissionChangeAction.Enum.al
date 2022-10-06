// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The types of the action to take in response to permission conflicts arising out of changes to plans in Office users.
/// </summary>
#pragma warning disable AL0659
enum 9017 "Azure AD Permission Change Action"
#pragma warning restore
{
    Extensible = false;

    /// <summary>
    /// Represents the case when either no action is needed or no action has been provided by the user.
    /// </summary>
    value(0; Select)
    {
        Caption = 'Select';
    }

    /// <summary>
    /// Represents the case when the user wants to keep the current configuration.
    /// </summary>
    value(1; "Keep Current")
    {
        Caption = 'Keep current';
    }

    /// <summary>
    /// Represents the case when the user wants to append a new configuration to one that already exists.
    /// </summary>
    value(2; Append)
    {
        Caption = 'Append';
    }
}