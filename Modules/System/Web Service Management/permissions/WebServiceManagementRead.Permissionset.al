// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 6710 "Web Service Management - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Web Service Management - Obj.";

    Permissions = tabledata AllObj = r,
                  tabledata AllObjWithCaption = r,
                  tabledata Field = r,
                  tabledata "Tenant Web Service" = R,
                  tabledata "Tenant Web Service Columns" = R,
                  tabledata "Tenant Web Service Filter" = R,
                  tabledata "Tenant Web Service OData" = R,
                  tabledata "Web Service" = R,
                  tabledata "Web Service Aggregate" = R;
}