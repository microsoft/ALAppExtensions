// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9171 "Default Role Center - Read"
{
    Access = internal;
    Assignable = false;

    IncludedPermissionSets = "Default Role Center - Objects";

    Permissions = tabledata "All Profile" = r,
                  tabledata AllObjWithCaption = r;
}