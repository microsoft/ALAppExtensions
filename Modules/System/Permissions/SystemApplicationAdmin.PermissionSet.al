// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 154 "System Application - Admin"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "System Application - Basic",
                             "Company - Edit",
                             "D365 BACKUP/RESTORE",
                             "D365 SNAPSHOT DEBUG",
                             "Email - Admin",
                             "Exten. Mgt. - Admin",
#if not CLEAN19
                             "EXCEL EXPORT ACTION",
#endif
                             "Edit in Excel-Admin",
                             "Feature Key - Admin",
                             "Permissions & Licenses - Edit",
                             "Retention Policy - Admin",
                             "SMARTLIST DESIGNER",
                             "TROUBLESHOOT TOOLS";
}
