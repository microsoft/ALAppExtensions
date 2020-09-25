// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to work with email accounts.
/// </summary>
codeunit 8894 "Email Account"
{
    Access = Public;

    /// <summary>
    /// Gets all of the email accounts registered in Business Central.
    /// </summary>
    /// <param name="LoadLogos">Flag, used to determine whether to load the logos for the accounts.</param>
    /// <param name="Accounts">Out parameter holding the email accounts.</param>
    procedure GetAllAccounts(LoadLogos: Boolean; var Accounts: Record "Email Account" temporary)
    begin
        EmailAccountImpl.GetAllAccounts(LoadLogos, Accounts);
    end;

    /// <summary>
    /// Gets all of the email accounts registered in Business Central.
    /// </summary>
    /// <param name="Accounts">Out parameter holding the email accounts.</param>
    procedure GetAllAccounts(var Accounts: Record "Email Account" temporary)
    begin
        EmailAccountImpl.GetAllAccounts(false, Accounts);
    end;

    /// <summary>
    /// Checks if there is at least one email account registered in Business Central.
    /// </summary>
    /// <return>True if there is any account registered in the system, otherwise - false.</return>
    procedure IsAnyAccountRegistered(): Boolean
    begin
        exit(EmailAccountImpl.IsAnyAccountRegistered());
    end;

    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
}