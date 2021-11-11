// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 102 "Media - View"
{
    Access = Public;
    Assignable = False;

    IncludedPermissionSets = "Media - Read";

    Permissions = tabledata "Tenant Media" = imd,
                  tabledata "Tenant Media Set" = imd,
                  tabledata "Tenant Media Thumbnails" = imd;
}
