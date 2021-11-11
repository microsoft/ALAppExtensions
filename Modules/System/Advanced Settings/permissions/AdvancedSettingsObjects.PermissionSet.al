// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1817 "Advanced Settings - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Navigation Bar Subs. - Objects";

    Permissions = Codeunit "Advanced Settings Impl." = X,
                  Codeunit "Advanced Settings" = X,
                  Page "Advanced Settings" = X;
}
