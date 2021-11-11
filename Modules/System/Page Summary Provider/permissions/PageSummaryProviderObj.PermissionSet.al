// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2716 "Page Summary Provider - Obj."
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Base64 Convert - Objects";

    Permissions = Codeunit "Page Summary Provider Impl." = X,
                  Codeunit "Page Summary Provider" = X;
}
