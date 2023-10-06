// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Environment;

permissionset 1929 "Data Cleanup - Admin"
{
    Access = Internal;
    Assignable = true;

    IncludedPermissionSets = "Data Cleanup - View";

    Permissions = tabledata "Tenant Media" = imd,
                  tabledata "Tenant Media Set" = imd;
}
