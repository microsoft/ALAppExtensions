// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9702 "Cues and KPIs - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Cues and KPIs - Read";

    Permissions = tabledata "Cue Setup" = imd;
}
