#if not CLEAN23
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 5418 "G/L-ACC SCHED"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read account schedules';
    ObsoleteReason = 'Use Account Schedules - View instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    IncludedPermissionSets = "Account Schedules - View";
}
#endif