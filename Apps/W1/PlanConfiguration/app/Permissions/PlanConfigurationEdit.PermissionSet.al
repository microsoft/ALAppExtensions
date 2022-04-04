// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9050 "Plan Configuration - Edit"
{
    Assignable = false;
    Access = Internal;
    Caption = 'License Configuration - Edit';

    IncludedPermissionSets = "Plan Configuration - Read";

    Permissions = tabledata "Custom User Group In Plan" = imd;
}
