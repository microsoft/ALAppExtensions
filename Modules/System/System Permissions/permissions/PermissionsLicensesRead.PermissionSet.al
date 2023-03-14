// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 88 "Permissions & Licenses - Read"
{
    Access = Public;
    Assignable = False;

    Permissions = tabledata "Access Control" = R,
                  tabledata Entitlement = R,
                  tabledata "Entitlement Set" = R,
                  tabledata "Membership Entitlement" = R,
                  tabledata "License Information" = R,
                  tabledata "License Permission" = R,
                  tabledata Permission = R,
                  tabledata "Permission Range" = R,
                  tabledata "Permission Set" = R,
                  tabledata "Tenant License State" = R,
                  tabledata "Tenant Permission" = R,
                  tabledata "Tenant Permission Set" = R,
                  tabledata "Tenant Permission Set Rel." = R,
                  tabledata "Expanded Permission" = R;
}
