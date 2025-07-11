// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 4508 "Email ORA - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - Outlook REST API - Objects';

    Permissions = codeunit "Email - OAuth Client" = X,
                  codeunit "Email - Outlook API Client" = X,
                  codeunit "Email - Outlook API Helper" = X,
                  codeunit "Email - Outlook API Install" = X,
                  page "Email - Outlook API Setup" = X,
                  table "Email - Outlook Account" = X,
                  table "Email - Outlook API Setup" = X;
}
