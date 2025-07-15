// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 4766 "Contoso Demo - Read"
{
    Access = Public;
    Assignable = true;
    Caption = 'Contoso Demo - Edit';

    IncludedPermissionSets = "Contoso Demo - Objects";

    Permissions =
                  tabledata "EService Demo Data Setup" = R,
                  tabledata "FA Module Setup" = R,
                  tabledata "Human Resources Module Setup" = R,
                  tabledata "Jobs Module Setup" = R,
                  tabledata "Manufacturing Module Setup" = R,
                  tabledata "Service Module Setup" = R,
                  tabledata "Warehouse Module Setup" = R,
                  tabledata "Contoso Coffee Demo Data Setup" = R,
                  tabledata "Contoso Demo Data Module" = R,
                  tabledata "Contoso Module Dependency" = R;
}
