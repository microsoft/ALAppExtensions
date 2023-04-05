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
                             "D365 ATTACH DEBUG",
                             "D365 BACKUP/RESTORE",
                             "D365 SNAPSHOT DEBUG",
                             "Data Cleanup - Admin",
                             "Email - Admin",
                             "Exten. Mgt. - Admin",
#if not CLEAN20
#pragma warning disable AL0432
                             "SMARTLIST DESIGNER",
#pragma warning restore
#endif
                             "Edit in Excel-Admin",
                             "Feature Key - Admin",
                             "Permissions & Licenses - Edit",
                             "Priv. Notice - Admin",
                             "Retention Policy - Admin",
                             "Page Summary - Admin",
                             "TROUBLESHOOT TOOLS";
}
