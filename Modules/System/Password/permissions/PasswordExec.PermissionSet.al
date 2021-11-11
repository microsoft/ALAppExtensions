// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1282 "Password - Exec"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Password - Objects";

    Permissions = tabledata User = r,
                  system "Tools, Security, Password" = X;
}