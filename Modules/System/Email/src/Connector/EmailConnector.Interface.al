// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// An e-mail connector interface used to creating e-mail accounts and sending an e-mail.
/// </summary>
interface "Email Connector"
{
    /// <summary>
    /// Sends an e-mail using the provided account.
    /// </summary>
    /// <param name="EmailMessage">The email message that is to be sent out.</param>
    /// <param name="AccountId">The email account ID which is used to send out the email.</param>
    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid);

    /// <summary>
    /// Gets the e-mail accounts registered for the connector.
    /// </summary>
    /// <param name="Accounts">Out variable that holds the registered e-mail accounts for the connector.</param>
    procedure GetAccounts(var Accounts: Record "Email Account");

    /// <summary>
    /// Shows the information for an e-mail account.
    /// </summary>
    /// <param name="AccountId">The ID of the e-mail account</param>
    procedure ShowAccountInformation(AccountId: Guid);

    /// <summary>
    /// Registers an e-mail account for the connector.
    /// </summary>
    /// <remarks>The out parameter must hold the account ID of the added account.</remarks>
    /// <param name="Account">Out parameter with the details of the registered Account.</param>
    /// <returns>True if an account was registered.</returns>
    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean

    /// <summary>
    /// Deletes an e-mail account for the connector.
    /// </summary>
    /// <param name="AccountId">The ID of the e-mail account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean

    /// <summary>
    /// Provides a custom logo for the connector that shows in the Setup Email Account Guide.
    /// </summary>
    /// <returns>Base64 encoded image.</returns>
    /// <remarks>The recomended image size is 128x128.</remarks>
    /// <returns>The logo of the connector is Base64 format</returns>
    procedure GetLogoAsBase64(): Text;

    /// <summary>
    /// Provides a more detailed description of the connector.
    /// </summary>
    /// <returns>A more detailed desctiption of the connector.</returns>
    procedure GetDescription(): Text[250];
}