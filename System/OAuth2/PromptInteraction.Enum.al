// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum contains the Prompt Interaction values possible for OAuth 2.0.
/// </summary>
enum 501 "Prompt Interaction"
{
    Extensible = false;

    /// <summary>
    /// No prompt parameter in the request
    /// </summary>
    value(0; None)
    {
        Caption = 'No prompt parameter in the request';
    }

    /// <summary>
    /// The user should be prompted to reauthenticate.
    /// </summary>
    value(1; Login)
    {
        Caption = 'Login';
    }

    /// <summary>
    /// The user is prompted to select an account, interrupting single sign on. The user may select an existing signed-in account, enter their credentials for a remembered account, or choose to use a different account altogether.
    /// </summary>
    value(2; "Select Account")
    {
        Caption = 'Select Account';
    }

    /// <summary>
    /// User consent has been granted, but needs to be updated. The user should be prompted to consent.
    /// </summary>
    value(3; Consent)
    {
        Caption = 'Consent';
    }

    /// <summary>
    /// An administrator should be prompted to consent on behalf of all users in their organization.
    /// </summary>
    value(4; "Admin Consent")
    {
        Caption = 'Admin Consent';
    }

}