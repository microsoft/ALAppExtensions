// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4615 "Email - SMTP API - Objects"
{
    Assignable = false;
    Access = Internal;
    Caption = 'Email - SMTP API - Objects';

    Permissions = codeunit "Anonymous SMTP Auth" = X,
                  codeunit "Basic SMTP Auth" = X,
                  codeunit "NTLM SMTP Auth" = X,
                  codeunit "OAuth2 SMTP Auth" = X,
                  codeunit "SMTP Authentication" = X,
                  codeunit "MailKit Client" = X,
                  codeunit "SMTP Client" = X,
                  codeunit "SMTP Client Impl" = X,
                  codeunit "SMTP Message" = X,
                  codeunit "SMTP Message Impl" = X;
}