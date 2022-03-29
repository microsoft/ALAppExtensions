// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Functions to be implemented by every SMTP authentication type
/// </summary>
interface "SMTP Auth"
{
    Access = Internal;

    /// <summary>
    /// Authenticate the SMTP client with the SMTP account.
    /// </summary>
    /// <param name="SmtpClient">SMTP client to authenticate.</param>
    /// <param name="SMTPAuth">The authentication information to use for authenticating the SMTP client.</param>
    procedure Authenticate(SmtpClient: DotNet SmtpClient; var SMTPAuthentication: Codeunit "SMTP Authentication");
}