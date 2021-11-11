// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 87 "Metadata - Read"
{
    Access = Public;
    Assignable = False;

    IncludedPermissionSets = "Field Selection - Read",
                             "Object Selection - Read",
                             "Table Information - Read";

    Permissions = tabledata "All Profile" = R,
                  tabledata AllObj = R,
                  tabledata "CodeUnit Metadata" = R,
                  tabledata Date = R,
                  tabledata "Object Metadata" = R,
                  tabledata "Page Documentation" = R,
                  tabledata "Page Metadata" = R,
                  tabledata Profile = R,
                  tabledata "Profile Configuration Symbols" = R,
                  tabledata "Profile Metadata" = R,
                  tabledata "Profile Page Metadata" = R,
                  tabledata "Report Metadata" = R,
                  tabledata "System Object" = R,
                  tabledata "Table Metadata" = R,
                  tabledata "Tenant Profile" = R,
                  tabledata "Tenant Profile Extension" = R,
                  tabledata "Tenant Profile Page Metadata" = R,
                  tabledata "Tenant Profile Setting" = R,
                  tabledata "Time Zone" = R,
                  tabledata "Windows Language" = R;
}
