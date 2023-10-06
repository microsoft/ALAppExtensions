// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Azure.Identity;

permissionset 160 SECURITY
{
    Assignable = true;
    Caption = 'Assign permissions to users';

    IncludedPermissionSets = "SECURITY (System)",
                             "Azure AD Plan - Admin",
                             "Security Groups - Admin",
                             "System Application - Basic";
}