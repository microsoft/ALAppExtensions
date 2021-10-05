// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 1751 "Data Classification - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Data Classification - Read";

    Permissions = tabledata "Data Privacy Entities" = IMD,
                  tabledata "Fields Sync Status" = imd,
                  tabledata "Data Sensitivity" = imd;
}
