// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Integration.Excel;

permissionset 4426 "Excel Export Action"
{
    Assignable = true;
    Caption = 'D365 Excel Export Action';

    IncludedPermissionSets = "Edit in Excel - View",
                             "Export Report Excel";
}