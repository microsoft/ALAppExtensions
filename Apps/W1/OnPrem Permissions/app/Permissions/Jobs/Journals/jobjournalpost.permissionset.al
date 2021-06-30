// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3415 "JOB-JOURNAL, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post job journals';

    IncludedPermissionSets = "Jobs Journals - Post";
}
