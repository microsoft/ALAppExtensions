// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Integration.Excel;
permissionset 132525 "Edit in Excel Test Lib. - Adm"
{
    Assignable = false;

    IncludedPermissionSets = "Edit in Excel Test Lib. - Obj.";

    Permissions =
        tabledata "Edit In Excel Test Table" = RIMD; // solves AS0103, PTE0004
}