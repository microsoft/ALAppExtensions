// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2143 "D365 COMPANY HUB"
{
    Assignable = true;

    IncludedPermissionSets = "Company Hub - Objects";

    Permissions = tabledata "COHUB Company Endpoint" = RIMD,
                  tabledata "COHUB Company KPI" = RIMD,
                  tabledata "COHUB Enviroment" = RIMD,
                  tabledata "COHUB Group" = RIMD,
                  tabledata "COHUB Group Company Summary" = RIMD,
                  tabledata "COHUB User Task" = RIMD;
}
