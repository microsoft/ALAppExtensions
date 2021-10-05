// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2501 "Extension Management - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Extension Management - Read";

    Permissions = tabledata "NAV App Setting" = m;
}