// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9176 "User Settings - View"
{
    Assignable = false;

    IncludedPermissionSets = "Language - View",
                             "Tenant License State - Read",
                             "Time Zone Selection - Read",
                             "User Selection - Read",
                             "User Login Times - View",
                             "User Permissions - Read",
                             "AAD User Management - Exec";

    Permissions = tabledata "All Profile" = r,
                  tabledata Company = r,
                  tabledata "Extra Settings" = rim,
                  tabledata "Tenant Profile" = r,
                  tabledata "Tenant Profile Setting" = rim,
                  tabledata "User Personalization" = rim;
}