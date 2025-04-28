// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 5680 "JOB-PERIODIC"
{
    Access = Public;
    Assignable = true;
    Caption = 'Job periodic activities';
        
    IncludedPermissionSets = "Jobs - View";
}
