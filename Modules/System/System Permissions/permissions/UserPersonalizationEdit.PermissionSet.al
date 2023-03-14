// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 91 "User Personalization - Edit"
{
    Access = Public;
    Assignable = False;

    IncludedPermissionSets = "User Personalization - Read";

    Permissions = tabledata "Page Data Personalization" = IMD,
                  tabledata "User Default Style Sheet" = IMD,
                  tabledata "User Personalization" = IMD,
#pragma warning disable AL0432
                  tabledata "User Metadata" = IMD,
#pragma warning restore AL0432
                  tabledata "User Page Metadata" = IMD;
}
