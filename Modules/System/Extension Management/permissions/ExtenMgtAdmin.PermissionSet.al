// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2502 "Exten. Mgt. - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Extension Management - Admin';

    IncludedPermissionSets = "Extension Management - View";

    Permissions = tabledata "Application Object Metadata" = Rimd, // r needed for check CanManageExtensions
                  tabledata "Application Dependency" = Rimd,
                  tabledata "Application Resource" = Rimd,
                  tabledata "Installed Application" = Rimd,
                  tabledata "NAV App Capabilities" = Rimd,
                  tabledata "NAV App Data Archive" = Rimd,
                  tabledata "NAV App Installed App" = Rimd,
                  tabledata "NAV App Object Prerequisites" = Rimd,
                  tabledata "NAV App Tenant Add-In" = Rimd,
                  tabledata "NAV App Tenant Operation" = RIMD,
                  tabledata "Published Application" = Rimd;
}