// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9176 "User Settings - View"
{
    Assignable = false;

    IncludedPermissionSets = "User Settings - Objects",
                             "Language - View",
                             "Tenant License State - Read",
                             "Time Zone Selection - Read",
                             "User Selection - Read",
                             "User Permissions - Read",
                             "AAD User Management - Exec",
                             "Azure AD User - View";

    Permissions = tabledata "All Profile" = r,
                  tabledata Company = r,
                  tabledata "Tenant Profile" = r,
                  tabledata "Tenant Profile Setting" = rim,
                  tabledata "User Personalization" = rim;
}