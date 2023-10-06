// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

using System.Environment;

permissionset 1481 "Edit in Excel - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Edit in Excel - Objects";

    Permissions = TableData "Media Resources" = r;
}
