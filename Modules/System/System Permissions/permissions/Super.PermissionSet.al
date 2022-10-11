// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 31 "SUPER"
{
    Access = Public;
    Assignable = true;
    Caption = 'This role has all permissions.';

    IncludedPermissionSets = "Application Objects - Exec",
                             "Super (Data)",
                             "System Objects - Exec";
}
