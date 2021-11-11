// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 1750 "Data Classification - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Data Classification - Objects";

    Permissions = tabledata Company = r,
                  tabledata "Data Privacy Entities" = R,
                  tabledata "Fields Sync Status" = r,
                  tabledata "Data Sensitivity" = R,
                  tabledata Field = r,
                  tabledata "Page Data Personalization" = R, // Page.Run requires this
                  tabledata "Table Relations Metadata" = r,
                  tabledata User = r;
}
