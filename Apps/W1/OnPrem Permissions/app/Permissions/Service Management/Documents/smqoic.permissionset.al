// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 8612 "SM-Q/O/I/C"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create orders,quotes,etc.';

    IncludedPermissionSets = "Service Documents - Edit";
}
