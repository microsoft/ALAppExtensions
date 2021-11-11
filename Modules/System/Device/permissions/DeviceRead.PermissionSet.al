// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 776 "Device - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Device - Objects";

    Permissions = tabledata Device = r;
}
