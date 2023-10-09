#if not CLEAN23
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3633 "G/L-ACC SCHED, EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit account schedules';
    ObsoleteReason = 'Use Account Schedules - Edit instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    IncludedPermissionSets = "Account Schedules - Edit";
}
#endif