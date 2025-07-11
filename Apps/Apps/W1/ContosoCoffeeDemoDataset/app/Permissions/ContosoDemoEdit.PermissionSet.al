// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 4767 "Contoso Demo - Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Contoso Demo - Edit';

    IncludedPermissionSets = "Contoso Demo - Read";

    Permissions =
        tabledata "EService Demo Data Setup" = IM,
        tabledata "FA Module Setup" = IM,
        tabledata "Human Resources Module Setup" = IM,
        tabledata "Jobs Module Setup" = IM,
        tabledata "Manufacturing Module Setup" = IM,
        tabledata "Service Module Setup" = IM,
        tabledata "Warehouse Module Setup" = IM,
        tabledata "Contoso Coffee Demo Data Setup" = IM,
        tabledata "Contoso Demo Data Module" = IM,
        tabledata "Contoso Module Dependency" = IM;
}
