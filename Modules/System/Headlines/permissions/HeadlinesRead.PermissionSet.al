// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1439 "Headlines - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Headlines - Objects",
                             "User Login Times - Read";

    Permissions = tabledata User = r;
}