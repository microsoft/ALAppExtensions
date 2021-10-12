// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 6711 "Web Service Management - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Web Service Management - Read";

    Permissions = tabledata "Tenant Web Service" = imd,
                  tabledata "Tenant Web Service Columns" = imd,
                  tabledata "Tenant Web Service Filter" = imd,
                  tabledata "Tenant Web Service OData" = imd,
                  tabledata "Web Service" = imd,
                  tabledata "Web Service Aggregate" = imd;
}