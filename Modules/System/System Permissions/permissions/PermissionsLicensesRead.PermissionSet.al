// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

permissionset 88 "Permissions & Licenses - Read"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata "Access Control" = R,
                  tabledata Entitlement = R,
                  tabledata "Entitlement Set" = R,
                  tabledata "Membership Entitlement" = R,
                  tabledata "License Information" = R,
                  tabledata "License Permission" = R,
#pragma warning disable AL0432
                  tabledata Permission = R,
#pragma warning restore AL0432
                  tabledata "Permission Range" = R,
#pragma warning disable AL0432
                  tabledata "Permission Set" = R,
#pragma warning restore AL0432
                  tabledata "Tenant License State" = R,
                  tabledata "Tenant Permission" = R,
                  tabledata "Tenant Permission Set" = R,
                  tabledata "Tenant Permission Set Rel." = R,
                  tabledata "Expanded Permission" = R;
}
