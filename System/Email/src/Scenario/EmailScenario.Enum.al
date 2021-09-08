// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Email scenarios.
/// Used to decouple email accounts from sending emails.
/// </summary>
enum 8890 "Email Scenario"
{
    Extensible = true;

    /// <summary>
    /// The default email scenario.
    /// Used in the cases where no other scenario is defined.
    /// </summary>
    value(0; Default)
    {
        Caption = 'Default';
    }
}