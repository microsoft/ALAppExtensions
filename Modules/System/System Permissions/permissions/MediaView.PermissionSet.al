// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Environment;

permissionset 102 "Media - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Media - Read";

    Permissions = tabledata "Tenant Media" = imd,
                  tabledata "Tenant Media Set" = imd,
                  tabledata "Tenant Media Thumbnails" = imd;
}
