// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 4340 "SM-SERVITEM,EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create service items';

    IncludedPermissionSets = "Service Items - Edit";
}
