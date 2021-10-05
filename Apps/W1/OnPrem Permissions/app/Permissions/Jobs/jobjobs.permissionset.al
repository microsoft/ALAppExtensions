// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1088 "JOB-JOBS"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read jobs and entries';

    IncludedPermissionSets = "Jobs - Read";
}
