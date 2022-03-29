// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Interface to allow usage of different clients.
/// </summary>
interface "iSMTP Client"
{
    procedure Connect(Host: Text; Port: Integer; SecureConnection: Boolean): Boolean;

    procedure Authenticate(Authentication: Enum "SMTP Authentication Types"; var SMTPAuthentication: Codeunit "SMTP Authentication"): Boolean;

    procedure Send(SMTPMessage: Codeunit "SMTP Message"): Boolean;

    procedure Disconnect();
}