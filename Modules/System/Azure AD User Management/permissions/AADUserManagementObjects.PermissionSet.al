// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

permissionset 9010 "AAD User Management - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Page "Azure AD User Update Wizard" = X,
                  Page "Azure AD User Updates Part" = X;
}
