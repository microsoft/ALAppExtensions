// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3872 "JOB-REGISTER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read job registers';

    IncludedPermissionSets = "Jobs Registers - Read";
}
