// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

permissionset 4501 "EmailCurUser-Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email Current User Connector - Objects';

    Permissions = codeunit "Current User Connector" = X,
                  page "Current User Email Account" = X;
}
