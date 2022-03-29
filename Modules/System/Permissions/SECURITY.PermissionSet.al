// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 160 SECURITY
{
    Access = Public;
    Assignable = true;
    Caption = 'Assign permissions to users';

    IncludedPermissionSets = "System Application - Basic",
                             "Company - Edit",
                             "Permissions & Licenses - Edit",
                             "Azure AD Plan - Admin",
                             "Session - Edit";

    Permissions = system "Tools, Security, Roles" = X,
                  tabledata "Add-in" = imd,
                  tabledata "All Profile" = IMD,
                  tabledata AllObj = imd,
                  tabledata AllObjWithCaption = Rimd,
                  tabledata Chart = imd,
                  tabledata "Code Coverage" = Rimd,
                  tabledata "Data Sensitivity" = RIMD,
                  tabledata Date = imd,
                  tabledata "Designed Query" = R,
                  tabledata "Designed Query Caption" = R,
                  tabledata "Designed Query Category" = R,
                  tabledata "Designed Query Column" = R,
                  tabledata "Designed Query Column Filter" = R,
                  tabledata "Designed Query Data Item" = R,
                  tabledata "Designed Query Filter" = R,
                  tabledata "Designed Query Group" = R,
                  tabledata "Designed Query Join" = R,
                  tabledata "Designed Query Management" = RIMD,
                  tabledata "Designed Query Obj" = Rimd,
                  tabledata "Designed Query Order By" = R,
                  tabledata "Designed Query Permission" = R,
                  tabledata "Document Service" = imd,
                  tabledata Entitlement = imd,
                  tabledata "Entitlement Set" = imd,
                  tabledata "Feature Key" = RIMD,
                  tabledata Field = Rimd,
                  tabledata Integer = Rimd,
                  tabledata "Intelligent Cloud" = Rimd,
                  tabledata "Intelligent Cloud Status" = Rimd,
                  tabledata Key = Rimd,
                  tabledata "License Information" = imd,
                  tabledata "License Permission" = imd,
                  tabledata "Membership Entitlement" = imd,
                  tabledata "NAV App Setting" = RIMD,
                  tabledata "Object Metadata" = imd,
                  tabledata Permission = imd,
                  tabledata "Permission Range" = imd,
                  tabledata "Permission Set" = imd,
                  tabledata Profile = IMD,
                  tabledata "Profile Configuration Symbols" = IMD,
                  tabledata "Profile Metadata" = IMD,
                  tabledata "Profile Page Metadata" = IMD,
                  tabledata "Server Instance" = imd,
                  tabledata "SID - Account ID" = Rimd,
                  tabledata "System Object" = imd,
                  tabledata "Table Information" = Rimd,
                  tabledata "Tenant Profile" = IMD,
                  tabledata "Tenant Profile Extension" = IMD,
                  tabledata "Tenant Profile Page Metadata" = IMD,
                  tabledata "Tenant Profile Setting" = IMD,
                  tabledata User = RMD,
                  tabledata "User Property" = Rimd,
                  tabledata "Windows Language" = imd;
}