// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 4503 "Email Conn. - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email Microsoft 365 Connector - Objects';

    Permissions = codeunit "Microsoft 365 Connector" = X,
                  page "Microsoft 365 Email Account" = X,
                  page "Microsoft 365 Email Wizard" = X;
}
