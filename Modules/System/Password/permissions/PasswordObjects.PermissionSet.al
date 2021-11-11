// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1284 "Password - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Password Dialog Impl." = X,
                  Codeunit "Password Dialog Management" = X,
                  Codeunit "Password Handler Impl." = X,
                  Codeunit "Password Handler" = X,
                  Page "Password Dialog" = X,
                  Report "Change Password" = X;
}
