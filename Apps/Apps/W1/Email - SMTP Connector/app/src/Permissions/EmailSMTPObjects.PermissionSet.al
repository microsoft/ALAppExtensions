// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 5522 "Email SMTP - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - SMTP Connector - Objects';

    Permissions = page "SMTP Account" = X,
                  table "SMTP Account" = X,
                  page "SMTP Account Wizard" = X,
                  codeunit "Dummy SMTP Authentication" = X,
                  codeunit "SMTP Connector Impl." = X,
                  codeunit "SMTP Connector Install" = X,
                  codeunit "OAuth2 SMTP Authentication" = X,
                  codeunit "SMTP Connector - Upgrade" = X;
}
