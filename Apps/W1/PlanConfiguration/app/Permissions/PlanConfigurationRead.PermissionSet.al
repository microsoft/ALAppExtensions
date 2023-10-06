#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

permissionset 9049 "Plan Configuration - Read"
{
    Assignable = false;
    Access = Internal;
    Caption = 'License Configuration - Read';

    IncludedPermissionSets = "Plan Configuration - Objects";

    Permissions = tabledata "Custom User Group In Plan" = r;
}

#endif