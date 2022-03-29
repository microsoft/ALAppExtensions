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
    /// <param name="TempEmailAccount">Out parameter holding the email accounts.</param>
    procedure GetAllAccounts(LoadLogos: Boolean; var TempEmailAccount: Record "Email Account" temporary)
    begin
        EmailAccountImpl.GetAllAccounts(LoadLogos, TempEmailAccount);
    end;

    /// <summary>
    /// Gets all of the email accounts registered in Business Central.
    /// </summary>
    /// <param name="TempEmailAccount">Out parameter holding the email accounts.</param>
    procedure GetAllAccounts(var TempEmailAccount: Record "Email Account" temporary)
    begin
        EmailAccountImpl.GetAllAccounts(false, TempEmailAccount);
    end;

    /// <summary>
    /// Checks if there is at least one email account registered in Business Central.
    /// </summary>
    /// <returns>True if there is any account registered in the system, otherwise - false.</returns>
    procedure IsAnyAccountRegistered(): Boolean
    begin
        exit(EmailAccountImpl.IsAnyAccountRegistered());
    end;

    /// <summary>
    /// Validates an email address and throws an error if it is invalid.
    /// </summary>
    /// <remarks>If the provided email address is an empty string, the function will do nothing.</remarks>
    /// <param name="EmailAddress">The email address to validate.</param>
    /// <error>The email address "%1" is not valid.</error>
    /// <returns>True if the email address is valid; false otherwise.</returns>
    [TryFunction]
    procedure ValidateEmailAddress(EmailAddress: Text)
    begin
        EmailAccountImpl.ValidateEmailAddress(EmailAddress, true);
    end;

    /// <summary>
    /// Validates an email address and throws an error if it is invalid.
    /// </summary>
    /// <param name="EmailAddress">The email address to validate.</param>
    /// <param name="AllowEmptyValue">Indicates whether to skip the validation if the provided email address is empty.</param>
    /// <error>The email address "%1" is not valid.</error>
    /// <error>The email address cannot be empty.</error>
    /// <returns>True if the email address is valid; false otherwise.</returns>
    [TryFunction]
    procedure ValidateEmailAddress(EmailAddress: Text; AllowEmptyValue: Boolean)
    begin
        EmailAccountImpl.ValidateEmailAddress(EmailAddress, AllowEmptyValue);
    end;

    /// <summary>
    /// Validates email addresses and displays an error if any are invalid.
    /// </summary>
    /// <remarks>If the provided email address is an empty string, the function will do nothing.</remarks>
    /// <param name="EmailAddresses">The email addresses to validate, separated by semicolons.</param>
    /// <error>The email address "%1" is not valid.</error>
    /// <returns>True if all email addresses are valid; false otherwise.</returns>
    [TryFunction]
    procedure ValidateEmailAddresses(EmailAddresses: Text)
    begin
        EmailAccountImpl.ValidateEmailAddresses(EmailAddresses, true);
    end;

    /// <summary>
    /// Validates email addresses and displays an error if any are invalid.
    /// </summary>
    /// <param name="EmailAddresses">The email addresses to validate, separated by semicolons.</param>
    /// <param name="AllowEmptyValue">Indicates whether to skip the validation if no email address is provided.</param>
    /// <error>The email address "%1" is not valid.</error>
    /// <error>The email address cannot be empty.</error>
    /// <returns>True if all email addresses are valid; false otherwise.</returns>
    [TryFunction]
    procedure ValidateEmailAddresses(EmailAddresses: Text; AllowEmptyValue: Boolean)
    begin
        EmailAccountImpl.ValidateEmailAddresses(EmailAddresses, AllowEmptyValue);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterValidateEmailAddress(EmailAddress: Text; AllowEmptyValue: Boolean)
    begin
    end;

    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
}