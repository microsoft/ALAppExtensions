// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Environment;

permissionset 1928 "Data Cleanup - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Data Cleanup - Objects";

    Permissions = tabledata "Tenant Media" = r,
                  tabledata "Tenant Media Set" = r;
}
