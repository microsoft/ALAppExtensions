// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9703 "Cues and KPIs - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Cues and KPIs - View";

    Permissions = tabledata "Cue Setup" = RIMD;
}
