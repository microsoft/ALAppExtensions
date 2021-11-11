// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 150 "System Initialization - Exec"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "System Initialization - Obj.",
                             "User Login Times - View",
                             "AAD User Management - Exec";
}