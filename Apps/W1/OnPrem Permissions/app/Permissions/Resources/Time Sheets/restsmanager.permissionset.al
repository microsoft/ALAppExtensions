// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 7666 "RES-TS MANAGER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Approve time sheets';

    IncludedPermissionSets = "Time Sheets - Post";
}
