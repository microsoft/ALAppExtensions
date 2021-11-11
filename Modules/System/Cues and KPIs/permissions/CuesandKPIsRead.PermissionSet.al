// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9701 "Cues and KPIs - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Cues and KPIs - Objects",
                             "Field Selection - Read",
                             "User Selection - Read";

    Permissions = tabledata "Cue Setup" = r,
                  tabledata Field = r;
}
