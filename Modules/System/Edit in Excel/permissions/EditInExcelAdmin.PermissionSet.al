// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Excel;

using System.Environment.Configuration;

permissionset 1480 "Edit in Excel-Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit in Excel - Admin';

    IncludedPermissionSets = "Edit in Excel - View",
                             "Guided Experience - View";

    Permissions = tabledata "Edit in Excel Settings" = RIMD;
}