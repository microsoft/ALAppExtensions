// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4470 "Record Link Management - Obj."
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Confirm Management - Objects";

    Permissions = Codeunit "Record Link Impl." = X,
                  Codeunit "Record Link Management" = X,
                  Codeunit "Remove Orphaned Record Links" = X;
}
