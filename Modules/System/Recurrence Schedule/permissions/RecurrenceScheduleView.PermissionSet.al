// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 4691 "Recurrence Schedule - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Recurrence Schedule - Read";

    Permissions = tabledata "Recurrence Schedule" = imd;
}
