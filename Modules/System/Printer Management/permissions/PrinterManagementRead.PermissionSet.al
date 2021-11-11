// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2616 "Printer Management - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Printer Management - Objects";

    Permissions = tabledata Printer = r;
}