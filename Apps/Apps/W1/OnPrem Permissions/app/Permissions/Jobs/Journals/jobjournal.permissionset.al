// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 7788 "JOB-JOURNAL"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create entries in job journals';

    IncludedPermissionSets = "Jobs Journals - Edit";
}
