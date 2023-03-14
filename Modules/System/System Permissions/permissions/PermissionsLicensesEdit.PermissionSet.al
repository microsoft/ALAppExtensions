// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 89 "Permissions & Licenses - Edit"
{
    Assignable = False;

    IncludedPermissionSets = "Permissions & Licenses - Read";

    Permissions = tabledata "Access Control" = IMD,
                  tabledata "Tenant Permission" = IMD,
                  tabledata "Tenant Permission Set" = IMD,
                  tabledata "Tenant Permission Set Rel." = IMD;
}
