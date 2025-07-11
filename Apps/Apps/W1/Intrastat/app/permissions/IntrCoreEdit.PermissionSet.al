// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

permissionset 4812 "Intr. Core - Edit"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Intrastat Core - Edit';

    IncludedPermissionSets = "Intr. Core - Read";

    Permissions =
        tabledata "Intrastat Report Setup" = IMD,
        tabledata "Intrastat Report Header" = IMD,
        tabledata "Intrastat Report Line" = IMD,
        tabledata "Intrastat Report Checklist" = IMD;
}