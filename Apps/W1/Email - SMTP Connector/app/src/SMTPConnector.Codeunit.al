// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The e-mail connector for creating accounts and sending e-mails via the SMTP protocol.
/// </summary>
codeunit 4512 "SMTP Connector" implements "Email Connector"
{
    Access = Internal;

    /// <summary>
    /// Gets the registered accounts for the SMTP connector.
    /// </summary>
    /// <param name="Accounts">Out parameter holding all the registered accounts for the SMTP connector.</param>
    procedure GetAccounts(var Accounts: Record "Email Account")
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        SMTPConnectorImpl.GetAccounts(Accounts);
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        SMTPConnectorImpl.ShowAccountInformation(AccountId);
    end;

    /// <summary>
    /// Register an e-mail account for the SMTP connector.
    /// </summary>
    /// <param name="Account">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var Account: Record "Email Account"): Boolean
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        exit(SMTPConnectorImpl.RegisterAccount(Account));
    end;

    /// <summary>
    /// Deletes an e-mail account for the SMTP connector.
    /// </summary>
    /// <param name="AccountId">The ID of the e-mail account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        exit(SMTPConnectorImpl.DeleteAccount(AccountId));
    end;

    /// <summary>
    /// Sends an e-mail via the SMTP connector.
    /// </summary>
    /// <param name="Message">The e-mail message to send.</param>
    /// <param name="AccountId">The ID of the account to be used for sending.</param>
    /// <error>SMTP connector failed to connect to server.</error>
    /// <error>SMTP connector failed to authenticate against server.</error>
    /// <error>SMTP connector failed to send the email.</error>
    procedure Send(Message: Codeunit "Email Message"; AccountId: Guid)
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        SMTPConnectorImpl.Send(Message, AccountId);
    end;

    /// <summary>
    /// Gets a description of the SMTP connector.
    /// </summary>
    /// <returns>A short description of the SMTP connector.</returns>
    procedure GetDescription(): Text[250]
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        exit(SMTPConnectorImpl.GetDescription());
    end;

    /// <summary>
    /// Gets the SMTP connector logo.
    /// </summary>
    /// <returns>A base64-formatted image to be used as logo.</returns>
    procedure GetLogoAsBase64(): Text
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
    begin
        exit(SMTPConnectorImpl.GetLogoAsBase64());
    end;
}